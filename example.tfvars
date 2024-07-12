rke2_version = "v1.28.10+rke2r1"
ha_mode = true
worker_count = 0 # Rancher Management Clusters use hybrid nodes only (cp + worker) so no dedicated workers are necessary
target_network_name= "host"
lb_ip = "10.10.0.8"
ippools = [
    <<-EOF
    resources:
    - apiVersion: loadbalancer.harvesterhci.io/v1beta1
      kind: IPPool
      metadata:
      name: rancher-mgmt-pool
      spec:
        ranges:
        - gateway: 10.10.0.1
          rangeEnd: 10.10.0.8
          rangeStart: 10.10.0.8
          subnet: 10.10.0.0/24
      selector: {}
    EOF
]

lb_spec = [
    <<-EOF
    resources:
      - ---
        apiVersion: loadbalancer.harvesterhci.io/v1beta1
        kind: LoadBalancer
        metadata:
          name: rancher-mgmt-lb
          namespace: default
        spec:
          healthCheck:
            failureThreshold: 3
            port: 6443
            successThreshold: 2
            timeoutSeconds: 5
            periodSeconds: 5
          ipam: pool
          ipPool: rancher-mgmt-pool
          listeners:
          - name: k8s-api
            port: 6443
            protocol: TCP
            backendPort: 6443
          - name: ingress
            port: 443
            protocol: TCP
            backendPort: 443
          - name: join
            port: 9345
            protocol: TCP
            backendPort: 9345
          workloadType: vm
          backendServerSelector:
            harvesterhci.io/vmName:
            - rke2-mgmt-controlplane-0
            - rke2-mgmt-controlplane-1
            - rke2-mgmt-controlplane-2
    EOF
]

# set to an empty list if you just want DHCP provisioning for your control plane nodes
# cp_network_data = []
cp_network_data = [
    <<EOT
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: no
      addresses: [10.10.0.20/24]
      gateway4: 10.10.0.1
      nameservers:
        addresses: [10.10.0.1]
    EOT
    ,
    <<EOT
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: no
      addresses: [10.10.0.21/24]
      gateway4: 10.10.0.1
      nameservers:
        addresses: [10.10.0.1]
    EOT
    ,
    <<EOT
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: no
      addresses: [10.10.0.22/24]
      gateway4: 10.10.0.1
      nameservers:
        addresses: [10.10.0.1]
    EOT
    ]