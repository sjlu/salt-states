## salt-states

These are some salt states that I use to bootstrap servers and are stateful from your
pillar data. I assume that all your servers use Ubuntu.

All servers get installed with:
* build-essential
* fail2ban
* git

Some of the stateful states are:
* nginx
  * sets up a load balancer
* mongodb
  * with replica set support
* mysql
  * localhost only
* nodejs
* deploys
  * from git urls
  * post deploy commands
  * post deploy hooks
  * configuration variables
* papertrail
  * installs remote_syslog2
* redis

## how this all works

Salt has a master and a minion. For right now, I only use a single master. The master is what
contains all your states and pillars. When you tell the master to keep its nodes up to date, it
will execute commands on your minions based on your configuration. These salt states tell your
master how to keep things up to date, they are basically your recipes. Your pillars are what
you'll actually touch to configure certain parts of those states.

### first things first

* had to get salt installed

        apt-get install salt-master salt-cloud salt-api

### configuring your master

the salt master pretty much controls all the servers and what is
applied to them.

* changed the following lines in `/etc/salt/master`

        interface: 0.0.0.0

        pillar_roots:
          base:
            - /srv/pillar

        gitfs_remotes:
          - https://github.com/sjlu/salt-states

        fileserver_backend:
          - roots
          - git

        file_roots:
          base:
            - /srv/salt/

* created the following directory structure

        mkdir /srv
        mkdir /srv/pillar
        mkdir /srv/reactor
        mkdir /srv/salt

### configuring master to auto-provision servers

* appended to `/etc/salt/cloud`

        provider: do
        minion:
          master: 0.0.0.0 # replace this with your instance's public IP address

* created `/etc/salt/cloud.providers.d/digital_ocean.conf`

        do:
          provider: digital_ocean
          client_key: xxx # replace with https://cloud.digitalocean.com/api_access
          api_key: xxx # replace with https://cloud.digitalocean.com/api_access
          ssh_key_name: salt
          ssh_key_file: /root/.ssh/id_rsa

* created `/etc/salt/cloud.profiles.d/digital_ocean.config`

        ny3-micro:
          provider: do
          image: 14.04 x64
          size: 512MB
          location: New York 3
          private_networking: True

  * you can run the following to get config details

          salt-cloud --list-sizes do
          salt-cloud --list-images do
          salt-cloud --list-locations do

* edit `/srv/pillar/saltmine.sls`

        mine_functions:
          network.ip_addrs: [eth0]
          public_ip_addrs:
            mine_function: network.ip_addrs
            interface: eth0
          private_ip_addrs:
            mine_function: network.ip_addrs
            cidr: 10.32.0.0/16 # change this according to your local network cidr

  * the cidr `/16` references that the first 16 bits are static while the rest are ignored (the `.0.0` part)
  while `/32` would mean the entire IP matters

* added `/srv/pillar/top.sls`

        base:
          '*':
            - saltmine

* spin up a minion

        salt-cloud -p ny3-micro hostname

### configuring salt-api to accept post hooks

* created `/etc/salt/master.d/salt-api.conf`

        rest_cherrypy:
          port: 443
          host: 0.0.0.0
          ssl_crt: /etc/ssl/private/cert.pem
          ssl_key: /etc/ssl/private/key.pem
          webhook_disable_auth: True
          webhook_url: /hook

* needed to create self signed keys

        openssl genrsa -out /etc/ssl/private/key.pem 4096
        openssl req -new -x509 -key /etc/ssl/private/key.pem -out /etc/ssl/private/cert.pem -days 1826

* created `/etc/salt/master.d/reactor.conf`

        reactor:
          - 'salt/netapi/hook/deploy':
            - /srv/reactor/deploy.sls

  * `salt/netapi/hook` is a command reference that the reactor looks upon `/deploy` is the end
  of the webhook url. An example would be `https://0.0.0.0/hook/deploy` would reference it.

* created `/etc/reactor/deploy.sls`

        {% set postdata = data.get('post', {}) %}

        {% if postdata.repository.full_name == 'sjlu/salt-state' %}
          {% set glob = 'salt*' %}
        {% endif %}

        {% if glob %}
        run_deploy:
          local.state.highstate:
            - tgt: '{{ glob }}'
        {% endif %}

  * this will run `state.highstate` on all minions that match that glob

* stolen from [Benjamin Cane](http://bencane.com/2014/07/17/integrating-saltstack-with-other-services-via-salt-api/)

### configuring your pillars and states

This is the part where you'll configure `/srv/salt/top.sls` and `/srv/pillar/top.sls` so that
your master knows what to bootstrap your servers with.

Each and every directory in this repository has it's own README to show you how
you can configure your pillars accordingly.

Here's an [example](EXAMPLE.md) I use to bootstrap a server to deploy code from one of my
Node projects.

## notes

* because saltstack runs in parallel for servers, the mongodb slaves could build slower than the master.
if that's the case, you'll see an error. all you need to do is re-run and the replica init file
will run successfully.
* built on top of digital ocean in mind
* mysql state needs some love

## license

MIT
