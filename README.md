# Sample DevOps Test

A simple Flask API that measures network latency between two EC2 instances using both ICMP (ping) and UDP (traceroute) protocols.

## Prerequisites

- Terraform installed
- Ansible installed
- AWS CLI configured (`aws configure`)
- SSH key pair for EC2 access (For ansible)

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
│   ├── cloud-init.yaml        # Init state
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

```bash
cd iac
terraform init
terraform plan
terraform apply -auto-approve
```

### 2. Get Instance IPs from output

```log
Outputs:

instance_singapore_private_ip = "10.2.1.186"
instance_singapore_public_ip = "54.251.210.47"
instance_us_east_private_ip = "10.1.1.108"
instance_us_east_public_ip = "44.199.249.139"
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

Edit `ansible/vars.yaml`:

```ini
app_dir: /home/ec2-user/app
api_port: "5000"
target_instance_ip: <INSTANCE_2_PUBLIC_IP>
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

## Test Scenarios & Results

### Case 1: Same VPC, Different Subnets
**Configuration:** Two instances in same VPC but different subnets  
**Connection:** Private IP  
**Expected Latency:** ~0.2-0.3 ms RTT

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
**Configuration:** Two instances in same subnet with placement group  
**Connection:** Private IP  
**Expected Latency:** ~0.2 ms RTT (minimal difference from Case 1)

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

**Observation:** Latency is nearly identical to Case 1. Placement groups ensure instances are on same physical rack, but AWS networking is already highly optimized within an AZ.

### Case 3: Different Regions (Singapore ↔ US-EAST-1)
**Configuration:** Instances in different AWS regions  
**Connection:** Public IP (through internet)  
**Expected Latency:** ~220-260 ms RTT

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

**Observations:**
- **~1000x higher latency** than same-region scenarios
- **Physical distance:** ~9,500 miles / 15,300 km
- **Speed of light limit:** ~76ms one-way (theoretical minimum)
- **Actual one-way:** ~110ms (accounting for routing, amplifiers, processing)
- **UDP shows more variance** (min: 219ms, max: 232ms) due to internet routing variability

## Understanding the Metrics

### Round-Trip Time (RTT) vs One-Way Latency
- **RTT**: Time for packet to go from Instance 1 → Instance 2 → Instance 1
- **One-Way Latency**: Approximately `RTT / 2`

**Example:**
```
RTT = 0.24 ms  →  One-way latency ≈ 0.12 ms
RTT = 220 ms   →  One-way latency ≈ 110 ms
```

### ICMP vs UDP
- **ICMP (ping)**: Simpler protocol, may be rate-limited by routers
- **UDP (traceroute)**: Shows network path, slightly lower overhead
- **Difference**: Usually 0.02-0.05 ms (negligible for most applications)

## Deployment Scenarios

The infrastructure supports multiple deployment patterns:

### 1. Same Subnet + Placement Group (`ec2.tf`)
- **Use case:** High-frequency trading, real-time gaming
- **Latency:** ~0.2 ms RTT
- **Cost:** Standard

### 2. Different Subnets (modify `snet.tf`)
- **Use case:** Network isolation, multi-tier applications
- **Latency:** ~0.3 ms RTT
- **Cost:** Standard

### 3. VPC Peering (add `vpc_peering.tf`)
- **Use case:** Isolated environments, security boundaries
- **Latency:** ~1-2 ms RTT
- **Cost:** No data transfer charges within same region

### 4. Cross-Region (modify `providers.tf`)
- **Use case:** Disaster recovery, global services
- **Latency:** 60-260 ms RTT (depends on regions)
- **Cost:** Higher (data transfer charges apply)

## Troubleshooting

### Application not responding
```bash
# SSH to Instance 1
ssh ec2-user@<INSTANCE_1_PUBLIC_IP>

# Check if container is running
docker ps

# Check logs
docker logs latency-monitor

# Restart if needed
docker restart latency-monitor
```

### Cannot ping Instance 2
```bash
# Verify security group allows ICMP
aws ec2 describe-security-groups --group-ids <SG_ID>

# Test manual ping from Instance 1
ssh ec2-user@<INSTANCE_1_PUBLIC_IP>
ping <INSTANCE_2_PRIVATE_IP>
```

### Ansible connection fails
```bash
# Test SSH access
ssh -i ~/.ssh/your-key.pem ec2-user@<INSTANCE_PUBLIC_IP>

# Check security group allows port 22
# Verify the key pair name in ec2.tf matches your local key
```

## Cleanup

```bash
cd iac
terraform destroy -auto-approve
```

## Assumptions & Limitations

### Assumptions
- Single AWS account
- Default VPC quotas sufficient
- ICMP/UDP traffic allowed by security groups
- Python 3 available on Amazon Linux 2023

### Limitations
1. **Measurement method:** ICMP/UDP may not reflect actual application latency
2. **Single target:** Only monitors one target instance
3. **No persistence:** Metrics not stored (in-memory only)
4. **No authentication:** API endpoints are public
5. **IPv4 only:** Does not support IPv6

## Future Improvements

1. **Add authentication** to API endpoints
2. **Store metrics** in time-series database (InfluxDB, CloudWatch)
3. **Multi-target monitoring** for comprehensive network visibility
4. **Grafana dashboard** for visualization
5. **Alerting** on latency thresholds
6. **Application-layer latency** (HTTP, TCP connection time)

## License

MIT

---

**Note:** This is a demonstration project for educational purposes.