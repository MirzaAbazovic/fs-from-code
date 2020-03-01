# INSTALL FreeSWITCH (FS) from source code

## Compiling from source code (latest master) 

### Prepare:

1. Install: gnupg2, wget, lsb-release
2. Add GPG FS key freeswitch_archive_g0.pub from
 https://files.freeswitch.org/repo/deb/debian-unstable
3. Update apt source list with freeswitch
4. Install FS dependencies
5. Clone
6. Run bootstrap script that starts building 


```bash
apt-get update && apt-get install -yq gnupg2 wget lsb-release
wget -O - https://files.freeswitch.org/repo/deb/debian-unstable/freeswitch_archive_g0.pub | apt-key add -
 
echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
 
apt-get update
 
# Install dependencies required for the build
apt-get build-dep freeswitch
 
# Then let's get the source. Use the -b flag to get a specific branch
cd /usr/src/
git clone https://github.com/signalwire/freeswitch.git freeswitch
cd freeswitch
 
# Because we're in a branch that will go through many rebases, it's
# better to set this one, or you'll get CONFLICTS when pulling (update).
git config pull.rebase true
 
# ... and do the build
 
# The -j argument spawns multiple threads to speed the build process, but causes trouble on some systems
./bootstrap.sh -j
```

### Select modules

    if you want to add or remove modules from the build, edit modules.conf
    
    ```vi modules.conf```
    
    add a module by removing '#' comment character at the beginning of the line
    
    remove a module by adding the '#' comment character at the beginning of the line  containing the name of the module to be skipped in the build process

 
### Build

 ```bash
./configure
make
make install
 
# Install audio files:
make cd-sounds-install cd-moh-install
 
```

### Update

```bash
# To update an installed build:
cd /usr/src/freeswitch
make current
```

Have scripts here just make them executable (and optionally edit modules.conf before install):

```bash
chmod +x prepare-fs.sh 
chmod +x install-fs.sh 
chmod +x update-fs.sh 
```


Build your own .deb Master package

```bash
apt-get update && apt-get install -yq gnupg2 wget lsb-release
wget -O - https://files.freeswitch.org/repo/deb/debian-unstable/freeswitch_archive_g0.pub | apt-key add -
 
echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
 
apt-get update && apt-get install -y xz-utils devscripts cowbuilder git screen
 
# nonstandard packages from freeswitch repo are not trusted by pbuilder !!
echo "ALLOWUNTRUSTED=yes" >> /etc/pbuilderrc
 
# get the latest master. Use the -b flag to get a specific branch
mkdir /usr/src/freeswitch-debs
git clone https://github.com/signalwire/freeswitch.git /usr/src/freeswitch-debs/freeswitch
 
cd /usr/src/freeswitch-debs
# here it's good to run screen with logging, so that you can detach from the shell prompt
screen -L
cd freeswitch
./debian/util.sh build-all -aamd64 -cbuster
 
# here you can detach by Ctrl-a Ctrl-d and see the log files in /usr/src/freeswitch-debs/log/ folder.
# The build may last about an hour, depending on your CPU speed.
# If the build is successful, you will have a bunch of .deb files in /usr/src/freeswitch-debs
```


# Post install

```bash
# create user 'freeswitch'
cd /usr/local
groupadd freeswitch
# add it to group 'freeswitch'
adduser --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH open source softswitch" --ingroup freeswitch freeswitch --disabled-password
# change owner and group of the freeswitch installation
chown -R freeswitch:freeswitch /usr/local/freeswitch/
chmod -R ug=rwX,o= /usr/local/freeswitch/
chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/*
```

# RUN it

Manually:

```/usr/local/freeswitch/bin/freeswitch- u freeswitch -g freeswitch -c```

As service:

You can also install it as a service by cretaing file /etc/systemd/system/freeswitch.service
with content [freeswitch.service](conf/freeswitch.service)

Relaod systemd config

```systemctl daemon-reload```

Start FreeSWITCH

```systemctl start freeswitch```

Stop FreeSWITCH:

```systemctl stop freeswitch```

Configure FreeSWITCH to start automatically at boot time:

```systemctl enable freeswitch```

To determine if FreeSWITCH is actually running, use one of these commands:

```ps aux | grep freeswitch```

```ps -e | grep freeswitch```

Either of the above should display a line beginning with the pid (process id) of freeswitch if it is indeed running. Ignore the line that matches the grep command since it also contains the string "freeswitch".

```pidof freeswitch```

pidof returns the process id of the named process. In this case, if FreeSWITCH is running you will see only its pid; if it prints nothing at all, then FreeSWITCH is not running.


# WIP

in ```/usr/local/freeswitch/bin/fs_cli``` run 

reload mod_event_socket