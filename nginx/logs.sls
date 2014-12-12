nginx_log:
  file.append:
    - name: /etc/log_files.yml
    - text: |
        - /var/log/nginx/error.log
    - require:
      - test -f /testfile
