create_log_dir:
  file.directory:
    - name: /logs
    - user: root
    - group: root
    - mode: 777
{%- if salt['pillar.get']('papertrail') %}
{%- if salt['pillar.get']('papertrail:port') %}
{%- set port = salt['pillar.get']('papertrail:port') %}
get_certs:
  pkg.installed:
    - name: rsyslog-gnutls
  file.managed:
    - name: /etc/papertrail-bundle.pem
    - source: https://papertrailapp.com/tools/papertrail-bundle.pem
    - source_hash: md5=c75ce425e553e416bde4e412439e3d09
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
add_remote_syslog_config:
  file.append:
    - name: /etc/log_files.yml
    - text: |
        destination:
          host: logs.papertrailapp.com
          port: {{ port }}
          protocol: tls
        files:
          - /logs/*
setup_remote_syslog:
  archive:
    - extracted
    - name: /etc/
    - source: https://github.com/papertrail/remote_syslog2/releases/download/v0.13/remote_syslog_linux_amd64.tar.gz
    - source_hash: md5=e08f03664bb097cb91c96dd2d4e0f041
    - archive_format: tar
    - tar_options: x
    - if_missing: /etc/remote_syslog/
  file.symlink:
    - name: /usr/local/bin/remote_syslog
    - target: /etc/remote_syslog/remote_syslog
remote_syslog_initd:
  file.managed:
    - name: /etc/init.d/remote_syslog
    - source: https://raw.githubusercontent.com/papertrail/remote_syslog2/master/examples/remote_syslog.init.d
    - source_hash: md5=8ebe6a3cf984a1440429aec17e6cd4b5
    - mode: 0755
    - user: root
    - group: root
  service:
    - name: remote_syslog
    - enable: True
    - running
    - restart: True
    - watch:
      - file: /etc/log_files.yml
{%- endif %}
{%- endif %}
