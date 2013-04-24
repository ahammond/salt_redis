{% set git = 'https://github.com/kumarnitin/RedisLive.git' %}
{% set dir = '/srv/RedisLive' %}
{% set sqlite = '{}/src/db'.format(dir) %}
{% set web = '{}/src/redis-live.py'.format(dir) %}
{% set monitor = '{}/src/redis-monitor.py'.format(dir) %}
{% set conf = '{}/src/redis-live.conf'.format(dir) %}
{% set virtualenv = '/srv/RedisLive_virtualenv' %}
{% set duration = 120 %}

git:
  pkg.installed

basic_python_packages:
  pkg.installed:
    - pkgs:
      - python-pip
      - python-virtualenv

{{ git }}:
  git.latest:
    - rev: master
    - target: {{ dir }}
    - require:
      - pkg: git

{{ sqlite }}:
  file.directory:
    - user: redislive
    - group: redislive
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
    - require:
      - git: {{ git }}
      - user: redislive

{{ virtualenv }}:
  virtualenv.managed:
    - requirements: {{ dir }}/requirements.txt
    - require:
      - pkg: basic_python_packages
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
    - requires:
        - git: {{ git }}  {# arguably less dirty than having git --force #}

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

cd /srv/RedisLive/src; ./redis-monitor.py --duration={{ duration }}:
  cron.present:
    - user: redislive
    - minute: '*/15'
    - require:
      - user: redislive
      - file: {{ sqlite }}
      - file: {{ monitor }}
      - virtualenv: {{ virtualenv }}
