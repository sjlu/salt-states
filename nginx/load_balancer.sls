nginx.load_balancer:
  file:
    - managed
    - name: /etc/nginx/sites-available/default
    - source: salt://nginx/files/load_balancer.conf
    - template: jinja
    - require:
      - pkg: nginx
