{%- if salt['pillar.get']('deploy') %}
{%- if salt['pillar.get']('deploy:git') %}
{%- if salt['pillar.get']('deploy:ssh_key') %}
{%- set target = salt['pillar.get']('deploy:target', '') %}
ssh_key:
  file.managed:
    - name: /root/.ssh/id_rsa
    - contents_pillar: deploy:ssh_key
    - mode: 400
    - require_in:
      - deploy
{%- endif %}
target_dir:
  file.directory:
    - name: {{ target }}
deploy:
  require:
    - pkg: git
  git:
    - latest
    - name: {{ salt['pillar.get']('deploy:git', '') }}
    - rev: {{ salt['pillar.get']('deploy:branch', 'master') }}
  {%- if salt['pillar.get']('deploy:ssh_key') %}
    - identity: /root/.ssh/id_rsa
  {%- endif %}
    - target: {{ target }}
{% if salt['pillar.get']('deploy:cmd') %}
  cmd.run:
    - name: {{ salt['pillar.get']('deploy:cmd') }}
    - cwd: {{ target }}
{%- endif %}
{%- endif %}
{%- endif %}
