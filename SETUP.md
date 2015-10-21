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
  mkdir /srv/runners
  ```

## Cloud Configuration

* appended to `/etc/salt/cloud`

  ```
  provider: do
  minion:
    master: 0.0.0.0 # change to master's IP
  ```

* created cloud provider

  `/etc/salt/cloud.providers.d/digital_ocean.conf`

  ```
  do:
    provider: digital_ocean
    client_key: xxx # replace with your key
    api_key: xxx # replace with your key
    ssh_key_name: salt
    ssh_key_file: /root/.ssh/id_rsa # make sure this key exists
  ```

  You can access your API key here: https://cloud.digitalocean.com/api_access

  `/etc/salt/cloud.providers.d/linode.conf`

  ```
  linode:
    provider: linode
    apikey:
    ssh_pubkey:
    ssh_key_file: /root/.ssh/id_rsa
    password:
  ```

* created a cloud profile

  `/etc/salt/cloud.profiles.d/digital_ocean.config`

  ```
  ny3-micro:
    provider: do
    image: 14.04 x64
    size: 512MB
    location: New York 3
    private_networking: True
  ```

  `/etc/salt/cloud.profiles.d/linode.config`

  ```
  1G:
  provider: linode
  image: Debian 8.1
  size: Linode 1024
  location: Newark, NJ, USA
  private_ip: True
  ```

  you can run the following to get config details

  ```
  salt-cloud --list-sizes
  salt-cloud --list-images
  salt-cloud --list-locations
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

* added `/srv/pillar/top.sls`

  ```
  base:
    '*':
      - saltmine
  ```

* spin up a minion

  ```
  salt-cloud -p ny3-micro hostname
  ```

## Reactor Configuration

I use the following configuration to handle GitHub webhooks so that I can deploy my projects with ease.

* created `/etc/salt/master.d/salt-api.conf`

  ```
  rest_cherrypy:
    port: 80
    host: 0.0.0.0
    disable_ssl: True
    webhook_disable_auth: True
    webhook_url: /hook
  ```

* created `/etc/salt/master.d/reactor.conf`

  ```
  reactor:
    - 'salt/netapi/hook/deploy/*':
      - /srv/reactor/deploy.sls
    - 'salt/job/*/ret/*':
      - /srv/reatcor/notify.sls
      
    runner_dirs:
      - /srv/runners
    
    state_output: changes
  ```

  `salt/netapi/hook` is a command reference that the reactor looks upon `/deploy` is the end
  of the webhook url. An example would be `https://0.0.0.0/hook/deploy` would reference it.

* created `/srv/reactor/deploy.sls`

  ```
  #!py        
            
  def run():
    body = data['body']
    target = tag.split('/')[-1]
    return {
      'webhook-deploy': {
        'local.state.highstate': [
          {'tgt': '{0}'.format(target)}                                                     
        ]   
      }       
    }    
  ```

* created `/srv/reactor/notify.sls`

  ```
  notify:
    runner.notify.email:
      - toaddr: my@email.com
      - data_str: {{ data | yaml_dquote }}
      - subject: "Salt Job Log: {{ data['jid'] }}"        
  ```
  
* created `/srv/runners/notify.py`

  ```
  import subprocess
  import salt.modules.smtp
          
  def email(toaddr, data_str, subject='Message from Salt'):
      data = eval(data_str)
      body = subprocess.check_output(["salt-run", "jobs.lookup_jid", data['jid']])
      salt.modules.smtp.send_msg(toaddr, body, subject=subject, server='smtp.mailgun.org', username='', password='')
      return True  
  ```
  
  * You can get your own mail account from mailgun.org, make sure you fill in the info

## Minion Configuration

* modified `/etc/salt/minion`

  ```
  master: 127.0.0.1
  ```

* modified `minion_id`

* ran commands to accept key into master

  ```
  salt-key -a minion_id
  ```
