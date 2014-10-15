FROM sameersbn/gitlab-ci-runner

MAINTAINER Andrew Fecheyr <andrew@bedesign.be>

# Let's add the wrapdocker and docker-in-docker magic so we can use docker inside the ci runner.
# From https://github.com/jpetazzo/dind

# Let's start with some basic stuff.
RUN apt-get update -qq
RUN apt-get install -qqy iptables ca-certificates lxc

# Install Docker from Docker Inc. repositories.
RUN apt-get install -qqy apt-transport-https
RUN echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
RUN apt-get update -qq
RUN apt-get install -qqy lxc-docker

# Install the magic wrapper.
ADD wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Must use a volume because AUFS cannot use an AUFS mount as a branch
# https://github.com/jpetazzo/dind#important-warning-about-disk-usage
VOLUME /var/lib/docker

# Setup supervisord which runs wrapdocker and the ci runner
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start supervisord
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

