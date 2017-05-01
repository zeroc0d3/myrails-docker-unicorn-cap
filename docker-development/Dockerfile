FROM zeroc0d3/nginx-unicorn-rails:1.10.3-2.4.1

# Install ruby dependencies
ONBUILD RUN apt-get update && \
    apt-get install -y openssh-server openssh-client && \

    # Cleanup
    apt-get clean && \
    cd /var/lib/apt/lists && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

# (Optional) Use gem data volume
# Created from: docker create -v /ruby_gems/2.4.1 --name gems-2.4.1 busybox
ENV GEM_HOME /ruby_gems/2.4.1
ENV PATH /ruby_gems/2.4.1/bin:$PATH

# Install & configure SSH
COPY sshd_config /etc/ssh/sshd_config

# Default ssh root password: secret
ONBUILD CMD mkdir -p /var/run/sshd
ONBUILD RUN echo 'root:secret' | chpasswd
ONBUILD RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
ONBUILD RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ONBUILD ENV NOTVISIBLE "in users profile"
ONBUILD RUN echo "export VISIBLE=now" >> /etc/profile

# Running SSHd services
ONBUILD CMD ["/usr/sbin/sshd", "-D"]

# SSH public key
CMD mkdir -p /root/.ssh
COPY key/id_rsa /root/.ssh/id_rsa
COPY key/id_rsa.pub /root/.ssh/id_rsa.pub
COPY key/id_rsa.pem /root/.ssh/id_rsa.pem

# Set Nginx site configuration
ADD nginx/development.conf /etc/nginx/sites-enabled/default

# Automatically start the web server
CMD ./script/start.sh

EXPOSE 80 22
