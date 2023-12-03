#!/bin/bash

SEARCH_PAGES='2'

if [ -f ./latest ]; then
    rm latest
fi

for i in $(seq 1 ${SEARCH_PAGES}); do
    curl -s "https://packages.gitlab.com/gitlab/gitlab-ee?page=${i}" | grep "_arm64.deb" | grep -v '\-rc' | sed 's/.*>\(.*\)<.*/\1/' | sort -u | sed 's/gitlab-ee_\(.*\)_arm64.deb/\1/' >> latest;
done
sort -rVu latest -o latest

