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
{%- set password = salt['pillar.get']('mongodb:auth') %}
mongodb_create_user:
  cmd.run:
    - name: mongo --eval 'db.createUser({user:"root",pwd:"{{password}}",roles:[{role:"root",db:"admin"}]});' admin
    - unless: mongo --eval 'db.system.users.find({user:"root"}).count()' admin
mongodb_set_auth:
  file.append:
    - name: /etc/mongod.conf
    - text: |
        auth=True
mongodb_comment_out_local:
  file.comment:
    - name: /etc/mongod.conf
    - regex: ^bind_ip[\s=]*127\.0\.0\.1
    - char: #
mongodb_add_all_ips:
  file.append:
    - name: /etc/mongod.conf
    - text: |
        bind_ip = 127.0.0.1{%- for ip in salt['network.ip_addrs']() %},{{ip}}{%- endfor %}
{%- endif %}

{%- if salt['pillar.get']('mongodb:replica') and salt['pillar.get']('mongodb:replica:key') and salt['pillar.get']('mongodb:replica:glob') %}
mongodb_keyfile:
  file.managed:
    - name: /var/lib/mongodb/keyfile
    - contents_pillar: mongodb:replica:key
    - mode: 0600
    - user: mongodb
    - group: mongodb
mongodb_replica_config:
  file.append:
    - name: /etc/mongod.conf
    - text: |
        replSet=rs0
        keyFile=/var/lib/mongodb/keyfile
mongodb_setup_replica:
  file.managed:
    - name: /var/lib/mongodb/replica.js
    - source: salt://mongodb/files/replica.js
    - user: root
    - group: root
    - mode: 644
    - template: jinja
{%- endif %}

mongod:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/mongod.conf