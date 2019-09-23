import optparse
import time
import os
import sys
from proton import Message
from proton.utils import BlockingConnection
from proton.handlers import IncomingMessageHandler

broker = os.getenv('AMQP_BROKER_HOST_PORT')
queue = os.getenv('AMQP_ADDRESS')
user_arg = os.getenv('AMQP_USER')
userpw_arg = os.getenv('AMQP_USER_PASSWORD')

conn = BlockingConnection(broker, user=user_arg, password=userpw_arg)
receiver = conn.create_receiver(queue)

count = 0
try:
    while True:
        msg = receiver.receive(timeout=None)
        count += 1
        print("got message, processing for two seconds...")
        sys.stdout.flush()
        time.sleep(2)
        receiver.accept()
finally:
    conn.close()

print ("All done.  Processed ", count, " messages.")
