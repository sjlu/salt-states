### `/srv/salt/top.sls`

```
base:
  '*':
    - essential
    - iptables
    - ppa
    - fail2ban
    - git
    - papertrail
  'sunset':
    - nginx
    - nodejs
    - mysql
    - redis
    - deploy
```

### `/srv/pillar/top.sls`

```
base:
  '*':
    - saltmine
    - papertrail
  'sunset':
    - sunset
```

### `/srv/pillar/sunset.sls`

```
nginx:
  load_balancer:
    glob: 'sunset'
    port: 3000
mysql:
  db_name: sunset
deploy:
  git: git@github.com:sjlu/sunset.git
  branch: master
  target: /home/nodejs/sunset
  logs: /home/nodejs/sunset/log
  user: nodejs
  cmd: 'npm run deploy'
  ssh_key: |
    -----BEGIN RSA PRIVATE KEY-----
    -----END RSA PRIVATE KEY-----
  config:
    ENV: production
    MYSQL_URL: mysql://root@localhost:3306/sunset
    REDIS_URL: redis://localhost:6379
    SESSION_SECRET: sunset
```

### `/srv/reactor/deploy.sls`

```
{% set postdata = data.get('post', {}) %}

{% if postdata.repository.full_name == 'sjlu/sunset' %}
  {% set glob = 'sunset' %}
{% endif %}

{% if glob %}
run_deploy:
  local.state.highstate:
    - tgt: '{{ glob }}'
{% endif %}
```