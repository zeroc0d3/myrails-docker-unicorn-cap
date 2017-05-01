FROM zeroc0d3/ubuntu-ruby:2.4.1

MAINTAINER ZeroC0D3 Team <zeroc0d3.0912@gmail.com>

# Install dependencies
RUN apt-get update && \
    apt-get install -qq -y nodejs software-properties-common

# Install Nginx.
RUN add-apt-repository -y ppa:nginx/stable && apt-get update && \
    apt-get install -qq -y nginx=1.10.3-0+xenial0 \

# Install SSHd
    openssh-server openssh-client && \    

    # Cleanup
    apt-get clean && \
    cd /var/lib/apt/lists && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

# Turn off nginx and set owner
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

# Set Nginx site configuration
ADD nginx/development.conf /etc/nginx/sites-enabled/default

# Install DB libs
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes libpq-dev libmysqlclient-dev && \

    # Cleanup
    apt-get clean && \
    cd /var/lib/apt/lists && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

# Install & configure SSH
# Default ssh root password: secret
RUN mkdir -p /var/run/sshd
RUN echo 'root:secret' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

# SSH public key
RUN mkdir -p /root/.ssh
RUN chmod 700 /root/.ssh
RUN touch /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

COPY key/id_rsa /root/.ssh/id_rsa
COPY key/id_rsa.pub /root/.ssh/id_rsa.pub
COPY key/id_rsa.pem /root/.ssh/id_rsa.pem

# (Optional) Use gem data volume
# Created from: docker create -v /ruby_gems/2.4.1 --name gems-2.4.1 busybox
ENV GEM_HOME /ruby_gems/2.4.1
ENV PATH /ruby_gems/2.4.1/bin:$PATH

# Install Rails App
WORKDIR /app
ADD . /app

# Automatically start the web server
CMD ./script/start.sh
EXPOSE 80 22
