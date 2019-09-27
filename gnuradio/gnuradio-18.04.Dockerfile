FROM ubuntu:18.04
LABEL maintainer=zleffke@vt.edu

# Run the configuration script to setup the repositories and update/install other packages
ADD config_gnuradio.sh /root/configure.sh
RUN bash /root/configure.sh

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
# Start the SSH daemon when running the container
CMD ["/usr/sbin/sshd", "-D"]
