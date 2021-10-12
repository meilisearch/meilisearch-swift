#!/bin/sh

# This script is used in the SDK CIs to fetch the latest MeiliSearch release name (ex: v0.16.0).
# The MeiliSearch latest version is needed to ensure the version that is downloaded is the latest one.
# The access token ($1) is provided as the first arg of the script: ./latest_release_meilisearch.sh my_token
# The personal access token should have access to the user email.
# See https://docs.github.com/en/rest/guides/basics-of-authentication#checking-granted-scopes


temp_file='temp_file' # temp_file needed because `grep` would start before the download is over

curl -H "Authorization:  $1" -s 'https://api.github.com/repos/meilisearch/MeiliSearch/releases' > "$temp_file" -i

echo "Latest release of MeiliSearch is" 
cat "$temp_file" 

latest_ms_release=$(cat "$temp_file" \
    | grep -E 'tag_name' | grep 'v0' | head -1 \
    | tr -d ',"' | cut -d ':' -f2 | tr -d ' ')
rm -rf "$temp_file"
echo "$latest_ms_release"
exit 0
