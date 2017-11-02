#!/bin/sh
yum install -y wget
cd /usr/sbin
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
mv jq-linux64 jq
git config --global user.name "childsb"
git config --global user.email "bchilds@redhat.com"
git config --global alias.pu '!git fetch origin -v; git fetch upstream -v; git rebase upstream/master'
git remote set-url --push upstream no_push
git config --global push.default simple
