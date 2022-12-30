from google.cloud import compute

def start_gateway():
    client = compute.InstancesClient()
    operation = client.start(
        project='djpb-1313',
        zone='europe-west1-b',
        instance='gateway'
    )
        
def stop_gateway():
    client = compute.InstancesClient()
    operation = client.stop(
        project='djpb-1313',
        zone='europe-west1-b',
        instance='gateway'
    )
    
def check_gateway():
    client = compute.InstancesClient()
    status = client.get(
        project='djpb-1313',
        zone='europe-west1-b',
        instance='gateway'
    )
    return status.status


if __name__=='__main__':
    check_gateway()
