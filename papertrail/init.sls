{%- if salt['pillar.get']('papertrail') %}
{%- if salt['pillar.get']('papertrail.port') %}
{%- set port = salt['pillar.get']('papertrail.port') %}
setup_rsyslog:
  file.append:
    - name: /etc/rsyslog.conf
    - text: |
      *.* @logs.papertrailapp.com:{{ port }}
  service:
    - running
    - restart: True
    - watch:
      - file: /etc/rsyslog.conf
{%- endif %}
{%- endif %}
