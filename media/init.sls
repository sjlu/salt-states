media-ssl-folder:
  file.directory:
    - name: /etc/apache2/ssl
    - user: root
    - group: root
    - mode: 700
    - require:
      - pkg: apache2

media-ssl-key:
  file.managed:
    - name: /etc/apache2/ssl.key
    - user: root
    - group: root
    - mode: 700
    - contents_pillar: media:ssl_key
    - require:
      - file: media-ssl-folder

media-ssl-cert:
  file.managed:
    - name: /etc/apache2/ssl.pem
    - user: root
    - group: root
    - mode: 600
    - contents_pillar: media:ssl_cert
    - require:
      - file: media-ssl-folder
