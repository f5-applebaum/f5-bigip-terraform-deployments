#cloud-config
users:
  - name: ${username}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
    passwd: ${password_hash}
    ssh_authorized_keys:
     -  "${ssh_public_key}"
write_files:
- encoding: b64
  content: ${netplan}
  path: /etc/netplan/99-custom-network.yaml
  permissions: '0644'
runcmd:
 - sudo netplan generate
 - sudo netplan apply
 - echo "PubkeyAcceptedAlgorithms=+ssh-rsa" | sudo tee -a /etc/ssh/sshd_config > /dev/null
 - sudo systemctl restart ssh.service
 - sudo apt update
 - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
 - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 - sudo apt update
 - sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
 - sudo apt install -y docker-ce
 - sudo docker run --name my_app -p 80:80 -p 443:443 -d ${app_container_name}