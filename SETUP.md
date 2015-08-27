# Setup

This describes the setup process I took to install a working Salt setup. I'll assume that
you're using Debian 8.1, like I am.

## Master Configuration

* changed the following lines in `/etc/salt/master`

```
interface: 0.0.0.0

pillar_roots:
  base:
    - /srv/pillar

fileserver_backend:
  - roots

file_roots:
  base:
    - /srv/salt/
    - /home/sjlu/salt-states
```

* created the following directory structure

```
mkdir /srv
mkdir /srv/pillar
mkdir /srv/reactor
mkdir /srv/salt
```

## Cloud Configuration


* appended to `/etc/salt/cloud`

```
provider: do
minion:
  master: 0.0.0.0 # change to master's IP
```

* created `/etc/salt/cloud.providers.d/digital_ocean.conf`

```
do:
  provider: digital_ocean
  client_key: xxx # replace with your key
  api_key: xxx # replace with your key
  ssh_key_name: salt
  ssh_key_file: /root/.ssh/id_rsa # make sure this key exists
```

  * Get your keys here: https://cloud.digitalocean.com/api_access

* created `/etc/salt/cloud.profiles.d/digital_ocean.config`

```
ny3-micro:
  provider: do
  image: 14.04 x64
  size: 512MB
  location: New York 3
  private_networking: True
```

    * you can run the following to get config details

    ```
    salt-cloud --list-sizes do
    salt-cloud --list-images do
    salt-cloud --list-locations do
    ```

* edit `/srv/pillar/saltmine.sls`

```
mine_functions:
  network.ip_addrs: [eth0]
  public_ip_addrs:
    mine_function: network.ip_addrs
    interface: eth0
  private_ip_addrs:
    mine_function: network.ip_addrs
    cidr: 10.32.0.0/16 # change this according to your local network cidr
```

  * the cidr `/16` references that the first 16 bits are static while the rest are ignored (the `.0.0` part)
  while `/32` would mean the entire IP matters

* added `/srv/pillar/top.sls`

        base:
          '*':
            - saltmine

* spin up a minion

        salt-cloud -p ny3-micro hostname