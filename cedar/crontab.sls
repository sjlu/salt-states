crontab-reboot:
  file.managed:
    - name: /etc/cron.d/app
    - mode: 755
    - contents: | 
        @reboot app ". ~/.profile; ~/latest/deploy.sh"
