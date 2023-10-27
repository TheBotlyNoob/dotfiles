#!/bin/bash

mackup backup
git add .
git commit -m "Update dotfiles"
git push
