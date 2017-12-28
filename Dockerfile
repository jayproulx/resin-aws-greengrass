FROM resin/rpi-raspbian:latest

RUN apt-get update && apt-get install curl -y

RUN mkdir /app
COPY resin/greengrass-linux-armv7l-1.3.0.tar.gz /app/greengrass.tar.gz
RUN cd /app && tar -zxf greengrass.tar.gz

RUN curl http://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem > /app/greengrass/certs/root.ca.pem

ENV PATH="/app/greengrass/ggc/core:${PATH}"

CMD ["greengrassd", "start"]