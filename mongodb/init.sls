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

mongodb:
  pkg.installed:
    - name: mongodb-org
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
