FROM fedora
MAINTAINER tschloss@redhat.com

# add volume for web content
VOLUME /var/www/html

# install everything necessary
RUN dnf install -y nginx && \
    dnf clean all

# required files
ADD files /root/files

# configure the container
RUN cp /root/files/nginx.conf /etc/nginx/nginx.conf && \
    mkdir -p /var/www/html

# default command is starting nginx server
CMD [ "nginx" ]

