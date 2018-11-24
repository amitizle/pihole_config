#!/usr/bin/env bash

set -e

PIHOLE_BIN="${PIHOLE_BIN:-/usr/local/bin/pihole}"

ADLIST_LIST_DEST="${ADLIST_LIST_DEST:-/etc/pihole/adlists.list}"
WHITELIST_FILE="${WHITELIST_FILE:-whitelist_domains}"
ADLIST_LIST_ADDONS_FILE="${ADLIST_LIST_ADDONS_FILE:-adlists.list.addons}"
DRY_RUN="${DRY_RUN:-0}"

# Whitelist domains
echo "Reading whitelist domains from $WHITELIST_FILE"
all_domains=""
while IFS= read -r line
do
  [[ "$line" =~ ^#.*$ ]] || [[ "$line" = "" ]] && continue
  all_domains="${all_domains} ${line}"
done < "$WHITELIST_FILE"

echo "Adding whitelist domains"
[[ "$DRY_RUN" -eq "0" ]] && $PIHOLE_BIN -w "$all_domains"

tmp_adlists_list=$(mktemp)

# Get the updated adlists.list and update pihole
curl -sL "https://v.firebog.net/hosts/lists.php?type=nocross" -o "$tmp_adlists_list"

# Add the lists from the addons

echo "Reading additional adlists from $ADLIST_LIST_ADDONS_FILE"
while IFS= read -r line
do
  [[ "$line" =~ ^#.*$ ]] || [[ "$line" = "" ]] && continue
  echo "$line" >> "$tmp_adlists_list"
done < "$ADLIST_LIST_ADDONS_FILE"

echo "Replacing $ADLIST_LIST_DEST with a new adlist.list file"
mv "$tmp_adlists_list" "$ADLIST_LIST_DEST"

echo "Updating gravity"
[[ "$DRY_RUN" -eq "0" ]] && $PIHOLE_BIN -g
