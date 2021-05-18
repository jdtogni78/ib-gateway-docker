FROM openjdk:16-slim

LABEL maintainer="jtogni78"

RUN  apt-get update
RUN  apt-get install -y wget unzip
RUN  apt-get install -y xvfb libxtst6 libxrender1 libxi6

# Setup IB TWS and IBController
RUN mkdir -p /tmp/ \
 && cd /tmp \
 && wget https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh \
 && wget -q https://github.com/IbcAlpha/IBC/releases/download/3.8.5/IBCLinux-3.8.5.zip

RUN chmod a+x /tmp/ibgateway-stable-standalone-linux-x64.sh \
 && yes n | /tmp/ibgateway-stable-standalone-linux-x64.sh

RUN mkdir -p /opt/IBController/ \
 && mkdir -p /opt/IBController/Logs \
 && cd /opt/IBController/ \
 && unzip /tmp/IBCLinux-3.8.5.zip \
 && chmod -R 755 *.sh \
 && chmod -R 755 scripts/*.sh

#RUN apt-get install -y socat software-properties-common iproute2

RUN rm /tmp/ibgateway-stable-standalone-linux-x64.sh \
 && rm /tmp/IBCLinux-3.8.5.zip
RUN  apt-get remove -y wget unzip

RUN  apt-get clean && apt-get autoclean

COPY ./vnc/xvfb_init /etc/init.d/xvfb
RUN  chmod 755 /etc/init.d/xvfb

# install VNC
#COPY ./vnc/vnc_init /etc/init.d/vnc
#COPY ./vnc/xvfb-daemon-run /usr/bin/xvfb-daemon-run
#RUN chmod 755 /usr/bin/xvfb-daemon-run \
#  && chmod 755 /etc/init.d/vnc
#RUN apt-get install -y x11vnc

# Below files copied during build to enable operation without volume mount
#COPY ib/IBController.ini.template /root/IBController/IBController.ini
#COPY ./ib/jts.ini /root/Jts/jts.ini

# DEBUG TOOLS
RUN apt-get install -y procps vim

# adjust to run as non-root
ARG uid=1000
ARG gid=1000
RUN groupadd -g $gid docker && useradd -ms /bin/bash -u $uid -g $gid docker
WORKDIR /home/docker

RUN mv /root/Jts . \
 && unlink /usr/local/bin/ibgateway \
 && ln -s Jts/ibgateway/978/ibgateway /usr/local/bin/ibgateway

RUN mv /opt/IBController .

COPY ./dstrader/runtime dstrader
RUN chmod 755 dstrader/daily_run.sh

COPY runscript.sh runscript.sh
RUN chmod 755 runscript.sh

RUN chown docker:docker . -R

USER docker

CMD bash runscript.sh
