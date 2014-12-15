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

        apt-get install salt-master saltcloud

* configure salt-master `/etc/salt/master`
  * change the `interface` to an IP to bind to
  * look for `fileserver_backend` and enable `git`
  * enabled `gitfs_remotes` with `https://github.com/sjlu/salt-states`
  * added `pillar_roots` with `/srv/pillar`

* configure salt-cloud `/etc/salt/cloud`
  * added `provider: do`
  * added `minion: master: IP`
  * added `/etc/salt/cloud.providers.d/digital_ocean.conf`

          do:
            provider: digital_ocean
            client_key: # https://cloud.digitalocean.com/api_access
            api_key: # https://cloud.digitalocean.com/api_access
            ssh_key_name: salt
            ssh_key_file: /root/.ssh/id_rsa

  * added `/etc/salt/cloud.profiles.d/digital_ocean.confg`

          ny3-micro:
            provider: do
            image: 14.04 x64
            size: 512MB
            location: New York 3
            private_networking: True

* used saltmine pillar which mines the private ip addresses from the boxes `/srv/pillar/saltmine.sls`

        mine_functions:
          network.ip_addrs: [eth0]
          public_ip_addrs:
            mine_function: network.ip_addrs
            interface: eth0
          private_ip_addrs:
            mine_function: network.ip_addrs
            cidr: 10.32.0.0/16 # change this according to your local network cidr

* added `/srv/pillar/top.sls`

        base:
          '*':
            - saltmine

* spun up an instance

        salt-cloud -p ny3-micro instance

* bootstrapped

        salt 'instance' state.highstate

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
