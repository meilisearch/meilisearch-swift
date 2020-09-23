#!/bin/sh
docker run -d --rm -p 7700:7700 getmeili/meilisearch:latest ./meilisearch  --no-analytics=true --master-key=masterKey
swift test