{% set RedisLive_git = 'https://github.com/kumarnitin/RedisLive.git' %}
{% set RedisLive_dir = '/srv/RedisLive' %}
{% set RedisLive_conf = '{}/src/redis-live.conf'.format(RedisLive_dir) %}
{% set RedisLive_virtualenv = '/srv/RedisLive_virtualenv' %}

include:
  - python

git:
  pkg.installed

{{ RedisLive_git }}:
  git.latest:
    - rev: master
    - target: {{ RedisLive_dir }}
    - require:
      - pkg: git

{{ RedisLive_virtualenv }}:
  virtualenv.managed:
    - requirements: {{ RedisLive_dir }}/requirements.txt
    - require:
      - pkg: python-pip
      - pkg: python-virtualenv
      - git: {{ RedisLive_git }}

{{ RedisLive_conf }}:
  file.managed:
    - source: salt://files/{{ RedisLive_conf }}.jinja
    - template: jinja

