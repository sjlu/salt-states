```
mongodb:
  replica:
    glob: '*' # glob that matches all your mongo nodes
    auth: 'changeme' # root password to your mongo instance
    key: |
      # generated ssl key
      # openssl rand -base64 741
```