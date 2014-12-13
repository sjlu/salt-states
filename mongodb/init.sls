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

{%- if salt['pillar.get']('mongodb:replica') and salt['pillar.get']('mongodb:replica:key') and salt['pillar.get']('mongodb:replica:glob') %}
mongodb_keyfile:
  file.managed:
    - name: /var/lib/mongodb/keyfile
    - contents_pillar: mongodb:replica:key
    - mode: 0600

mongodb_setup_replica:
  file.managed:
    - name: /var/lib/mongodb/setup_replica.js
    - source: salt://mongodb/files/setup_replica.js
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  cmd.run:
    - name: mongo /var/lib/mongodb/setup_replica.js
    - require:
      - file: /var/lib/mongodb/setup_replica.js
{%- endif %}

mongodb_service:
  file:
    - managed
    - name: /etc/mongod.conf
    - source: salt://mongodb/files/mongod.conf
    - template: jinja
  service:
    - name: mongod
    - running
    - restart: True
    - watch:
      - file: /etc/mongod.conf
