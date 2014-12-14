use admin;
db.createUser({
  user: "root",
  pwd: "{{ salt['pillar.get']('mongodb:auth') }}",
  roles: [ { role: "root", db: "admin" } ]
});