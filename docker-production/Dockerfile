FROM zeroc0d3/nginx-unicorn-rails:1.10.3-2.4.1

# (Optional) Use gem data volume
# Create via: docker create -v /ruby_gems/2.4.1 --name gems-2.4.1 busybox
ENV GEM_HOME /ruby_gems/2.4.1
ENV PATH /ruby_gems/2.4.1/bin:$PATH

# (Optional) Set custom Nginx site configuration (if you have any)
ADD nginx/production.conf /etc/nginx/sites-enabled/default

# Automatically start the web server
CMD bundle install && \
    bundle exec rake assets:precompile && \
    foreman start -f Procfile

# Automatically start the web server
CMD ./script/start.sh

EXPOSE 80