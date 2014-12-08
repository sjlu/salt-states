nodejs:
  pkg.installed:
    - name: nodejs
    - version: 0.10.33-1chl1~precise1
    - requires:
      - ppa
  user.present:
    - name: nodejs
    - shell: /bin/bash
    - home: /home/nodejs