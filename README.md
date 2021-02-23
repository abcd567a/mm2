## mm2
### ModeSMixer2 installation script for RPi 2/3/4 and Raspbian Stretch/Buster, Ubuntu 20.04, and Debian 10.5 
</br>

Copy-paste following command in SSH console and press Enter key. The script will install and configure modesmixer2. </br></br>
**(1) For 32 Bit Raspberry Pi OS:** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/mm2/master/install-mm2.sh)" `</br></br>
**(2) For 64 Bit Raspberry Pi OS:** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/mm2/master/install-mm2-64bit.sh)" ` </br></br>
**(3) For Ubuntu 20.04 (x86_64) & Kali Linux 2020 amd64:** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/mm2/master/install-mm2-ubuntu20.sh)" ` </br></br>
**(4) For Debian 10.5 (x86_64):** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/mm2/master/install-mm2-debian10.sh)" ` </br></br>
After script finishes, it displays following message
```
=======================
INSTALLATION COMPLETED
=======================
PLEASE DO FOLLOWING:

(1) If installed on RPi, in your browser, go to web interface at http://ip-of-pi:8787. 
(2) If installed on Ubuntu20, in browser of Ubuntu go to web interface at http://localhost:8787 or http://127.0.0.1:8787


(3) Open file mm2.sh for editing by following command:

sudo nano /usr/share/mm2/mm2.conf

Add following line: 

--location xx.xxxx:yy.yyyy 

(Replace xx.xxxx and yy.yyyy by your 
actual latitude and longitude) 
After entering location, Save (Ctrl+o) and Close (Ctrl+x) file md2.conf 
then restart mm2 by following command: 

sudo systemctl restart mm2



To see status sudo systemctl status mm2
To restart    sudo systemctl restart mm2
To stop       sudo systemctl stop mm2
```

### CONFIGURATION </br>
The configuration file can be edited by following command; </br>
`sudo nano /usr/share/mm2/mm2.conf ` </br></br>
**Default contents of config file**</br>
Default setting are for a decoder like dump1090-mutability or dump1090-fa running on the RPi. </br>
This can be changed by editing config file</br>
You can add extra arguments, one per line starting with `--` </br>
```
--inConnectId 127.0.0.1:30005:ADSB
--inConnectId 127.0.0.1:30105:MLAT
--web 8787

```
</br>

**To see all config parameters** </br>
```
cd /usr/share/mm2
./modesmixer2 --help
```

### CLERING MAXIMUM COVERAGE CURVE ON THE MAP</br>
The maximum coverage curve data is stored in file `distances.json`. If you want to clear the coverage plot and start a fresh plot, delete this file and restart mm2. Upon restart, when mm2 does not find file `distances.json`, it creates it's new blank copy, and start populating it with fresh data. </br>
```
sudo rm /usr/share/mm2/distances.json  
sudo systemctl restart mm2   
```

### UNINSTALL </br>
To completely remove configuration and all files, give following 6 commands:
```
sudo systemctl stop mm2 
sudo systemctl disable mm2 
sudo rm /lib/systemd/system/mm2.service 
sudo rm -rf /usr/share/mm2 
sudo rm /usr/bin/modesmixer2 
sudo userdel mm2  
```
