{%- if salt['pillar.get']('mongodb:replica') and salt['pillar.get']('mongodb:replica:key') and salt['pillar.get']('mongodb:replica:glob') %}
mongod:
  service:
    - running
    - restart: True
    - listen:
      - file: /etc/mongod.conf
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