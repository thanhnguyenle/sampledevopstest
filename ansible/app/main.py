from flask import Flask, jsonify
import subprocess
import os
from datetime import datetime

app = Flask(__name__)

TARGET_IP = os.getenv('TARGET_IP', '8.8.8.8')
TARGET_PORT = os.getenv('TARGET_PORT', '443')
API_PORT = int(os.getenv('API_PORT', 5000))

def get_ping_latency(host):
    cmd = ['ping', '-c', '10', host]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        latencies = []
        for line in result.stdout.split('\n'):
            if 'time=' in line:
                time_str = line.split('time=')[1].split()[0]
                latencies.append(float(time_str))
        
        if latencies:
            return {
                'min': f'{round(min(latencies), 3)} ms',
                'avg': f'{round(sum(latencies) / len(latencies), 3)} ms',
                'max': f'{round(max(latencies), 3)} ms'
            }
    except (subprocess.TimeoutExpired, ValueError):
        pass

    return None

def get_traceroute_latency(host):
    cmd = ['traceroute', '-n', '-q', '3', host]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)  
        lines = result.stdout.strip().split('\n')
        dest_ip = None
        if lines and 'traceroute to' in lines[0]:
            parts = lines[0].split()
            if len(parts) >= 3:
                dest_ip = parts[2]
        
        if not dest_ip:
            return None
        
        for line in reversed(lines[1:]):
            if dest_ip in line and 'ms' in line:
                parts = line.split()
                latencies = []

                for i in range(len(parts)):
                    if parts[i] == 'ms' and i > 0:
                        latency_value = float(parts[i - 1])
                        latencies.append(latency_value)
                if latencies:
                    return {
                        'min': f'{round(min(latencies), 3)} ms',
                        'avg': f'{round(sum(latencies) / len(latencies), 3)} ms',
                        'max': f'{round(max(latencies), 3)} ms'
                    }
    except (subprocess.TimeoutExpired, ValueError):
        pass

        return None

def get_curl_latency(host, port):
    url = f"http://{host}:{port}"
    cmd = [
        'curl', '-w',
        '%{time_namelookup},%{time_connect},%{time_appconnect},%{time_pretransfer},%{time_redirect},%{time_starttransfer},%{time_total}',
        '-o', '/dev/null',
        '-s',
        url
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        print(result.stdout)
        print(result.returncode)
        
        if result.stdout.strip():
            values = result.stdout.strip().split(',')
            if len(values) == 7:
                return {
                    'DNS Lookup Time': f"{round(float(values[0]) * 1000, 3)} ms",
                    'TCP Connect Time': f"{round(float(values[1]) * 1000, 3)} ms",
                    'SSL Handshake Time': f"{round(float(values[2]) * 1000, 3)} ms",
                    'Pretransfer Time': f"{round(float(values[3]) * 1000, 3)} ms",
                    'Redirect Time': f"{round(float(values[4]) * 1000, 3)} ms",
                    'Start Transfer Time': f"{round(float(values[5]) * 1000, 3)} ms",
                    'Total Time': f"{round(float(values[6]) * 1000, 3)} ms"
                }
    except (subprocess.TimeoutExpired, ValueError):
        pass
    
    return None

@app.route('/latency', methods=['GET'])
def get_latency():
    try:
        icmp = get_ping_latency(TARGET_IP)
    except Exception as e:
        icmp = None
    try:
        udp = get_traceroute_latency(TARGET_IP)
    except Exception as e:
        udp = None
    try:
        http = get_curl_latency(TARGET_IP, TARGET_PORT)
    except Exception as e:
        http = None

    return jsonify({
        'target_ip': TARGET_IP,
        'target_port': TARGET_PORT,
        'measurements': {
            'ICMP': icmp,
            'UDP': udp,
            'TCP': http
        }
    })


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=API_PORT)