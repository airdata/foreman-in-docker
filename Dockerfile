FROM ubuntu:16.04
MAINTAINER Rumen LISHKOV "rlishkov@ingimax.com"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV FOREOPTS --foreman-locations-enabled=true \
  --enable-foreman-compute-ec2
RUN apt update && apt-get install -y ca-certificates wget nano net-tools locales && \
locale-gen en_US.UTF-8 && \
wget https://apt.puppetlabs.com/puppet5-release-xenial.deb && \
dpkg -i puppet5-release-xenial.deb  && \
echo "deb http://deb.theforeman.org/ xenial 1.16" > /etc/apt/sources.list.d/foreman.list && \
echo "deb http://deb.theforeman.org/ plugins 1.16" >> /etc/apt/sources.list.d/foreman.list && \
wget -q https://deb.theforeman.org/pubkey.gpg -O- | apt-key add -
RUN apt-get update && apt-get -y install foreman-installer foreman-postgresql && \
rm -f /usr/share/foreman-installer/checks/hostname.rb && \
export FACTER_fqdn="foreman.lab" && \
echo "127.0.0.1  foreman.lab" >> /etc/hosts && \
echo "Running foreman installer" && \
    (/usr/sbin/foreman-installer $FOREOPTS || /bin/true) && \
sed -i -e "s/START=no/START=yes/g" /etc/default/foreman && \
sed -i -e "s/:require_ssl: true/:require_ssl: false/g" /etc/foreman/settings.yaml
COPY start.sh /
ADD ssl /etc/puppetlabs/puppet/ssl
RUN chmod 700 /start.sh && \
  chown -R puppet:puppet /etc/puppetlabs/puppet/
ENTRYPOINT /bin/bash /start.sh
