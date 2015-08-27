media-ssl-folder:
  file.directory:
    - name: /etc/apache2/ssl
    - user: root
    - group: root
    - mode: 700
    - require:
      - pkg: apache2

media-apache-ssl:
  apache_module.enable:
    - name: ssl

media-ssl-key:
  file.managed:
    - name: /etc/apache2/ssl/default.key
    - user: root
    - group: root
    - mode: 700
    - contents_pillar: media:ssl_key
    - require:
      - file: media-ssl-folder

media-ssl-cert:
  file.managed:
    - name: /etc/apache2/ssl/default.pem
    - user: root
    - group: root
    - mode: 600
    - contents_pillar: media:ssl_cert
    - require:
      - file: media-ssl-folder

media-http-basic-auth:
  file.managed:
    - name: /var/www/.htpasswd
    - user: www-data
    - group: www-data
    - mode: 644
    - contents_pillar: media:http_auth

media-apache-site:
  file.managed:
    - name: /etc/apache2/sites-available/000-default.conf
    - source: salt://media/files/default.conf
    - user: root
    - group: root
    - mode: 644

media-apache-restart:
  cmd.run:
    - name: service apache2 reload
    - onchanges:
      - file: media-apache-site
