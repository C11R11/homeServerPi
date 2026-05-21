---
- hosts: all
  gather_facts: no
  tasks:
    - name: Ensure targeted directory layout exists
      file:
        path: /home/cristian/music-stack
        state: directory

    - name: Securely copy current Compose blueprint to server
      copy:
        src: ./docker-compose.yml
        dest: /home/cristian/music-stack/docker-compose.yml

    - name: Declaratively bring stack up to matching specification
      community.docker.docker_compose_v2:
        project_src: /home/cristian/music-stack
        state: present
        pull: always