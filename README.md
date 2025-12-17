# Sample DevOps Test

A simple Flask API that measures network latency between two EC2 instances using both ICMP (ping), TCP (curl) and UDP (traceroute) protocols.

## Prerequisites

- Terraform installed (v1.14.2)
- Ansible installed (2.16.3)
- Python installed (3.12.3)
- AWS CLI configured (`aws configure`)
- SSH key pair (public key and private key) for EC2 access (For ansible)

## Project Structure

```
sampledevopstest
├── .github
│   └── workflows
│       └── deploy.yml         # CI/CD pipeline
├── ansible
│   ├── app
│   │   ├── main.py            # Flask application
│   │   ├── Dockerfile         # Container image
│   │   └── requirements.txt   # Python dependencies
│   ├── inventory.ini          # Ansible hosts
│   ├── playbook.yaml          # Deployment playbook
│   ├── ansible.cfg            # Ansible configuration
│   └── vars.yaml              # Variables
├── iac
│   ├── cloud-init.yaml        # Init EC2 state
│   ├── common.tf              # Common tags
│   ├── ec2.tf                 # EC2 instances
│   ├── igw.tf                 # Internet Gateway
│   ├── output.tf              # Terraform outputs
│   ├── providers.tf           # AWS provider config
│   ├── rt.tf                  # Route tables
│   ├── sg.tf                  # Security groups
│   ├── snet.tf                # Subnets
│   └── vpc.tf                 # VPC
└── README.md
```

## Quick Start

### 1. Deploy Infrastructure

Update `iac/cloud-init.yaml`:

```json
#cloud-config

users:
  - default
  - name: ec2-user
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - <YOUR PUBLIC KEY>

ssh_pwauth: false
disable_root: true
```

Run command:
```bash
cd iac
terraform init
terraform plan
terraform apply -auto-approve
```

### 2. Get Instance IPs from output

```log
Outputs:

instance_01_public_ip = <INSTANCE_1_PUBLIC_IP>
instance_01_private_ip = <INSTANCE_1_PRIVATE_IP>
instance_02_private_ip = <INSTANCE_2_PRIVATE_IP>
```

### 3. Update Ansible

Edit `ansible/inventory.ini`:

```ini
[app]
<INSTANCE_1_PUBLIC_IP>

[app:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=./id_rsa
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
```
=> The `id_rsa` file contains the private key that Ansible uses to SSH into Instance 1 for setup (same folder with `ansible/inventory.ini`)

Edit `ansible/vars.yaml`:

```ini
app_dir: /home/ec2-user/app
api_port: "5000"
target_instance_ip: <INSTANCE_2_PRIVATE_IP>
```

### 4. Deploy Application

```bash
cd ../ansible

ansible-playbook -i inventory.ini playbook.yaml
```

### 5. Test the API

```bash
curl http://<INSTANCE_1_PUBLIC_IP>/latency
```

## Technology Choices

### Infrastructure
- **Terraform**: Infrastructure as code
- **AWS EC2**: AWS compute instances

### Application
- **Python + Flask**: Simple, easy to deploy API
- **ICMP (ping)**: Standard network latency measurement
- **UDP (traceroute)**: Reveals network path and hop-by-hop latency

### Deployment
- **Ansible**: Simple configuration management
- **Docker**: Containerized application
- **cloud-init**: Automated instance bootstrapping

## Test Scenarios

### Case 1: Same VPC, Different Subnets
- **Configuration:** Two instances in same VPC but different subnets  
- **Connection:** Private IP  
- **Expected Latency:** ~0.2-0.3 ms RTT

```json
{
  "ICMP": {
    "avg": "0.253 ms",
    "max": "0.371 ms",
    "min": "0.212 ms"
  },
  "UDP": {
    "avg": "0.205 ms",
    "max": "0.223 ms",
    "min": "0.186 ms"
  },
  "target_ip": "10.0.2.183"
}
```

**Observation:** UDP shows slightly lower latency than ICMP (~0.05ms). This is expected as UDP has less protocol overhead.

### Case 2: Same VPC, Same Subnet, Same Rack
- **Configuration:** Two instances in same subnet with placement group  
- **Connection:** Private IP  
- **Expected Latency:** ~0.2 ms RTT (minimal difference from Case 1)

```json
{
  "ICMP": {
    "avg": "0.233 ms",
    "max": "0.258 ms",
    "min": "0.212 ms"
  },
  "UDP": {
    "avg": "0.196 ms",
    "max": "0.218 ms",
    "min": "0.175 ms"
  },
  "target_ip": "10.0.2.218"
}
```

**Observation:** Latency is nearly identical to Case 1. Although placement groups ensure that instances are located on the same physical rack, the difference is not clearly when transferring small packets.

