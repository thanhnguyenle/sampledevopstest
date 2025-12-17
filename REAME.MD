# Sample DevOps Test

A simple Flask API that measures network latency between two instances using both ICMP (ping) and UDP (traceroute) protocols.

## Prerequisites

- ansible install
- terraform install
- can login to aws 

## Project Structure

```
sampledevopstest
|- .github
|   |- workflows
|       |- deploy.yml
|- ansible
|   |- app
|   |   |- main.py
|   |   |- Dockerfile
|   |   |- requirements.txt
|   |- inventory.ini
|   |- playbook.yml
|   |- ansible.cfg
|   |- vars.yaml
|- iac
|   |- cloud-init.yaml
|   |- common.tf
|   |- ec2.tf
|   |- igw.tf
|   |- output.tf
|   |- providers.tf
|   |- rt.tf
|   |- sg.tf
|   |- snet.tf
|   |- vpc.tf
|- README.MD
```

## API Usage

### Endpoint: `GET /latency`

Returns latency measurements using both ICMP and UDP protocols.

**Example Request:**
```bash
curl http://[PUBLIC IP INSTANCE 1]/latency
```

**CASE 1: Same VPC, different Subnet, PING USE PRIVATE IP**
```json
{
  "ICMP": {
    "avg": 0.252,
    "max": 0.291,
    "min": 0.217
  },
  "UDP": {
    "avg": 0.173,
    "max": 0.353,
    "min": 0.006
  },
  "target_ip": "10.0.2.137",
  "timestamp": "2025-12-17T03:48:03.608814"
}
```