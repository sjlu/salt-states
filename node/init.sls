download-node:
  archive.extracted:
    - source: https://nodejs.org/dist/v{{ salt['pillar.get']('node:version', '4.1.2') }}/node-v{{ salt['pillar.get']('node:version', '4.1.2') }}-linux-x64.tar.gz
    - source_hash: sha256={{ salt['pillar.get']('node:sha256', 'c39aefac81a2a4b0ae12df495e7dcdf6a8b75cbfe3a6efb649c8a4daa3aebdb6') }}
    - name: /opt/node
    - archive_format: tar
    - tar_options: --strip 1

symlink-node:
  file.symlink:
    - name: /usr/local/bin/node
    - target: /opt/node/bin/node

symlink-npm:
  file.symlink:
    - name: /usr/local/bin/npm
    - target: /opt/node/bin/npm
    
