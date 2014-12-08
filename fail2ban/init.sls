fail2ban:
  pkg.installed:
    - name: fail2ban
  service:
    - running
    - require:
      - pkg: fail2ban
