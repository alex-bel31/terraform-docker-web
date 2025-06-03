#cloud-config
package_update: true
package_upgrade: true
packages:
  - curl
  - git
  - jq

users:
  - name: ${username}
    groups: [sudo, docker]
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    lock_passwd: false
    ssh_authorized_keys:
      - ${ssh_public_key}

runcmd:
  - mkdir -p /opt/app
  - chown ${username}:${username} /opt/app

  - |
    MYSQL_IP=$(getent hosts ${mysql_host} | awk '{ print $1 }')
    tee /opt/app/.env > /dev/null <<EOF
    DB_USER=${db_user}
    DB_PASSWORD=${db_password}
    DB_NAME=${db_name}
    DB_HOST=$${MYSQL_IP}
    EOF
  
  - |
    tee /opt/app/registry_id > /dev/null <<EOF
    ${registry_id}
    EOF

  - cd /opt/app
  - git clone ${git_repo}

  - chmod +x /opt/app/conf-docker-nginx/deploy-scripts.sh
  - chown ${username}:${username} /opt/app/conf-docker-nginx
  - sudo -u ${username} /opt/app/conf-docker-nginx/deploy-scripts.sh
