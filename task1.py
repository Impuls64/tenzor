# task1.py
import requests
import time
from datetime import datetime

def fetch_time_data():
    url = "https://yandex.com/time/sync.json?geo=213"
    
    # a) Выполнение запроса и вывод сырого ответа
    response = requests.get(url)
    print("a) Raw response:")
    print(response.json())
    print()
    
    data = response.json()
    
    # b) Время в человекочитаемом формате и временная зона
    timestamp = data['time'] / 1000  # Convert ms to seconds
    human_time = datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    timezone = data['clocks']['213']['name']  # Fixed path to timezone
    print(f"b) Human-readable time: {human_time}")
    print(f"   Timezone: {timezone}")
    print()
    
    return timestamp

def measure_delta():
    deltas = []
    for i in range(5):
        start_time = time.time()
        timestamp = fetch_time_data()
        end_time = time.time()
        
        server_time = timestamp
        local_time_before = start_time
        delta = server_time - local_time_before
        
        print(f"c) Delta for request {i+1}: {delta:.6f} seconds")
        deltas.append(delta)
        time.sleep(1)  # Small delay between requests
    
    avg_delta = sum(deltas) / len(deltas)
    print(f"\nd) Average delta: {avg_delta:.6f} seconds")

if __name__ == "__main__":
    measure_delta()