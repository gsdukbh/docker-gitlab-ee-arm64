#!/bin/bash

# Define the number of pages to search for packages
SEARCH_PAGES='1'

# Remove the 'latest' file if it already exists
if [ -f ./latest ]; then
    rm latest
fi

# Loop through the specified number of pages to fetch package information
for i in $(seq 1 ${SEARCH_PAGES}); do
    # Fetch the package list from the GitLab package repository
    # Filter for '_arm64.deb' files, exclude release candidates ('-rc'),
    # extract the package version, and append it to the 'latest' file
    curl -s "https://packages.gitlab.com/app/gitlab/gitlab-ee/search?filter=debs&page=${i}" | \
    grep "_arm64.deb" | grep -v '\-rc' | sed 's/.*>\(.*\)<.*/\1/' | sort -u | \
    sed 's/gitlab-ee_\(.*\)_arm64.deb/\1/' >> latest;
done

# Sort the 'latest' file in version order and remove duplicates
sort -uV latest -o latest


