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
  '*mongodb*01*':
    - mongodb.auth
    - mongodb.replica