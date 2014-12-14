mongodb_setup_replica:
  file.managed:
    - name: /var/lib/mongodb/replica.js
    - source: salt://mongodb/files/replica.js
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  cmd.run:
    - name: mongo{%- if salt['pillar.get']('mongodb:auth') %} -u 'root' -p '{{salt['pillar.get']('mongodb:auth')}}'{%- endif %} /var/lib/mongodb/replica.js
    - require:
      - file: /var/lib/mongodb/replica.js