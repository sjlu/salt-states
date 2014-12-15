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

## pillars

These are just some sample pillars that you're able ot use.

* saltmine.sls

        mine_functions:
          network.ip_addrs: [eth0]
          public_ip_addrs:
            mine_function: network.ip_addrs
            interface: eth0
          private_ip_addrs:
            mine_function: network.ip_addrs
            cidr: 10.32.0.0/16 # change this according to your local network cidr
            
* deploy.sls
      deploy:
        config:
          - ENV: production
        git: git@github.com:sjlu/salt-states.git
        branch: master
        target: /path/on/remote/server
        logs: /path/on/remote/server
        user: run_as_user
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

## notes

## license

MIT
