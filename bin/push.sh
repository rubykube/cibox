#!/bin/sh

git config --global user.name $BOT_NAME
git config --global user.email $BOT_EMAIL

git remote add authenticated-origin https://$BOT_USERNAME:$GITHUB_API_KEY@github.com/${DRONE_REPO}
git fetch authenticated-origin

bump patch --commit-message "release bump [ci skip]"

git tag $(cat VERSION)
git push authenticated-origin master
git push --tags authenticated-origin
git describe --tags $(git rev-list --tags --max-count=1) > .tags
