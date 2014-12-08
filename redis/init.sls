redis:
  pkg.installed:
    - name: redis-server
  service:
    - name: redis-server
    - running
