base:
  '*':
    - iptables
    - ppa
    - fail2ban
    - git
    - papertrail
  '*node*':
    - nodejs
    - deploy
  '*nginx*':
    - nginx
  '*mongodb*':
    - mongodb
    - mongodb.replica
    - mongodb.auth
