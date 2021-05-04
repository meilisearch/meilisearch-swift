#!/bin/sh

# Checking if current tag matches the package version
file='MeiliSearch.podspec'
file_tag=$(grep '  s.version' $file | cut -d '=' -f2 | tr -d "'" | tr -d ' ')
current_tag=$(echo $GITHUB_REF | tr -d 'refs/tags/v')
if [ "$current_tag" != "$file_tag" ]; then
  echo "Error: the current tag does not match the version in $file."
  echo "$current_tag vs $file_tag"
  exit 1
fi

echo 'OK'
exit 0
