# self signed key for the Artemis Jolokia management server

openssl req -newkey rsa:2048 -nodes -keyout brokerkey.pem -x509 -days 3650 -out brokercert.pem -subj "/C=XX/ST=Default/L=Default City/O=Self Signed/OU=Messaging/CN=artemis01.keda-sample.svc.cluster.local"

# make a version in pkcs12 format for the broker config

openssl pkcs12 -inkey brokerkey.pem -in brokercert.pem -export -out ../etc-override/brokerks.p12 -password pass:brokerpw
