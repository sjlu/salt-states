iptables:
  require:
    - pkg: iptables
    - iptables: iptables.allow_salt_ssh
    - iptables: iptables.disallow_global_ssh

iptables.allow_salt_ssh:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - source: {{ salt['pillar.get']('master:interface') }}
    - dport: ssh
    - proto: tcp
    - save: True

iptables.disallow_global_ssh:
  iptables.append:
    - position: last
    - table: filter
    - chain: INPUT
    - jump: REJECT
    - dport: ssh
    - proto: tcp
    - save: True
