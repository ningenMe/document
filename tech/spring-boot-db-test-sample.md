# spring-boot + dbunit + dockerでdbのテストを行う

## はじめに
こんにちは。webエンジニア社会人をしている [ningenMe](https://twitter.com/ningenMe) です。

タイトル通り、spring-bootでdbのテストを行う記事です。  
下記のことを行います。

- spring bootでmapperを書いた際のテストを行う
- `gradle test`実行時にテスト専用のdbをdockerで立ち上げる
- dbunitを使ってdbのassertionを行う
- spock / junit でテストを行う


## GitHub
実際に動くソースはこちら

- [https://github.com/ningenMe/spring-boot-db-test-sample](https://github.com/ningenMe/spring-boot-db-test-sample)


## test用のdocker
テスト専用のdbをdockerを使って立てます。  
テストのdbをどこに用意するかというのは選択肢が色々あると思います(テスト用のdbを開発環境に立てたり、h2のインメモリデータベースなど)、が、今回はdockerで立てる方法を採用します。  

今回はサンプルとしてmysqlを使用します。  
下記のdocker-compose.yamlでmysqlを起動します。

```yaml
version: '3'

services:
  db:
    image: mysql:5.7
    container_name: mysql
    environment:
      MYSQL_DATABASE: sample
      MYSQL_ROOT_PASSWORD: password
      TZ: 'Asia/Tokyo'
    command: mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    volumes:
      - ./:/docker-entrypoint-initdb.d
    ports:
      - 3306:3306
```


テスト用のdbを`gradle test`実行時に起動し、`gradle test`終了時に破棄するために下記のtaskを `build.gradle` に書きます。

```groovy
task dockerComposeUp (type: Exec) {
	commandLine 'docker-compose','-f','src/test/resources/docker-compose.yaml','up','-d'
	doLast {
		Thread.sleep(5 * 1000) //5sec
	}
}

task dockerComposeDown (type: Exec) {
	commandLine 'docker-compose', '-f', 'src/test/resources/docker-compose.yaml', 'down', '--remove-orphans', '--volumes'
}

test {
	useJUnitPlatform()
	dependsOn(dockerComposeUp)
}
```
上記のように依存関係を書くことで、`gradle test`を実行した際にテスト専用のdbが立ち上がります。  
またdockerが立ち上がり切る前にテストが始まりconnectionでエラーになることがあるので5秒sleepをかけています。

## schema.sql
テーブル作成用の`schema.sql`ファイルを`docker-compose.yaml`と同じ階層に用意しておくことで、実行時にtableも自動で作られます。

```sql
CREATE TABLE `users` (
  `id`           integer(10) NOT NULL,
  `name`         varchar(255) NOT NULL,
  `deleted_time` timestamp NULL DEFAULT NULL,
  `created_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```
今回はサンプル用にusersというテーブルを用意してテストを書いてみます

## mybatis
sqlはmybatisを用いて記述します。
mybatisの接続設定は下記のようにします。

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/sample
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
```
`username`, `password` をdocker側で設定したものに合わせておきます。  
テスト用でしか使わないので環境変数などは使わなくてok。


## mapper

テスト用のinsertクエリを書きます。bulkでインサートするクエリを書いてみます。

```java
@Mapper
public interface UserMysqlMapper {

  @Insert(
          "<script>" +
          "INSERT INTO " +
          "     users (id, name) " +
          "VALUES " +
          "     <foreach item='user' collection='userDtoList' open='' separator=',' close=''>" +
          "     (#{user.id}, #{user.name}) " +
          "     </foreach> " +
          "</script>"
  )
  void insert(@Param("userDtoList") @NonNull final List<UserDto> userDtoList);

}
```

## spockでのテスト

dbunitを使ってspockでテストを書いていきます。正常系のテストを1個サンプルとして書いていきます。
xmlを使って初期化用、期待値用のテーブルの状態を記述します。


`setup.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataset>
    <users id="1" name="user1" />
    <users id="2" name="user2" />
</dataset>
```

`expect.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataset>
    <users id="1" name="user1" />
    <users id="2" name="user2" />
    <users id="3" name="user3" />
    <users id="4" name="user4" />
</dataset>
```

user1,user2が存在する状態で、user3,user4をinsertするようなテストを書きます。

```groovy
@SpringBootTest
class UserMysqlMapperSpec extends Specification {

    private final static String FILE_PATH = "src/test/groovy/ningenme/net/sample/mapper"

    @Autowired
    JdbcTemplate jdbcTemplate

    @Autowired
    UserMysqlMapper userMysqlMapper

    IDatabaseConnection iDatabaseConnection

    def setup() {
        iDatabaseConnection = new DatabaseConnection(jdbcTemplate.getDataSource().getConnection(),"sample",false);
        iDatabaseConnection.getConfig().setProperty(DatabaseConfig.PROPERTY_METADATA_HANDLER, new MySqlMetadataHandler());
        DatabaseOperation.CLEAN_INSERT.execute(
                iDatabaseConnection,
                new FlatXmlDataSetBuilder().build(new File(FILE_PATH + "/setup.xml"))
        )
    }

    def "insert_新規挿入が出来る" (){
        when:
        def user3 = new UserDto();
        {
            user3.setId(3)
            user3.setName("user3")
        }
        def user4 = new UserDto();
        {
            user4.setId(4)
            user4.setName("user4")
        }
        userMysqlMapper.insert([user3, user4]);

        then:
        def actual = DefaultColumnFilter.excludedColumnsTable(
                iDatabaseConnection.createDataSet().getTable("users"),
                new String[]{"deleted_time","created_time","updated_time"}
        )

        def expect = DefaultColumnFilter.excludedColumnsTable(
                new FlatXmlDataSetBuilder().build(new File(FILE_PATH + "/expect.xml")).getTable("users"),
                new String[]{"deleted_time","created_time","updated_time"}
        )
        assertEquals(actual,expect)
        noExceptionThrown()
    }

}
```

`setup` でconnectionを張り、用意していたxmlを使ってテーブルを初期化します。  
then句の中で insertメソッドを実行した後のテーブルと、期待値用のxmlとで比較を行います。  

この`assertEquals`がdbテーブルの状態で比較が出来るので便利です。  

また比較の際は`excludedColumnsTable`を使うことで、比較に使いたくないカラムを除外できます。



## junitでのテスト

一応junitでも同じ内容のテストを書いておきます。

```java
@SpringBootTest
class UserMysqlMapperTest {

  private final static String FILE_PATH = "src/test/java/ningenme/net/sample/mapper";

  @Autowired
  JdbcTemplate jdbcTemplate;

  @Autowired
  UserMysqlMapper userMysqlMapper;

  IDatabaseConnection iDatabaseConnection;

  @BeforeEach
  void beforeEach() throws SQLException, MalformedURLException, DatabaseUnitException {
    iDatabaseConnection = new DatabaseConnection(jdbcTemplate.getDataSource().getConnection(), "sample", false);
    iDatabaseConnection.getConfig().setProperty(DatabaseConfig.PROPERTY_METADATA_HANDLER, new MySqlMetadataHandler());
    DatabaseOperation.CLEAN_INSERT.execute(
            iDatabaseConnection,
            new FlatXmlDataSetBuilder().build(new File(FILE_PATH + "/setup.xml")));
  }

  @Test
  void insert_新規挿入が出来る() throws SQLException, DatabaseUnitException, MalformedURLException {
    //when
    UserDto user3 = new UserDto();
    {
      user3.setId(3);
      user3.setName("user3");
    }
    UserDto user4 = new UserDto();
    {
      user4.setId(4);
      user4.setName("user4");
    }
    userMysqlMapper.insert(List.of(user3, user4));


    //then
    ITable actual = DefaultColumnFilter.excludedColumnsTable(
            iDatabaseConnection.createDataSet().getTable("users"),
            new String[]{"deleted_time","created_time","updated_time"});

    ITable expect = DefaultColumnFilter.excludedColumnsTable(
            new FlatXmlDataSetBuilder().build(new File(FILE_PATH + "/expect.xml")).getTable("users"),
            new String[]{"deleted_time","created_time","updated_time"});

    assertEquals(actual,expect);
  }

  @AfterEach
  void afterEach() throws SQLException {
    iDatabaseConnection.close();
  }
}
```

## 何が嬉しいか

- dbにdockerを使う点  
テスト用のdbをh2にするとmysqlと微妙に文法が違ってエラーになる、
開発環境にdbを立てると皆で共有になってしまったりする、など弊害が起きがちな気がするので、テスト用のdbはdockerでスタンドアローンなものにするのがベターに感じます。

- dbunitを使う点  
テストでassert用に自分でクエリを書くのはあまり良くないので、dbunitを使うのがやはりオススメだと思います。  
期待値を静的ファイルとして保持できる点でもjava側で色々書くよりは思います。


## さいごに
これでspring bootでdbのテストを行う環境が整ったと思います。  
どれも大したことはしていないですが、組み合わせることで少しは使いやすいものになっているかなと。



sample用のソースは [https://github.com/ningenMe/spring-boot-db-test-sample](https://github.com/ningenMe/spring-boot-db-test-sample) に上げています。  
細かいパッケージ構成等はそちらを確認してください。 

ではでは。