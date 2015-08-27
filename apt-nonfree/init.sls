linode-nonfree:
  file.replace:
    - name: /etc/apt/sources.list
    - pattern: jessie main
    - repl: jessie non-free main
