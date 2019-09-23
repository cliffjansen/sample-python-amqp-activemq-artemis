FROM debian
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install --yes python-pip && pip install python-qpid-proton && mkdir amqpsample
COPY msg_processor.py simple_send.py amqpsample/
CMD ["/usr/bin/python", "/amqpsample/msg_processor.py"]
