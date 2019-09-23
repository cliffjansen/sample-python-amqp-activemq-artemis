# KEDA scaling with ActiveMQ Artemis queues and a Python AMQP message processor

This sample shows creating a message processor function that is scaled by KEDA based on the message backlog in an ActiveMQ Artemis broker queue.  The sample function is written in Python and uses the AMQP 1.0 protocol, however, it could have been written using any protocol supported by Artemis (MQTT, STOMP, OpenWire, HornetQ) or any client language implementation for that protocol (C++, Java, .NET, Go, JavaScript).  Configuring the ActiveMQ Artemis KEDA scaler would be unchanged.

For simplicity, this sample focuses on the steps to configure KEDA to securely communicate with the ActiveMQ Artemis broker.  Aside from separating the "administrator" and "user" credentials, this sample does not address secure communication between client and broker.

## Pre-requisites

* Kubernetes cluster
* [KEDA installed](https://github.com/kedacore/keda#setup) on the cluster
* Docker

## Tutorial

We deploy an Artemis broker instance with known credentials and a message queue named "queue01".  We create an image that simulates processing messages from a source queue.  We create a Kubernetes Deployment of that image and a KEDA ScaledObject that configures KEDA to control scaling for handling messages on queue01.  We send some test messages and watch KEDA scaling in action.


First you should clone the project and create a separate testing namespace:

```cli
git clone https://github.com/kedacore/sample-python-amqp-activemq-artemis
cd sample-python-amqp-activemq-artemis
kubectl create namespace keda-sample

```

### Deploy Artemis

The etc-override directory contains just enough configuration to create the Artemis broker instance for this example.  It sets up TLS on port 8161 used by the console and Jolokia management, both an "admin" credential and a lesser "user" credential, and a requisite message queue.  If you need to modify the TLS certificates and keys, take a look at tls/make_self_signed.sh.

```cli
kubectl create configmap artemis-config -n keda-sample --from-file etc-override
kubectl apply -f deploy-artemis.yaml -n keda-sample

```

Create a service that allows KEDA and others to find the Artemis image:

```cli
kubectl apply -f artemis-service.yaml -n keda-sample

```

### Create the message processor image

The sample "msg_processor.py" merely reads a single message at a time, and pauses two seconds between each subsequent message, to simulate processing work on each message.

```cli
( cd msg_processor && docker build . -t amqp-msg-processor:v001 )
```

### Time for KEDA scaling

The ActiveMQ Artemis scaler within KEDA requires access to the broker's Jolokia management system and the name of the queue.  In this sample, the administrator password is left blank in the ScaledObject definition and is provided separately in a Kubernetes secret.  KEDA parses the message processor's deployment definition to extract the password from the secret available from the "env" or "envFrom" directives.  The passwordKey field in the ScaledObject metadata identifies which ENV value contains the password, which is chosen as ARTEMIS_J_PASSWORD for this sample.

```cli
kubectl create secret generic artemispasswd --from-literal=ARTEMIS_J_PASSWORD=admin001pw -n keda-sample
kubectl apply -f keda-amqp-processor.yaml
```

KEDA will now monitor the broker's queue and adjust the number of replicas of the message processor function accordingly.  You can send a burst of messages with your favorite messaging client and observe the scaling behavior over time.  For example, a simple python message producer was tucked into the amqp-msg-processor image created above:

```cli
kubectl get pods -n keda-sample
docker run -it --rm amqp-msg-processor:v001 python /amqpsample/simple_send.py -a amqp://user01:user01pw@172.17.0.20:5672/queue01 -m 10
kubectl get pods -n keda-sample
```

