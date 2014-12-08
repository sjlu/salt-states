base:
  '*':
    - fail2ban
    - iptables
    - git
    - ppa
  '*node*':
    - nodejs
    - deploy
  '*nginx*':
    - nginx
