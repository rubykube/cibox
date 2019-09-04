#!/bin/sh

SEMVER=$(cat VERSION)

git config --global user.name "Kite Bot"
git config --global user.email "kite-bot@heliostech.fr"

git remote add authenticated-origin https://kite-bot:$GITHUB_API_KEY@github.com/${DRONE_REPO}
git fetch authenticated-origin

bump patch --commit-message "Release $SEMVER [ci skip]"

git tag $(cat VERSION)
git push authenticated-origin master
git push --tags authenticated-origin
git describe --tags $(git rev-list --tags --max-count=1) > .tags
