#!/usr/bin/env bash

set -e

RUN_UUID=$(cat /proc/sys/kernel/random/uuid)

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PIHOLE_BIN="${PIHOLE_BIN:-/usr/local/bin/pihole}"

ADLIST_LIST_DEST="${ADLIST_LIST_DEST:-/etc/pihole/adlists.list}"
WHITELIST_FILE="${WHITELIST_FILE:-whitelist_domains}"
ADLIST_LIST_ADDONS_FILE="${ADLIST_LIST_ADDONS_FILE:-adlists.list.addons}"
DRY_RUN="${DRY_RUN:-0}"

echo "*** Starting run $RUN_UUID ***"

# Whitelist domains
# We do one by one, because if we join a string of domains (space seperated) and
# there's an error in one of the lines in whitelist_domains the whole thing will fail.
# It should take long only on first run, after that it'll say that domain already exists.
echo "Reading whitelist domains from $WHITELIST_FILE"
while IFS= read -r line
do
  [[ "$line" =~ ^#.*$ ]] || [[ "$line" = "" ]] && continue
  [[ "$DRY_RUN" -eq "0" ]] && "$PIHOLE_BIN" -w "$line"
done < "$WHITELIST_FILE"


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
install -m 644 "$tmp_adlists_list" "$ADLIST_LIST_DEST"
rm "$tmp_adlists_list"

echo "Updating gravity"
[[ "$DRY_RUN" -eq "0" ]] && "$PIHOLE_BIN" -g

echo "*** Finished run $RUN_UUID ***"
