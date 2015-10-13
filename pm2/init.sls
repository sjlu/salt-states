pm2:
  npm.installed

pm2-startup:
  cmd.run:
    - name: pm2 startup ubuntu -u {{ salt['pillar.get']('pm2:user', 'root') }}
    - onlyif: 
      - file.missing: /etc/init.d/pm2-init.sh
    - user: root
