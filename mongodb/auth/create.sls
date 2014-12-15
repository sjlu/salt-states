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
  mongodb_user.present:
    - name: root
    - passwd: {{ password }}
    - database: admin
    - host: localhost
    - port: 27017
    - require:
      - pip: pymongo
{%- endif %}
