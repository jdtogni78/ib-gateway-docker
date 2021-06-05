echo PLEASE EDIT CRONTABS

INITD=/etc/init.d/dstrader
cp host/init.d/dstrader $INITD
chmod 755 $INITD
chown root:root $INITD

OPT=/opt/dstrader/
mkdir -p $OPT
cp opt/* $OPT

chmod -R 755 $OPT
chown -R root:root $OPT
