{% set git = 'https://github.com/kumarnitin/RedisLive.git' %}
{% set dir = '/srv/RedisLive' %}
{% set conf = '{}/src/redis-live.conf'.format(dir) %}
{% set virtualenv = '/srv/virtualenv' %}
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
    - password: '*'
    - gid_from_name: True