### Case 3: Different Regions (Singapore ↔ US-EAST-1)
- **Configuration:** Instances in different AWS regions  
- **Connection:** Public IP (through internet)  
- **Expected Latency:** ~219-232 ms RTT

```json
{
  "ICMP": {
    "avg": "220.0 ms",
    "max": "220.0 ms",
    "min": "220.0 ms"
  },
  "UDP": {
    "avg": "227.226 ms",
    "max": "232.402 ms",
    "min": "219.977 ms"
  },
  "target_ip": "54.251.210.47"
}
```

**Observation:** Latency is higher due to the physical distance.

### Case 4: Different Regions (Singapore ↔ US-EAST-1)
- **Configuration:** Instances in different AWS regions  
- **Connection:** Private IP
- **Expected Latency:** ~219-224 ms RTT
```json
{
  "measurements": {
    "ICMP": {
      "avg": "224.0 ms",
      "max": "224.0 ms",
      "min": "224.0 ms"
    },
    "TCP": {
      "DNS Lookup Time": "0.015 ms",
      "Pretransfer Time": "0.0 ms",
      "Redirect Time": "0.0 ms",
      "SSL Handshake Time": "0.0 ms",
      "Start Transfer Time": "0.0 ms",
      "TCP Connect Time": "0.0 ms",
      "Total Time": "224.849 ms"
    },
    "UDP": {
      "avg": "220.347 ms",
      "max": "221.28 ms",
      "min": "219.414 ms"
    }
  },
  "target_ip": "10.2.1.29",
  "target_port": "80"
}
```

**Observation:** Latency is similar to the public IP case. The large latency caused by geographic distance makes it difficult to clearly the difference between traffic transferred via public IPs (through the Internet) and private IPs (over the AWS backbone)

### Case 5: Nearby Regions (US-EAST-2 ↔ US-EAST-1)
- **Configuration:** Instances in different but nearby AWS regions
- **Connection:** Public IP vs Private IP

- Public IP (through internet)
```json
{
  "measurements": {
    "ICMP": {
      "avg": "12.29 ms",
      "max": "12.3 ms",
      "min": "12.2 ms"
    },
    "TCP": {
      "DNS Lookup Time": "0.014 ms",
      "Pretransfer Time": "0.0 ms",
      "Redirect Time": "0.0 ms",
      "SSL Handshake Time": "0.0 ms",
      "Start Transfer Time": "0.0 ms",
      "TCP Connect Time": "0.0 ms",
      "Total Time": "12.397 ms"
    },
    "UDP": {
      "avg": "10.916 ms",
      "max": "12.065 ms",
      "min": "9.666 ms"
    }
  },
  "target_ip": "3.145.125.2",
  "target_port": "80"
}
```

- Private IP
```json
{
  "measurements": {
    "ICMP": {
      "avg": "11.53 ms",
      "max": "11.8 ms",
      "min": "11.5 ms"
    },
    "TCP": {
      "DNS Lookup Time": "0.018 ms",
      "Pretransfer Time": "0.0 ms",
      "Redirect Time": "0.0 ms",
      "SSL Handshake Time": "0.0 ms",
      "Start Transfer Time": "0.0 ms",
      "TCP Connect Time": "0.0 ms",
      "Total Time": "11.847 ms"
    },
    "UDP": {
      "avg": "11.375 ms",
      "max": "11.467 ms",
      "min": "11.283 ms"
    }
  },
  "target_ip": "10.2.1.56",
  "target_port": "80"
}
```

**Observations:** There is still a difference between data transfer over public and private IPs. Although the gap is only around 1–2 ms, it can still have an impact on HPC systems.

## Understanding the Metrics

### Round-Trip Time (RTT) vs One-Way Latency
- **RTT**: Time for packet to go from Instance 1 → Instance 2 → Instance 1
- **One-Way Latency**: Approximately `RTT / 2`

### ICMP vs UDP vs TCP
- **ICMP (ping)**: Simpler protocol, may be rate-limited by routers
- **UDP (traceroute)**: Slightly lower protocol overhead
- **TCP (curl)**: Measures application-layer latency, including TCP handshake and connection setup

## Cleanup

```bash
cd iac
terraform destroy -auto-approve
```

## Assumptions & Limitations

### Assumptions

- Both servers are AWS resources
- ICMP, UDP, and TCP traffic is allowed by security groups
- Network connectivity between servers is properly configured

### Limitations

- Unable to evaluate latency improvements using AWS Global Accelerator
- Unable to test scenarios different network environments (VPC vs on-premises)
- Tests with small packets only, which may not reflect real-world traffic patterns

###  Future Improvements

- Test connectivity between on-premises and VPC environments
- Perform latency tests using larger data transfers to better simulate real-world workloads
- Evaluate the impact of AWS Global Accelerator on latency and routing performance