# Just enough broker configuration to do the KEDA sample.
# Called with OVERRIDE_PATH set to our mounted override files, including this script.
# CONFIG_PATH is set to the normal $BROKER_HOME/etc dir with the Artemis config files.


# \X..X  denotes the regex used to locate the insertion point for added text
sed -i '\X</security-settings>Xi \
         <security-setting match="queue01"> \
            <permission roles="sampleuser, amq" type="send"/> \
            <permission roles="sampleuser, amq" type="consume"/> \
            <permission roles="sampleuser, amq" type="browse"/> \
            <permission  roles="amq" type="manage"/> \
         </security-setting> \
' $CONFIG_PATH/broker.xml

sed -i '\X</addresses>Xi \
         <address name="queue01"> \
            <anycast> \
               <queue name="queue01" /> \
            </anycast> \
         </address> \
' $CONFIG_PATH/broker.xml

# Add a non-admin role and user that can use our queue01
echo 'sampleuser = user01' >>$CONFIG_PATH/artemis-roles.properties
echo 'user01 = user01pw' >>$CONFIG_PATH/artemis-users.properties


# setup Jolokia to use https and our self signed cert
cp $OVERRIDE_PATH/tls_bootstrap.xml $CONFIG_PATH/bootstrap.xml
cp $OVERRIDE_PATH/tls_jolokia-access.xml $CONFIG_PATH/jolokia-access.xml
