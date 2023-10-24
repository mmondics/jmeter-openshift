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
# TODO make this run as non-root
USER root

RUN cd /opt \
    && apt update && apt install wget \
    && wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
    && tar xzf apache-jmeter-${JMETER_VERSION}.tgz \
    && rm apache-jmeter-${JMETER_VERSION}.tgz

# Create a symlink to the JMeter process in a normal bin directory
RUN ln -s /opt/apache-jmeter-${JMETER_VERSION}/bin/jmeter /usr/local/bin

# Copy JMeter script and required files
RUN mkdir /test-plan
ADD test-plan/ /test-plan
RUN mv /test-plan/libraries/* /opt/apache-jmeter-${JMETER_VERSION}/lib/ext
RUN mv /test-plan/jmeter.properties /opt/apache-jmeter-${JMETER_VERSION}/bin/jmeter.properties

# Create a symlink to the JMeter script mounted by configmap
RUN ln -s /etc/jmeter-driver/test-plan.jmx /test-plan

# Indicate the default command to run
CMD jmeter -n -t /test-plan/test-plan.jmx -DusePureIDs=true -JUSER=9999 -JHOST=$HOST -JPORT=$PORT -JTHREAD=$THREAD -JRAMP=$RAMP -JDELAY=$DELAY -j /test-plan/jMeter-log