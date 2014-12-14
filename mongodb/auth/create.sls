{%- if salt['pillar.get']('mongodb:auth') %}
{%- set password = salt['pillar.get']('mongodb:auth') %}
mongodb_create_user:
  cmd.run:
    - name: mongo --eval 'db.createUser({user:"root",pwd:"{{password}}",roles:[{role:"root",db:"admin"}]});' admin
    - unless: mongo --eval 'db.system.users.find({user:"root"}).count()' admin
{%- endif %}
