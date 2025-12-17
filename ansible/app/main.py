from flask import Flask, jsonify
import subprocess
import os
from datetime import datetime

app = Flask(__name__)

TARGET_IP = os.getenv('TARGET_IP', '10.0.2.1')
API_PORT = int(os.getenv('API_PORT', 5000))

def get_ping_latency(host):
    cmd = ['ping', '-c', '10', host]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    latencies = []
    for line in result.stdout.split('\n'):
        if 'time=' in line:
            try:
                time_str = line.split('time=')[1].split()[0]
                latencies.append(float(time_str))
            except:
                pass
    
    if latencies:
        return {
            'min': f'{round(min(latencies), 3)} ms',
            'avg': f'{round(sum(latencies) / len(latencies), 3)} ms',
            'max': f'{round(max(latencies), 3)} ms'
        }
    return None

def get_traceroute_latency(host):
    cmd = ['traceroute', '-n', host]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    
    latencies = []
    for line in result.stdout.split('\n'):
        parts = line.split()
        for i, part in enumerate(parts):
            if part == 'ms':
                try:
                    latencies.append(float(parts[i-1]))
                except:
                    pass
    
    if latencies:
        return {
            'min': f'{round(min(latencies), 3)} ms',
            'avg': f'{round(sum(latencies) / len(latencies), 3)} ms',
            'max': f'{round(max(latencies), 3)} ms'
        }
    return None

@app.route('/latency', methods=['GET'])
def get_latency():
    icmp = get_ping_latency(TARGET_IP)
    udp = get_traceroute_latency(TARGET_IP)
    
    return jsonify({
        'target_ip': TARGET_IP,
        'ICMP': icmp,
        'UDP': udp
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=API_PORT)