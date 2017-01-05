# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/scipy-notebook

MAINTAINER Carolyn Ownby <carolyn@archethought.com>

USER root


# Spark and Mesos config
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:/usr/lib/python2.7/dist-packages
ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

# Spark dependencies
ENV APACHE_SPARK_VERSION 2.0.2
# 2.0.0: (shasum) 8A14410A906926D2593E45E1FFD7E26C4E9223DF94AD9902FC62CAD6B900A8FCC22944FB6E9DFC2C4B35066A7D0C1E676CE4D0DB35DEE36DAC2DEEA6B83C1F24
# 2.0.1: (md5sum) 43AA7C28B9670E65CB4F395000838860
# 2.0.2: (shasum) 9A1D19AB295D1252ECB0A4ADCAAF5F215A75DC7427597AF9A9475F0C0FE0A59713FF601E5C13ECE25ECCD67913167FAB85A04D1C104A51C027D4F39E2C414034


RUN apt-get -y update && \
    apt-get install -y --no-install-recommends openjdk-7-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
        wget -q http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz && \
        echo "9A1D19AB295D1252ECB0A4ADCAAF5F215A75DC7427597AF9A9475F0C0FE0A59713FF601E5C13ECE25ECCD67913167FAB85A04D1C104A51C027D4F39E2C414034 *spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz" | shasum -c - && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz


RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7 spark

# get latest py4j zip for both python 2 & 3
RUN pip2 install py4j
RUN pip install py4j

# Mesos dependencies
# Currently, Mesos is not available from Debian Jessie.
# So, we are installing it from Debian Wheezy. Once it
# becomes available for Debian Jessie. We should switch
# over to using that instead.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    DISTRO=debian && \
    CODENAME=wheezy && \
    echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-get -y update && \
    apt-get --no-install-recommends -y --force-yes install mesos=0.22.1-1.0.debian78 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# RSpark config
ENV R_LIBS_USER $SPARK_HOME/R/lib

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# R packages
RUN conda config --add channels r && \
    conda install --quiet --yes \
    'r-base=3.3*' \
    'r-irkernel=0.6*' \
    'r-ggplot2=2.1*' \
    'r-rcurl=1.95*' && conda clean -tipsy

# Apache Toree kernel
RUN pip --no-cache-dir install toree==0.1.0.dev7
RUN jupyter toree install --user

