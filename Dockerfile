# Base Image
FROM amazonlinux:2018.03
CMD ["/bin/bash"]

# Maintainer
MAINTAINER ProcessMaker CloudOps <cloudops@processmaker.com>
ENV PROCESSMAKER_VERSION 3.4.11
# Extra
LABEL version="3.4.11"
LABEL description="ProcessMaker 3.4.7 Docker Container."

# Declare ARGS and ENV Variables
ARG URL
ENV URL $URL

# Initial steps
RUN yum clean all && yum install epel-release -y && yum update -y
RUN cp /etc/hosts ~/hosts.new && sed -i "/127.0.0.1/c\127.0.0.1 localhost localhost.localdomain `hostname`" ~/hosts.new && cp -f ~/hosts.new /etc/hosts

# Required packages
RUN yum install \
  wget \
  vim \
  nano \
  sendmail \
  nginx \
  mysql56 \
  php71-fpm \
  php71-opcache \
  php71-gd \
  php71-mysqlnd \
  php71-soap \
  php71-mbstring \
  php71-ldap \
  php71-mcrypt \
  -y

# Download ProcessMaker Enterprise Edition

#ADD "processmaker-${PROCESSMAKER_VERSION}-community.tar.gz" /opt/
RUN mkdir -p /opt && wget https://downloads.sourceforge.net/project/processmaker/ProcessMaker/${PROCESSMAKER_VERSION}/processmaker-${PROCESSMAKER_VERSION}-community.tar.gz -P /opt && \
  tar xzvf /opt/processmaker-${PROCESSMAKER_VERSION}-community.tar.gz && rm -rf /opt/processmaker-${PROCESSMAKER_VERSION}-community.tar.gz
# Copy configuration files
COPY processmaker-fpm.conf /etc/php-fpm.d
RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bk
COPY nginx.conf /etc/nginx
COPY processmaker.conf /etc/nginx/conf.d

# NGINX Ports
EXPOSE 80

# Docker entrypoint
COPY docker-entrypoint.sh /bin/
RUN chmod a+x /bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]