# FROM openjdk:8-slim as base
# FROM ubuntu:focal as base
FROM ubuntu:bionic as base

LABEL maintainer="jtogni78"

# Get the container up to date
RUN apt-get -yq update && apt-get -yq dist-upgrade
RUN apt-get -yq install curl wget unzip
RUN apt-get -yq install xvfb libxtst6 libxrender1 libxi6

# Install JRE 1.8 dependencies
RUN apt-get -yq install --no-install-recommends \
    libglib2.0-0 libxrandr2 libxinerama1 libgl1-mesa-glx libgl1 \
    libgtk2.0-0 libasound2 libc6 libgif7 libpulse0 \
    libx11-6 libxext6 libxtst6 libxslt1.1 libopenjfx-jni \
    libcanberra-gtk-module libjpeg8
    #libpng12-0

RUN apt-get -yq install openjdk-8-jre
RUN apt-get -yq install openjfx

# RUN apt-get -yq install ttf-mscorefonts-installer
# Accept license for Microsoft fonts
# RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

FROM base as ibc

# ARG ibc_version=3.8.5
# ARG ibc_installer=IBCLinux-${ibc_version}.zip
# ARG ibc_url=https://github.com/IbcAlpha/IBC/releases/download
#
# # Setup IB TWS and IBController
# RUN cd /tmp \
#  && wget -q ${ibc_url}/${ibc_version}/${ibc_installer} \
#  && mkdir -p /opt/IBController/Logs \
#  && cd /opt/IBController/ \
#  && unzip /tmp/${ibc_installer} \
#  && chmod -R 755 *.sh \
#  && chmod -R 755 scripts/*.sh \
#  && rm /tmp/${ibc_installer}
#
#
# RUN apt-get -qy install libcommons-cli-java libjxgrabkey-jni antlr4
# RUN wget https://launchpad.net/sikuli/sikulix/2.0.5/+download/sikulixide-2.0.5.jar
# ADD sikuli-ide /
# RUN chmod 755 /sikuli-ide

RUN apt-get -qy install python3-pip python3-tk python3-dev scrot
#RUN pip3 -q install pyautogui

FROM ibc as ibc_vnc

RUN apt-get install -y x11vnc
COPY ./vnc/xvfb_init /etc/init.d/xvfb
RUN  chmod 755 /etc/init.d/xvfb
# install VNC
COPY ./vnc/vnc_init /etc/init.d/vnc
COPY ./vnc/xvfb-daemon-run /usr/bin/xvfb-daemon-run
RUN chmod 755 /usr/bin/xvfb-daemon-run \
 && chmod 755 /etc/init.d/vnc



FROM ibc_vnc as tws

# version can be stable, latest, or beta; arch can be x64 or x86
ARG version=latest
ARG arch=x64

# configure a dedicated user
ARG RUN_USER=docker
ARG RUN_USER_UID=1000
ARG RUN_USER_GID=1000

# ARG jre=/usr/local/openjdk-8/jre
ARG jre=/usr/lib/jvm/java-8-openjdk-arm64/jre/

# RUN mv /root/Jts . \
#  && unlink /usr/local/bin/ibgateway \
#  && ln -s Jts/ibgateway/978/ibgateway /usr/local/bin/ibgateway
#
# RUN mv /opt/IBController .
#

#RUN chmod a+x /tmp/ibgateway-stable-standalone-linux-x64.sh \
# && yes n | /tmp/ibgateway-stable-standalone-linux-x64.sh
ARG tws_url=https://download2.interactivebrokers.com/installers/tws

RUN groupadd -g $RUN_USER_GID ${RUN_USER} && \
    useradd -ms /bin/bash -u $RUN_USER_UID -g $RUN_USER_GID ${RUN_USER}

USER ${RUN_USER}
WORKDIR /tmp
# Fetch and deploy the install4j package IB makes available
RUN curl -s -O ${tws_url}/$version/tws-$version-linux-$arch.sh \
    && chmod +x tws-$version-linux-$arch.sh \
    && sed -i '170s/return/echo ignoring/' tws-$version-linux-$arch.sh \
    && sed -n 90,180p /tmp/tws-$version-linux-$arch.sh

