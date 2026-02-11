#!/bin/bash

# Usage: ./scripts/list-external-contributors.sh <TAG>

set -e

date_of_tag=$(git log -1 --format=%aI --date=iso-strict $1)
unique_authors=$(gh api "repos/lyxal_network/lyxal_network/commits?since=$date_of_tag" --paginate -q '.[].author.login' | sort -u)
rust_lyxal_network_maintainers_team_members=$(gh api teams/6797340/members --paginate | jq -r '.[].login' | sort -u)

echo "$unique_authors" | grep -vxF -f <(echo "$rust_lyxal_network_maintainers_team_members") | grep -vF "bot" | grep -vF "web-flow"
