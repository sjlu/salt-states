mongodb.10gen:
  pkgrepo.managed:
    - humanname: mongodb 10gen
    - name: deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
    - dist: dist
    - file: /etc/apt/sources.list.d/mongodb.list
    - keyid: "7F0CEB10"
    - keyserver: keyserver.ubuntu.com
    - require_in:
      pkg: mongodb
mongodb_pkg:
  pkg.installed:
    - name: mongodb-org
mongodb_log:
  file.symlink:
    - name: /logs/mongod.log
    - target: /var/log/mongodb/mongod.log

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
{%- endif %}

mongod:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/mongod.conf