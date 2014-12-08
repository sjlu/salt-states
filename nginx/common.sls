nginx.common:
  pkg.installed:
    - name: nginx
    - requires:
      - ppa
  service:
    - name: nginx
    - running
    - enable: True
    - reload: True
    - require:
      - pkg: nginx
    - watch:
      - file: /etc/nginx/*
