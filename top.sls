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
