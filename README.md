# Pihole config

This is my personal configuration, including:

  * [WALLY3K'S big blocklist collection](https://firebog.net/) - I'm using the [non-crossed list](https://v.firebog.net/hosts/lists.php?type=nocross)
  * [Whitelist](https://github.com/amitizle/pihole_config/blob/master/whitelist_domains) - originally taken from [here](https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212) with a few addition of my own.

I'm running [pi-hole](https://pi-hole.net/) on a Raspberry Pi 3 Model B+ and a [Mikrotik hAP ac](https://mikrotik.com/product/RB962UiGS-5HacT2HnT), setting pi-hole as the upstream DNS provider for the Mikrotik.

I've setup the [pihole_conf.sh](https://github.com/amitizle/pihole_config/blob/master/pihole_conf.sh) script to be running every hour as a cronjob.

## Setup cron

This is just a personal preference, it's way easier for me rather than setup some redundant bootstrapping tool, thus involve manual steps.
I'm also assuming that all permissions (i.e. to `/var/log`) already setup the way you like to.

  1. Clone the repo, assuming to `/opt/pihole_config`: `git clone https://github.com/amitizle/pihole_config.git opt/pihole_config`.
  2. Setup the cronjob (using `crontab -e`): `0 */1 * * * bash -c "cd /opt/pihole_config && git pull && ./pihole_conf.sh &>> /var/log/pihole_config.log"`

## Caveats

The [Whitelist file](https://github.com/amitizle/pihole_config/blob/master/whitelist_domains) is parsed at the moment with the following rules:

  * Every line starts with `#` is treated as a comment.
  * Empty lines are ignored.
  * Every line can only contain **one domain**.