RUN mkdir -p /home/${RUN_USER}
WORKDIR /home/${RUN_USER}

# RUN pwd && ls -l && java -version && ls ${jre} \
#     && sed -n 90,180p /tmp/tws-$version-linux-$arch.sh

RUN export INSTALL4J_JAVA_HOME=${jre} \
    && export INSTALL4J_JAVA_HOME_OVERRIDE=${jre} \
    && /tmp/tws-$version-linux-$arch.sh -q \
    && rm /tmp/tws-$version-linux-$arch.sh

RUN mkdir Jts/1011 && cp -R tws/jars Jts/1011/
RUN pwd && find . \
    && grep test_jvm * -R -l | xargs sed -i '170s/return/echo ignoring/'

RUN echo "export INSTALL4J_JAVA_HOME=${jre}" > .bashrc
# Below files copied during build to enable operation without volume mount
COPY ib/IBController.ini.template IBController/IBController.ini
COPY ./ib/jts.ini Jts/jts.ini

# RUN cp .install4j tws/.install4j/updater.log

# Add a few variables to ensure memory management in a container works
# correctly and raise memory limit to 1.5GB.
# Force anti-aliasing to LCD as JRE relies on xsettings, which are
# not present inside the container.
RUN echo " \n\
# Force LCD anti-aliasing \n\
-Dawt.useSystemAAFontSettings=lcd \n\
# Respect container memory limits \n\
-XX:+UnlockExperimentalVMOptions \n\
-XX:+UseCGroupMemoryLimitForHeap \n\
# Increase heap allocations \n\
-Xmx1536m \n\
" >> Jts/1011/tws.vmoptions

# #RUN apt-get install -y socat software-properties-common iproute2

# RUN  apt-get remove -y wget unzip
# RUN  apt-get clean && apt-get autoclean

# adjust to run as non-root

COPY ./dstrader/runtime dstrader
RUN pwd && ls -la dstrader
COPY runscript.sh runscript.sh

USER root

RUN chmod 755 runscript.sh dstrader/daily_run.sh
RUN chown ${RUN_USER}:${RUN_USER} /home/${RUN_USER} -R

# COPY fonts/* /home/${RUN_USER}/.fonts/
# RUN fc-cache

USER ${RUN_USER_UID}

# IB TWS 954 and later can listen on port 7496 (live API) and 7497 (paper API)
# This functionality is disabled by default in TWS configuration
EXPOSE 7496
EXPOSE 7497
EXPOSE 5900
EXPOSE 5901

export DISPLAY=:0
sudo mkdir /root/.vnc
sudo x11vnc -storepasswd "1234" /root/.vnc/passwd > /dev/null
sudo /usr/bin/Xvfb :0 -ac -screen 0 1280x1024x16 +extension RANDR &
sudo /usr/bin/x11vnc -forever -rfbport 5900 -rfbauth /root/.vnc/passwd -o /root/.vnc/x11vnc.log -display :0 &

# add_class_path "/usr/share/openjfx/lib/javafx.base.jar"
# add_class_path "/usr/share/openjfx/lib/javafx.controls.jar"
# add_class_path "/usr/share/openjfx/lib/javafx.fxml.jar"
# add_class_path "/usr/share/openjfx/lib/javafx.graphics.jar"
# add_class_path "/usr/share/openjfx/lib/javafx.media.jar"
# add_class_path "/usr/share/openjfx/lib/javafx.swing.jar"
# add_class_path "/usr/share/openjfx/lib/javafx.web.jar"
USER root

# DEBUG TOOLS
RUN apt-get -yq install \
    procps vim iputils-ping
# needed by xvfb: RUN rm /usr/lib/aarch64-linux-gnu/mesa/libGL.so.1

# USER ${RUN_USER}

# #CMD bash runscript.sh
CMD bash