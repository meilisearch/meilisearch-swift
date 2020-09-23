#!/bin/sh
docker run -d --rm -p 7700:7700 getmeili/meilisearch:v0.13.0rc0 ./meilisearch  --no-analytics=true --master-key=5YsHgCa4hkA8W8hGrftkKPVbyQDHzdJR
swift test