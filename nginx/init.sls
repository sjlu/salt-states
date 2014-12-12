include:
  - nginx.common
  {%- if salt['pillar.get']("nginx:load_balancer") %}
  - nginx.load_balancer
  {%- endif %}
  - nginx.logs
