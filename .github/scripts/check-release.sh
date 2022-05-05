#!/bin/sh

# Checking if current tag matches the package version
current_tag=$(echo $GITHUB_REF | tr -d 'refs/tags/')
file1='README.md'
file2='.code-samples.meilisearch.yaml'
file3='Sources/MeiliSearch/Model/PackageVersion.swift'
file_tag1=$(grep '.package(url:' $file1 | cut -d ':' -f4 | tr -d '"' | tr -d ')' | tr -d ' ')
file_tag2=$(grep '.package(url:' $file2 | cut -d ':' -f4 | tr -d '"' | tr -d ')' | tr -d ' ')
file_tag3=$(grep 'let current' -A 0 $file3 | cut -d '=' -f2 | tr -d '"' | tr -d ' ')

if [ "$current_tag" != "$file_tag1" ] || [ "$current_tag" != "$file_tag2" ] || [ "$current_tag" != "$file_tag3" ]; then
  echo "Error: the current tag does not match the version in package file(s)."
  echo "$file1: found $file_tag1 - expected $current_tag"
  echo "$file2: found $file_tag2 - expected $current_tag"
  echo "$file3: found $file_tag3 - expected $current_tag"
  exit 1
fi

echo 'OK'
exit 0
