#!/bin/bash

cp -r src.link/* ./src

git add .
git commit -m "$@"
git push
