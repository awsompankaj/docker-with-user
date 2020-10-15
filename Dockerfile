FROM ubuntu:18.04

MAINTAINER Pankaj Sharma

RUN apt-get update \
    && apt-get install -y nginx \
    && apt-get clean \
    && apt-get install -y  openssh-server  sudo telnet vim git nano python3 python3-pip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY requirement.txt /tmp/
RUN pip3 install -r /tmp/requirement.txt

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G www-data,users,sudo,root -d /home/bi --shell /bin/bash -m bi
USER root
ENV LANG en_GB.UTF-8
ENV LANG en_US.UTF-8
USER bi
WORKDIR /home/bi
ENV HOME /home/bi
RUN for f in "/home/bi" "/etc/passwd" "/etc/group" "/home/bi"; do\
           sudo chgrp -R 0 ${f} && \
           sudo chmod -R g+rwxXs ${f}; \
        done && \
        sudo chmod -R g+rwxXs /home/bi && \
        # Generate passwd.template \
        cat /etc/passwd | \
        sed s#bi:x.*#bi:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/bash#g \
        > /home/bi/passwd.template && \
        # Generate group.template \
        cat /etc/group | \
        sed s#root:x:0:#root:x:0:0,\${USER_ID}:#g \
        > /home/bi/group.template && \
        sudo sed -ri 's/StrictModes yes/StrictModes no/g' /etc/ssh/sshd_config

EXPOSE 80
EXPOSE 443


CMD ["sudo", "nginx", "-g", "daemon off;"]
