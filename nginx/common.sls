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
  {%- if salt['pillar.get']("nginx:load_balancer") %}
    - watch:
      - file: /etc/nginx/*
  {%- endif %}