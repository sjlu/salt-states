{%- if salt['pillar.get']('deploy') %}
{%- if salt['pillar.get']('deploy:git') %}
{%- if salt['pillar.get']('deploy:ssh_key') %}
{%- set target = salt['pillar.get']('deploy:target', '') %}
{%- set key_path = '/root' %}
{%- if salt['pillar.get']('deploy:user') %}
  {%- set key_path = '/home/' + salt['pillar.get']('deploy:user') %}
{%- endif %}
ssh_key:
  file.managed:
    - name: {{key_path}}/.ssh/id_rsa
    - contents_pillar: deploy:ssh_key
    - mode: 400
  {%- if salt['pillar.get']('deploy:user') %}
    - user: {{ salt['pillar.get']('deploy:user') }}
    - group: {{ salt['pillar.get']('deploy:user') }}
  {%- endif %}
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
    - identity: {{key_path}}/.ssh/id_rsa
  {%- endif %}
    - target: {{ target }}
  {%- if salt['pillar.get']('deploy:user') %}
    - user: {{ salt['pillar.get']('deploy:user') }}
  {%- endif %}
{% if salt['pillar.get']('deploy:cmd') %}
  cmd.run:
    - name: {{ salt['pillar.get']('deploy:cmd') }}
    - cwd: {{ target }}
{%- endif %}
{%- endif %}
{%- endif %}