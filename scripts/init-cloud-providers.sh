#!/bin/bash

set +e

for provider in gdrive onedrive; do
    mkdir ~/$provider
    rclone mount $provider: ~/$provider \
        --vfs-cache-mode full \
        --vfs-read-chunk-size 10M \
        --vfs-read-chunk-size-limit 20M \
        --multi-thread-cutoff 9M \
        --multi-thread-streams 4 &

    trap "fusermount -u ~/$provider" EXIT
done
