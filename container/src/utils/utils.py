import os
import time
import requests
from google.cloud import compute

def start_instance():
    client = compute.InstancesClient()
    operation = client.start(
        project='djpb-1313',
        zone='europe-west1-b',
        instance='gateway'
    )

    count = 0
    while (not operation.done()) and count<30:
        time.sleep(10)
        count = count+1

    count = 0
    while (not check_instance()) and count<30:
        time.sleep(10)
        count = count+1

    print('Instance started')

        
def stop_instance():
    client = compute.InstancesClient()
    operation = client.stop(
        project='djpb-1313',
        zone='europe-west1-b',
        instance='gateway'
    )

    count = 0
    while (not operation.done()) and count<30:
        time.sleep(10)
        count = count+1

    print('Instance stopped')
    

def check_instance():
    try:
        requests.get(f'''http://{os.environ['GATEWAY_IP']}:80''', timeout=30)
        return True
    except Exception:
        return False


if __name__=='__main__':
    stop_instance()
