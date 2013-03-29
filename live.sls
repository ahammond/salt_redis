{% set git = 'https://github.com/kumarnitin/RedisLive.git' %}
{% set dir = '/srv/RedisLive' %}
{% set web = '{}/src/redis-live.py'.format(dir) %}
{% set monitor = '{}/src/redis-monitor.py'.format(dir) %}
{% set conf = '{}/src/redis-live.conf'.format(dir) %}
{% set virtualenv = '/srv/RedisLive_virtualenv' %}
{% set duration = 120 %}

include:
  - python

git:
  pkg.installed

{{ git }}:
  git.latest:
    - rev: master
    - target: {{ dir }}
    - require:
      - pkg: git

{{ virtualenv }}:
  virtualenv.managed:
    - requirements: {{ dir }}/requirements.txt
    - require:
      - pkg: python-pip
      - pkg: python-virtualenv
      - git: {{ git }}

{{ web }}:
  file.sed:
    - before: /usr/bin/env python
    - after: {{ virtualenv }}/bin/python
    - limit: ^#!
    - requires:
      - git: {{ git }}

{{ monitor }}:
  file.sed:
    - before: /usr/bin/env python
    - after: {{ virtualenv }}/bin/python
    - limit: ^#!
    - requires:
      - git: {{ git }}

{{ conf }}:
  file.managed:
    - source: salt://redis/files{{ conf }}.jinja
    - template: jinja
    - require:
      - git: {{ git }}

redislive:
  user.present:
    - system: True
    - home: {{ dir }}
    - gid_from_name: True

{% set redis_monitor_init = '/etc/init/redis-monitor.conf' %}
{{ redis_monitor_init }}:
  file.managed:
    - source: salt://redis/files{{ redis_monitor_init }}.sls
    - template: jinja
    - dir: {{ dir }}/src
    - duration: {{ duration }}

redis-monitor:
  service.running:
    - enable: True
    - reload: True
    - require:
      - user: redislive
      - file: {{ monitor }}
      - file: {{ redis_monitor_init }}
      - virtualenv: {{ virtualenv }}
    - watch:
      - file: {{ conf }}

{% set redis_live_init = '/etc/init/redis-live.conf' %}
{{ redis_live_init }}:
  file.managed:
    - source: salt://redis/files{{ redis_live_init }}.sls
    - template: jinja
    - dir: {{ dir }}/src

redis-live:
  service.running:
    - enable: True
    - reload: True
    - require:
      - user: redislive
      - file: {{ web }}
      - file: {{ redis_live_init }}
      - virtualenv: {{ virtualenv }}
    - watch:
      - file: {{ conf }}
