FROM resin/rpi-raspbian:latest

# Update linux kernel per AWS Greengrass docs
RUN apt-get update && apt-get install rpi-update apt-utils -y
RUN sudo rpi-update b81a11258fc911170b40a0b09bbd63c84bc5ad59

# Install standard dependencies
RUN apt-get install unzip curl sqlite3 binutils cgroupfs-mount wget build-essential libssl-dev python2.7 -y

RUN ln -s $(which python2.7) /usr/bin/python

WORKDIR /app

# Install NodeJS via NVM
ENV NVM_DIR="/app/.nvm"
ADD https://raw.githubusercontent.com/creationix/nvm/master/install.sh /app/nvm-install.sh
RUN bash /app/nvm-install.sh \
	&& [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
	&& nvm install v6.10 \
	&& ln -s $(nvm which v6.10) /usr/bin/nodejs6.10

# Install Oracle JDK 8
RUN wget --no-check-certificate --quiet -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-arm32-vfp-hflt.tar.gz
RUN mkdir /usr/java
RUN tar -zxf jdk-8u151-linux-arm32-vfp-hflt.tar.gz -C /usr/java
RUN sudo update-alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_151/bin/java 1000
RUN sudo update-alternatives --install /usr/bin/javac javac /usr/java/jdk1.8.0_151/bin/javac 1000
RUN sudo ln -s /usr/bin/java /usr/bin/java8

# Install ARM7 Greengrass for RPi
ADD resin/greengrass-linux-armv7l-1.3.0.tar.gz /app/

# Add greengrassd to the path
ENV PATH="/app/greengrass/ggc/core:${PATH}"

# Download Symantec root CA
ADD http://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem /app/greengrass/certs/root.ca.pem

# Mount cgroup directories
# This fails when building the Dockerfile, but cgroup subsystems are available when running this container on the Raspberry Pi
# RUN sudo cgroupfs-mount

# Add ggc_user and _group
RUN sudo adduser --system ggc_user
RUN sudo addgroup --system ggc_group

RUN nodejs6.10 --version
RUN java8 -version
RUN python2.7 --version

# Check dependencies to make sure we're A-OK
# cgroup checks fail when building the Dockerfile locally, but pass when this image is started on a Raspberry Pi (3)
#ADD https://raw.githubusercontent.com/aws-samples/aws-greengrass-samples/master/greengrass-dependency-checker-GGCv1.3.0.zip /app/greengrass-dependency-checker.zip
#RUN cd /app && unzip greengrass-dependency-checker.zip && cd greengrass-dependency-checker-GGCv1.3.0 && ./check_ggc_dependencies

# Configure greengrassd and start
CMD ["nodejs6.10", "start-greengrass.js"]