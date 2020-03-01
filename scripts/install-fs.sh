cp modules.conf /usr/src/freeswitch/modules.conf
cd /usr/src/freeswitch

./configure
make
make install
 
# Install audio files:
make cd-sounds-install cd-moh-install
 