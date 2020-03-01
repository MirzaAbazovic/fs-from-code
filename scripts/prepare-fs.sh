apt-get update && apt-get install -yq gnupg2 wget lsb-release
wget -O - https://files.freeswitch.org/repo/deb/debian-unstable/freeswitch_archive_g0.pub | apt-key add -
 
echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
 
apt-get update
 
# Install dependencies required for the build
apt-get build-dep freeswitch
 
# Then let's get the source. Use the -b flag to get a specific branch
cd /usr/src/
rm -Rf freeswitch/
git clone https://github.com/signalwire/freeswitch.git freeswitch
cd freeswitch
 
# Because we're in a branch that will go through many rebases, it's
# better to set this one, or you'll get CONFLICTS when pulling (update).
git config pull.rebase true
 
# ... and do the build
 
# The -j argument spawns multiple threads to speed the build process, but causes trouble on some systems
./bootstrap.sh -j
