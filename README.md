## salt-states

Contains the salt states that I use to provision servers. It is designed to bootstrap servers based on their hostname and inject data using pillars.

The states provided are:
* nginx
  * sets up a load balancer
* mongodb
  * with replica set support
* nodejs
* deploys
  * supports git urls
  * can run post deploy hook
* papertrail
  * installs remote_syslog2
* redis

## getting started

* had to get salt installed

        apt-get install salt-master salt-cloud salt-api

### salt master

the salt master pretty much controls all the servers and what is
applied to them.

* configure salt-master `/etc/salt/master`
  * change the `interface` to an IP to bind to
  * look for `fileserver_backend` and enable `git`
  * enabled `gitfs_remotes` with `https://github.com/sjlu/salt-states`
  * added `pillar_roots` with `/srv/pillar`

* to apply your states run highstate

        salt '*' state.highstate

### salt cloud

the salt cloud helps provision minions. in my example I use digital ocean

* configure salt-cloud `/etc/salt/cloud`
  * appended

          provider: do
          minion:
            master: 0.0.0.0 # replace this with your IP

* created `/etc/salt/cloud.providers.d/digital_ocean.conf`

        do:
          provider: digital_ocean
          client_key: # https://cloud.digitalocean.com/api_access
          api_key: # https://cloud.digitalocean.com/api_access
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

          `salt-cloud --list-sizes do`
          `salt-cloud --list-images do`
          `salt-cloud --list-locations do`

* used saltmine pillar which mines the private ip addresses from the boxes `/srv/pillar/saltmine.sls`

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

* spun up an instance

        salt-cloud -p ny3-micro hostname

    * remember to set the hostname to a pattern that will bootstrap the server. for example 'mongodb01' will bootstrap that server with mongodb

### salt api

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

## pillars

These are just some sample pillars that you're able ot use.

* deploy.sls

        deploy:
          config:
            - ENV: production
          git: git@github.com:sjlu/salt-states.git
          branch: master
          target: /path/on/remote/server
          logs: /path/on/remote/server
          user: run_as_user
          cmd: 'post deploy cmd'
          ssh_key: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----

* nginx.sls

        nginx:
          load_balancer:
            glob: '*'
            port: 3000

* papertrail.sls

        papertrail:
          port: 13131 # the port to report to, something like logs.papertrail.com:13131

* mongodb.sls

        mongodb:
          replica:
            glob: '*' # glob that matches all your mongo nodes
            auth: 'changeme' # root password to your mongo instance
            key: |
              # generated ssl key
              # openssl rand -base64 741

* redis.sls

        redis:
          auth: # auth key

## notes

* because saltstack runs in parallel for servers, the mongodb slaves could build slower than the master. if that's the case, you'll see an error. all you need to do is re-run and the replica init file will run successfully.
* built on top of digital ocean in mind

## license

MIT
