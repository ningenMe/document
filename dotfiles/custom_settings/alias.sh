alias ll='ls -la'

alias docker-reset='_docker_reset'
function _docker_reset() {
  docker container stop `docker container ls -qa`
  docker container rm `docker container ls -qa`
  docker volume rm `docker volume ls -q`
}

alias git-clean='_git_branch_clean'
function _git_branch_clean() {
  git branch | grep -v "*" | xargs git branch -D
}

alias echopath='_echo_path'
function _echo_path() {
  echo $PATH | sed 's/:/\'$'\n/g'
}

alias desql='_dev_sql'
function _dev_sql() {
  echo mysql -h127.0.0.1 -uroot -ppassword
}
