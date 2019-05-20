FROM ubuntu:19.04

ENV JMETER_HOME /usr/local/apache-jmeter-5.1.1
#ENV IP 127.0.0.1
ENV RMI_PORT 1099
ENV LOCAL_PORT 50000

RUN apt-get -qq update && \
    apt-get -yqq install openjdk-8-jre-headless unzip && \
    apt-get -q clean && \
    rm -rf /var/lib/apt/lists/*

#RUN if [ ! -d "tmp" ]; then \
#    RUN mkdir tmp \
#fi
#RUN if [ ! -d "jmeterSetup" ]; then \
#    RUN mkdir jmeterSetup \
#fi
RUN mkdir /tmp/jmeterSetup
RUN chmod 777 -R tmp/jmeterSetup

COPY jmeterSetup.tar.gz  /tmp/jmeterSetup   

RUN tar -xzvf /tmp/jmeterSetup/jmeterSetup.tar.gz -C /usr/local && \
    apt-get -yqq autoremove && \
    rm -rf /tmp/jmeterSetup

ENV PATH $PATH:$JMETER_HOME/bin

WORKDIR $JMETER_HOME

#EXPOSE $RMI_PORT

#EXPOSE $LOCAL_PORT

COPY test.jmx /
COPY jmeter.prop /
COPY jmeterData.csv /

RUN chmod 777 -R /test.jmx
RUN chmod 777 -R /jmeter.prop
RUN chmod 777 -R /jmeterData.csv
#COPY rmi_keystore.jks /
#COPY entrypoint.sh /
#RUN chmod 777 -R .

RUN chmod 777 -R $JMETER_HOME
RUN export JVM_ARGS="-Xmn512m -Xms512m -Xmx512m"

#ENTRYPOINT ["/entrypoint.sh"]