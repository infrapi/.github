#!/usr/bin/env bash
# Sets each product's version in profile/README.md to its latest GitHub
# release: the `vX.Y.Z` in the table row that links to github.com/infrapi/<repo>.
# Uses $GH_TOKEN / $GITHUB_TOKEN when set (higher API rate limit).
set -euo pipefail
cd "$(dirname "$0")/.."

token=${GH_TOKEN:-${GITHUB_TOKEN:-}}
readme=profile/README.md

for repo in kayra tofu-api ulgen lib; do
  tag=$(curl -fsSL ${token:+-H "Authorization: Bearer $token"} \
          "https://api.github.com/repos/infrapi/$repo/releases/latest" | jq -er .tag_name)
  grep -q "^|.*\*\*\[[^]]*\](https://github.com/infrapi/$repo)\*\*" "$readme" \
    || { echo "::error::$readme: no table row for infrapi/$repo" >&2; exit 1; }
  sed -i -E "/^\|.*\*\*\[[^]]*\]\(https:\/\/github\.com\/infrapi\/$repo\)\*\*/ s/\`v[0-9][^\`]*\`/\`$tag\`/" "$readme"
  echo "  infrapi/$repo $tag"
done
