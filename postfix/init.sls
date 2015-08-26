postfix:
  pkg:
    - installed
  service.running:
    - enable: True

postfix_virtual_config_block:
  file.blockreplace:
    - name: /etc/postfix/main.cf
    - marker_start: '# START: managed virtual aliases block
    - marker_end: '# END: managed virtual aliases block'
    - append_if_not_found: True
    - show_changes: True

virtual_config:
  file.accumulated:
    - filename: /etc/postfix/main.cf
    - name: accumulated-aliases
    - text: |
        virtual_alias_domains = hash:/etc/postfix/domains
        virtual_alias_maps = hash:/etc/postfix/virtual
    - require_in:
      - file: postfix_virtual_config_block

/etc/postfix/virtual:
  file.managed:
    - source: salt://postfix/files/virtual
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/postfix/domains:
  file.managed:
    - source: salt://postfix/files/domains
    - template: jinja
    - user: root
    - group: root
    - mode: 644

reload_domains:
  cmd.run:
    - name: postmap /etc/postfix/domains; postfix reload
    - onchanges:
      - file: /etc/postfix/domains

reload_virtual:
  cmd.run:
    - name: postmap /etc/postfix/virtual; postfix reload
    - onchanges:
      - file: /etc/postfix/virtual

reload_postfix:
  cmd.run:
    - name: postfix reload
    - onchanges:
      - file: postfix_virtual_config_block
