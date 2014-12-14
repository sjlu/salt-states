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

mongod:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/mongod.conf