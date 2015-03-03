mysql_python:
  pkg.installed:
    - name: python-mysqldb

mysql:
  pkg.installed:
    - name: mysql-server
  service.running:
    - enable: True

{%- if salt['pillar.get']('mysql:db_name') %}
  mysql_database.present:
    - name: {{ salt['pillar.get']('mysql:db_name') }}
    - host: localhost
    - connection_user: root
    - connection_charset: utf8
{%- endif %}
