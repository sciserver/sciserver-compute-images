#!/usr/bin/bash

# place files in their locations.

home=/home/idies

cat jupyter_server_config.py >> ${ENV_DIR}/heasoft/etc/jupyter/jupyter_server_config.py
chown $USER:$USER -R ${ENV_DIR}/heasoft/etc/jupyter/

mv xstartup /opt/xstartup
chmod +x /opt/xstartup

mv fluxbox/menu /etc/X11/fluxbox/fluxbox-menu
mv fluxbox/apps /etc/X11/fluxbox/apps
mv fluxbox/init /etc/X11/fluxbox/init

chmod +x start_supervisor
mv start_supervisor /usr/local/bin/

mkdir -p /etc/supervisor/conf.d/
mv supervisord.conf /etc/supervisor/conf.d/

patch /opt/novnc/vnc_lite.html vnc_lite.html.patch
rm vnc_lite.html.patch

mv ds9.svg /opt/

printf '\nalias ds9="/usr/local/bin/ds9 -mode region"\n' >> $home/.bashrc
