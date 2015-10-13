deployable:
  git.latest:
    - name: https://github.com/abacuslabs/deployable
    - require:
      - pkg: git
    - rev: {{ salt['pillar.get']('deployable:version', 'master') }}
    - submodules: true
    - target: /home/{{ salt['pillar.get']('deployable:user', 'root') }}/deployable
    - user: {{ salt['pillar.get']('deployable:user', 'root') }}
  cmd.wait:
    - name: ./deploy.sh
    - cwd: /home/{{ salt['pillar.get']('deployable:user', 'root') }}/deployable
    - watch:
      - git: deployable
    - user: {{ salt['pillar.get']('deployable:user', 'root') }}

deployable_config:
  file.managed:
    - name: /home/{{ salt['pillar.get']('deployable:user', 'root') }}/deployable/.env
    - source: salt://deployable/files/env
    - user: {{ salt['pillar.get']('deployable:user', 'root') }}
    - group: {{ salt['pillar.get']('deployable:user', 'root') }}
    - template: jinja

deployable_repos:
  file.serialize:
    - name: /home/{{ salt['pillar.get']('deployable:user', 'root') }}/deployable/config/repos.json
    - dataset_pillar: deployable:repos
    - user: {{ salt['pillar.get']('deployable:user', 'root') }}
    - group: {{ salt['pillar.get']('deployable:user', 'root') }}
    - formatter: json

deployable_restart:
  cmd.wait:
    - name: pm2 restart all
    - user: {{ salt['pillar.get']('deployable:user', 'root') }}
    - watch:
      - file: deployable_config
      - file: deployable_repos
