```
deploy:
  git: git@github.com:sjlu/sunset.git
  branch: master
  target: /home/nodejs/sunset
  logs: /home/nodejs/sunset/log
  user: nodejs
  cmd: 'npm run deploy'
  ssh_key: |
    -----BEGIN RSA PRIVATE KEY-----
    -----END RSA PRIVATE KEY-----
```