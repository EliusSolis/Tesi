# Dummy plc

import random
import json
import time


random.seed()

while True:
    with open('/var/log/plc/plc.log', 'a') as log:
        data = {'sensor':'water-tank', 'water-level':f'{random.random() * 100}l'}
        json_data = json.dumps(data)
        log.write(json_data + '\r\n')
        print(json_data)
    time.sleep(1)
