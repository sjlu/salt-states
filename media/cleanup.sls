cleanup-movies:
  cron.present:
    - identifier: cleanup-movies
    - name: find /var/www/media/movies -maxdepth 1 -type d -mtime +730 -exec sh -c 'rm -rf "$1"' -- {} \;
    - user: www-data
    - minute: 0
    - hour: 4
    - dayweek: 4

