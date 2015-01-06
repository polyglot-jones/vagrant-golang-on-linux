#!/usr/bin/env bash
echo "Setting GOPATH and PATH"
export GOPATH=/workgo
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
echo "Declaring aliases for cdg and h"
alias cdg='cd $GOPATH/src'
alias h='history'
