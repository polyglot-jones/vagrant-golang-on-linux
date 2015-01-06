#!/usr/bin/env bash
export GOPATH=/workgo
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export POSTGRES_DSN="user=vagrant password=vagrant host=/var/run/postgresql port=5432 dbname=vagrant sslmode=disable"
alias cdg='cd $GOPATH/src'
alias h='history'
