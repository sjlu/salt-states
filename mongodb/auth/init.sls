{%- if salt['pillar.get']('mongodb:auth') %}
mongodb_comment_out_local:
  file.comment:
    - name: /etc/mongod.conf
    - regex: ^bind_ip = 127\.0\.0\.1$
    - char: "#"
mongodb_add_all_ips:
  file.append:
    - name: /etc/mongod.conf
    - text: |
        bind_ip = 127.0.0.1{%- for ip in salt['network.ip_addrs']() %},{{ip}}{%- endfor %}
mongodb_set_auth:
  file.append:
    - name: /etc/mongod.conf
    - text: |
        auth=True
mongodb_auth_restart:
  cmd.run:
    - name: service mongod restart
{%- endif %}
