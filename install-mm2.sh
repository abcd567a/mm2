#!/bin/bash
VERSION=modesmixer2_rpi4_deb10_20190413
#DOWNLOAD_ID=1YY7wQNtqrPk7qtE3OB9DGkc4nDalJsCS
INSTALL_FOLDER=/usr/share/mm2

echo "Creating folder mm2"
mkdir ${INSTALL_FOLDER}
#echo "Downloading modeSMixer2 file from Google Drive"
#sudo wget -O ${INSTALL_FOLDER}/${VERSION}.tgz "https://drive.google.com/uc?export=download&id=${DOWNLOAD_ID}"
echo "Downloading modeSMixer2 file from Github"
wget -O ${INSTALL_FOLDER}/${VERSION}.tgz "https://github.com/abcd567a/mm2/releases/download/v1/${VERSION}.tgz"

echo "Unzipping downloaded file"
tar xvzf ${INSTALL_FOLDER}/${VERSION}.tgz -C ${INSTALL_FOLDER}

echo "Creating symlink to modesmixer2 binary in folder /usr/bin/ "
ln -s ${INSTALL_FOLDER}/modesmixer2 /usr/bin/modesmixer2

echo -e "\e[1;32m...ADDING ARCHITECTURE armhf ...\e[39m"
sleep 2
sudo dpkg --add-architecture armhf
echo -e "\e[1;32m...UPDATING ... \e[39m"
sleep 2
apt update
echo -e "\e[1;32m...INSTALLING DEPENDENCY PACKAGES ... \e[39m"
echo -e "\e[1;32m...INSTALLING DEPENDENCY 1 of 3 (libssl1.1:armhf) ... \e[39m"
sleep 2
wget -O ${INSTALL_FOLDER}/libssl1.1_1.1.1w-0+deb11u1_armhf.deb http://http.us.debian.org/debian/pool/main/o/openssl/libssl1.1_1.1.1w-0+deb11u1_armhf.deb
dpkg -i ${INSTALL_FOLDER}/libssl1.1_1.1.1w-0+deb11u1_armhf.deb
apt -y --fix-broken install
apt install -y libssl1.1:armhf
echo -e "\e[1;32m...INSTALLING DEPENDENCY 2 of 3 (libstdc++6:armhf) ... \e[39m"
sleep 2
apt install -y libstdc++6:armhf
echo -e "\e[1;32m...INSTALLING DEPENDENCY 3 of 3 (netbase) ... \e[39m"
sleep 2
apt install -y netbase

echo "Creating startup script file mm2.sh"
SCRIPT_FILE=${INSTALL_FOLDER}/mm2.sh
touch ${SCRIPT_FILE}
chmod 777 ${SCRIPT_FILE}
echo "Writing code to startup script file mm2.sh"
/bin/cat <<EOM >${SCRIPT_FILE}
#!/bin/sh
CONFIG=""
while read -r line; do CONFIG="\${CONFIG} \$line"; done < ${INSTALL_FOLDER}/mm2.conf
cd ${INSTALL_FOLDER}
${INSTALL_FOLDER}/modesmixer2 \${CONFIG}
EOM
chmod +x ${SCRIPT_FILE}

echo "Creating config file mm2.conf"
CONFIG_FILE=${INSTALL_FOLDER}/mm2.conf
touch ${CONFIG_FILE}
chmod 777 ${CONFIG_FILE}
echo "Writing code to config file mm2.conf"
/bin/cat <<EOM >${CONFIG_FILE}
--inConnectId 127.0.0.1:30005:ADSB
--inConnectId 127.0.0.1:30105:MLAT
--web 8787
EOM
chmod 644 ${CONFIG_FILE}

echo "Creating User mm2 to run modesmixer2"
adduser --system --no-create-home mm2

echo "Creating distance file distances.json"
DISTANCE_FILE=${INSTALL_FOLDER}/distances.json
touch ${DISTANCE_FILE}
chown mm2 ${DISTANCE_FILE}

echo "Assigning ownership of install folder to user mm2"
chown mm2 -R ${INSTALL_FOLDER}

echo "Creating Service file mm2.service"
SERVICE_FILE=/lib/systemd/system/mm2.service
touch ${SERVICE_FILE}
chmod 777 ${SERVICE_FILE}
/bin/cat <<EOM >${SERVICE_FILE}
# modesmixer2 service for systemd
[Unit]
Description=ModeSMixer2
Wants=network.target
After=network.target
[Service]
User=mm2
RuntimeDirectory=modesmixer2
RuntimeDirectoryMode=0755
ExecStart=/bin/bash ${INSTALL_FOLDER}/mm2.sh
SyslogIdentifier=modesmixer2
Type=simple
Restart=on-failure
RestartSec=30
RestartPreventExitStatus=64
Nice=-5
[Install]
WantedBy=default.target

EOM

chmod 644 ${SERVICE_FILE}
systemctl enable mm2
systemctl restart mm2

echo " "
echo " "
echo -e "\e[32mINSTALLATION COMPLETED \e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32mPLEASE DO FOLLOWING:\e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32m(1) In your browser, go to web interface at\e[39m"
echo -e "\e[39m     http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*'):8787 \e[39m"
echo " "
echo -e "\e[33m(2) Open file mm2.conf by following command:\e[39m"
echo -e "\e[39m     sudo nano "${INSTALL_FOLDER}"/mm2.conf \e[39m"
echo ""
echo -e "\e[33mAdd following line:\e[39m"
echo -e "\e[39m     --location xx.xxxx:yy.yyyy \e[39m"
echo ""
echo -e "\e[33m(Replace xx.xxxx and yy.yyyy \e[39m"
echo -e "\e[33mby your actual latitude and longitude) \e[39m"
echo -e "\e[33mSave (Ctrl+o) and Close (Ctrl+x) file mm2.conf \e[39m"
echo ""
echo -e "\e[33mthen restart mm2 by following command:\e[39m"
echo -e "\e[39m     sudo systemctl restart mm2 \e[39m"
echo " "

echo -e "\e[32mTo see status\e[39m sudo systemctl status mm2"
echo -e "\e[32mTo restart\e[39m    sudo systemctl restart mm2"
echo -e "\e[32mTo stop\e[39m       sudo systemctl stop mm2"


