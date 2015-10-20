{% if salt['pillar.get']('cedar:deploy') %}
cedar-git-deploy:
  git.latest:
    - name: {{ salt['pillar.get']('cedar:deploy:git') }}
    - target: /home/app/codebase
    - rev: master
    - submodules: true
    - user: app
    - identity: /home/app/.ssh/id_rsa

cedar-restart:
  cmd.wait:
    - name: . ~/.profile; bash deploy.sh
    - cwd: /home/app/codebase
    - user: app
    - watch:
      - git: cedar-git-deploy
{% endif %}
