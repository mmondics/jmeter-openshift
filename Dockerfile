# build on the top of Java image
FROM open-liberty:latest

# JMeter Version
ARG JMETER_VERSION="5.5"
ARG HOST=$HOST
ARG PORT=$PORT
ARG THREAD=$THREAD
ARG RAMP=$RAMP
ARG DELAY=$DELAY

# Download and unpack the JMeter tar file
USER root

RUN cd /opt \
    && apt update && apt install wget \
    && wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
    && tar xzf apache-jmeter-${JMETER_VERSION}.tgz \
    && rm apache-jmeter-${JMETER_VERSION}.tgz

# Create a symlink to the jmeter process in a normal bin directory
RUN ln -s /opt/apache-jmeter-${JMETER_VERSION}/bin/jmeter /usr/local/bin

# Copy acmeair jmeter script and required files
RUN mkdir /driver
ADD script/ /driver
RUN mv /driver/acmeair-jmeter-2.0.0-SNAPSHOT.jar /opt/apache-jmeter-${JMETER_VERSION}/lib/ext && \
    mv /driver/json-simple-1.1.1.jar /opt/apache-jmeter-${JMETER_VERSION}/lib/ext

# Create a symlink to the jmeter script mounted by configmap
RUN ln -s /etc/jmeter-driver/AcmeAir-microservices.jmx /driver

# Copying custom property file
COPY ./script/jmeter.properties /opt/apache-jmeter-${JMETER_VERSION}/bin/jmeter.properties

# Indicate the default command to run
CMD jmeter -n -t /driver/test-plan.jmx -DusePureIDs=true -JUSER=9999 -JHOST=$HOST -JPORT=$PORT -JTHREAD=$THREAD -JRAMP=$RAMP -JDELAY=$DELAY -j /driver/jMeter-log