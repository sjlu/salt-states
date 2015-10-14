nextbus:
  git.latest:
    - name: https://github.com/sjlu/nextbus-php.git
    - target: ~/nextbus
    - rev: master
    - submodules: true
    - require:
      - pkg: php-cli
      - pkg: php-curl
    - user: root

nextbus-import:
  file.managed:
    - name: ~/nextbus/import.py
    - source: salt://nextbus/files/import.py
    - user: root
    - group: root
    - mode: 644
    - template: jinja

nextbus-cron-predictions:
  cron.present:
    - identifier: predictions
    - name: python ~/nextbus/import.py -p > /dev/null 2>&1
    - user: root
    - minute: '*'

nextbus-cron-configuration:
  cron.present:
    - identifier: configuration
    - name: python ~/nextbus/import.py -c > /dev/null 2>&1
    - user: root
    - minute: '*'
