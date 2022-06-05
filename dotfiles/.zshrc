typeset -U path PATH
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
)

. /opt/homebrew/opt/asdf/libexec/asdf.sh

GOV=$(asdf where golang)
export GOROOT=$GOV/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

export PATH="/opt/homebrew/opt/mysql@5.7/bin:$PATH"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

source ~/custom_settings/env.sh
source ~/custom_settings/alias.sh