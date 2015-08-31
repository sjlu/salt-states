install_apcupsd:
  pkg.installed:
    - pkgs:
      - apcupsd

configure_apcupsd-1:
  file.replace:
    - name: /etc/apcupsd/apcupsd.conf
    - pattern: UPSCABLE smart
    - repl: UPSCABLE usb

configure_apcupsd-2:
  file.replace:
    - name: /etc/apcupsd/apcupsd.conf
    - pattern: UPSTYPE smart
    - repl: UPSTYPE usb

configure_apcupsd-3:
  file.comment:
    - name: /etc/apcupsd/apcupsd.conf
    - regex: ^DEVICE .*

configure_apcupsd-4:
  file.replace:
    - name: /etc/apcupsd/apcupsd.conf
    - pattern: #UPSNAME
    - repl: UPSNAME myups

configure_apcupsd-5:
  file.replace:
    - name: /etc/default/apcupsd
    - pattern: ISCONFIGURED=no
    - repl: ISCONFIGURED=yes

apcupsd_restart:
  cmd.run:
    - name: /etc/init.d/apcupsd restart
    - onchanges:
      - file: /etc/apcupsd/apcupsd.conf
      - file: /etc/default/apcupsd

