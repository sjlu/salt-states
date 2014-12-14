{%- if salt['pillar.get']('mongodb:replica') and salt['pillar.get']('mongodb:replica:key') and salt['pillar.get']('mongodb:replica:glob') %}
mongodb_start_replica:
  file.managed:
    - name: /var/lib/mongodb/replica.js
    - source: salt://mongodb/files/replica.js
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  cmd.run:
    - name: mongo{%- if salt['pillar.get']('mongodb:auth') %} admin -u 'root' -p '{{salt['pillar.get']('mongodb:auth')}}'{%- endif %} /var/lib/mongodb/replica.js
    - require:
      - file: /var/lib/mongodb/replica.js
{%- endif %}