base:
  '*':
    - essential
    - iptables
    - ppa
    - fail2ban
    - git
    - papertrail
  '*[worker,web]*':
    - nodejs
    - deploy
  '*nginx*':
    - nginx
  '*mongodb*':
    - mongodb
  '*mongodb or *mongodb*1':
    - mongodb.auth.create
    - mongodb.auth
    - mongodb.replica
    - mongodb.replica.start
  '*mongodb*[2-99]':
    - mongodb.auth
    - mongodb.replica
  '*redis*':
    - redis
