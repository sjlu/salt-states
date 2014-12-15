{%- if salt['pillar.get']('mongodb:auth') %}
{%- set password = salt['pillar.get']('mongodb:auth') %}
python_pip:
  pkg.installed:
   - name: python-pip

pymongo_package:
  pip.installed:
    - name: pymongo
    - require:
      - pkg: python_pip

mongodb_create_user:
#   mongodb_user.present:
#     - name: root
#     - passwd: {{ password }}
#     - database: admin
#     - host: localhost
#     - port: 27017
#     - require:
#       - pip: pymongo
  cmd.run:
    - name: mongo admin --eval 'db.createUser({user:"root",pwd:"{{ password }}",roles:["root"]})'
    - unless: grep -Fxq 'auth=True' /etc/mongod.conf
{%- endif %}
