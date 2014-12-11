{%- if salt['pillar.get']('papertrail') %}
{%- if salt['pillar.get']('papertrail:port') %}
{%- set port = salt['pillar.get']('papertrail:port') %}
get_certs:
  pkg.installed:
    - name: rsyslog-gnutls
  file.managed:
    - name: /etc/papertrail-bundle.pem
    - source: https://papertrailapp.com/tools/papertrail-bundle.pem
    - soruce_hash: md5=c75ce425e553e416bde4e412439e3d09
setup_rsyslog:
  file.append:
    - name: /etc/rsyslog.conf
    - text: |
        $DefaultNetstreamDriverCAFile /etc/papertrail-bundle.pem
        $ActionSendStreamDriver gtls
        $ActionSendStreamDriverMode 1
        $ActionSendStreamDriverAuthMode x509/name
        $ActionSendStreamDriverPermittedPeer *.papertrailapp.com
        *.* @logs.papertrailapp.com:{{ port }}
  service:
    - name: rsyslog
    - running
    - restart: True
    - watch:
      - file: /etc/rsyslog.conf
{%- endif %}
{%- endif %}
