{% set RedisLive_git = 'https://github.com/kumarnitin/RedisLive.git' %}
{% set RedisLive_dir = '/srv/RedisLive' %}
{% set RedisLive_virtualenv = '/srv/RedisLive_virtualenv' %}

{{ RedisLive_git }}:
  git.latest:
    - rev: master
    - target: {{ RedisLive_dir }}

{{ RedisLive_virtualenv }}:
  virtualenv.managed:
    - python: python2.7
    - requirements: {{ RedisLive_dir }}/requirements.txt
    - require:
      - git: {{ RedisLive_git }}

