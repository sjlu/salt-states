crontab-reboot:
  file.managed:
    - name: /etc/cron.d/app
    - mode: 755
    - contents: | 
        @reboot app ". ~/.profile; cd latest; bash deploy.sh"
