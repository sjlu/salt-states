{% if salt['pillar.get']('media:mount') %}
{{ salt['pillar.get']('media:mount:target') }}:
  mount.mounted:
    - device: {{ salt['pillar.get']('media:mount:device') }}
    - fstype: ext4
    - mkmnt: True
    - opts:
      - defaults

{{ salt['pillar.get']('media:mount:target') }}-symlink:
  file.symlink:
    - name: /var/www/media
    - target: /mnt/raid/media
    - user: www-data
{% endif %}
