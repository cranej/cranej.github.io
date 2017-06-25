#!/usr/bin/env sh

# Temporarily store uncommited changes
git stash

# Verify correct branch
git checkout develop

# Build new files
stack exec site clean
stack exec site build

# Overwrite existing files with new files
# cp -a _site/. .
rsync -rvz --filter='P .well-known/'      \
         --delete-excluded        \
         _site/ cranej@$1:/var/www/html

