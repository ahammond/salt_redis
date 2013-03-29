{% set git = 'https://github.com/kumarnitin/RedisLive.git' %}
{% set dir = '/srv/RedisLive' %}
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

{% set monitor_init = '/etc/init/RedisLive_monitor.conf' %}
{{ monitor_init }}:
  file.managed:
    - source: salt://redis/files{{ monitor_init }}.sls
    - template: jinja
    - python: {{ virtualenv }}/bin/python
    - dir: {{ dir }}/src
    - duration: {{ duration }}

RedisLive_monitor:
  service.running:
    - enable: True
    - reload: True
    - require:
      - user: redislive
      - file: {{ monitor_init }}
      - virtualenv: {{ virtualenv }}
    - watch:
      - file: {{ conf }}
