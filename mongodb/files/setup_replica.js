{%- set glob = salt['pillar.get']('mongodb:replica:glob') %}
var rsconf = {_id : "{{glob}}", members: [
  {%- set count = 0 %}
  {%- for server, addrs in salt['mine.get'](glob, 'public_ip_addrs', expr_form='glob').items() %}
    {
      _id: {{ count }},
      host: '{{ addrs[0] }}:27017',
    },
    {%- set count = count + 1 %}
  {%- endfor %}
]};

if (rs.status()['ok'] != 1) {
  rs.initiate(rsconf);
}

rs.reconfig(rsconf);