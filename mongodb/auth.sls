{%- if salt['pillar.get']('mongodb:auth') %}
mongodb_create_user:
  mongodb_user.present:
    - name: 'root'
    - passwd: {{salt['pillar.get']('mongodb:auth')}}
mongodb_set_auth:
  file.append:
    - name: /etc/mongod.conf
    - text: |
        auth=True
mongodb_bind_all:
  file.comment:
    - name: /etc/mongod.conf
    - regex: ^bind 127.0.0.1
    - char: #
{%- endif %}