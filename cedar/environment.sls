profile-env:
  file.blockreplace:
    - name: /home/app/.profile
    - marker_start: '# start managed env'
    - marker_end: '# end managed env'
    - append_if_not_found: True
    {% if salt['pillar.get']('cedar:environment') %}
    - content: |
    {%- for key,val in salt['pillar.get']('cedar:environment').iteritems() %}
        export {{key}}={{val}}
    {%- endfor %}
    {% endif %}
