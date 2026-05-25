# Go environment settings
export GOPATH=$HOME/go
if [ -z "$__PATH_INITIALIZED" ]; then
  export PATH=/usr/local/go/bin:$PATH
  export PATH=$GOPATH/bin:$PATH
fi
