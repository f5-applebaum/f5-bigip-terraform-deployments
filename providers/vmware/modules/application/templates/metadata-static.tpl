local-hostname: ${hostname}
instance-id: ${hostname}
network:
  version: 2
  ethernets:
    ens192:
      # dhcp4: true
      addresses:
        - ${ipv4_network_address}
      routes:
        - to: default
          via: ${ipv4_gateway}
      nameservers:
        addresses:
          - ${dns_server}