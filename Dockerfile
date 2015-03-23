###############################################################
#
# Dockerfile to build an image with the necessary dependencies
# to use Echoprint server and codegen. (26-11-2014)
#
###############################################################

FROM ubuntu:14.04
MAINTAINER Bruno Dias <bruno.filipe.silva.dias@gmail.com>

RUN mkdir /home/audio-fingerprinting

RUN sudo apt-get update	
RUN sudo apt-get install -y wget
RUN sudo apt-get install -y zlib1g-dev
RUN sudo apt-get install -y libbz2-dev
RUN sudo apt-get install -y git
RUN sudo apt-get install -y python-setuptools
RUN sudo easy_install web.py
RUN sudo easy_install pyechonest
RUN sudo apt-get install -y libboost1.55-dev
RUN sudo apt-get install -y libtag1-dev
RUN sudo apt-get install -y zlib1g-dev
RUN sudo apt-get install -y software-properties-common
RUN sudo apt-get install -y python-software-properties
RUN sudo apt-add-repository -y ppa:jon-severinsson/ffmpeg
RUN sudo apt-get update
RUN sudo apt-get install -y ffmpeg
RUN sudo apt-get install -y g++
RUN sudo apt-get install -y openjdk-7-jdk


EXPOSE 8080

WORKDIR /home/audio-fingerprinting/
RUN wget http://sourceforge.net/projects/tokyocabinet/files/tokyocabinet/1.4.32/tokyocabinet-1.4.32.tar.gz
RUN tar xvf tokyocabinet-1.4.32.tar.gz
WORKDIR tokyocabinet-1.4.32
RUN sudo mkdir /usr/local/tokyocabinet/
RUN ./configure --prefix=/usr/local/tokyocabinet/
RUN sudo apt-get install -y make
RUN make
RUN sudo make install



WORKDIR /home/audio-fingerprinting/
RUN wget http://sourceforge.net/projects/tokyocabinet/files/tokyotyrant/1.1.33/tokyotyrant-1.1.33.tar.gz
RUN tar xvf tokyotyrant-1.1.33.tar.gz
WORKDIR tokyotyrant-1.1.33
RUN sudo mkdir /usr/local/tokyotyrant
RUN ./configure --prefix=/usr/local/tokyotyrant/ --with-tc=/usr/local/tokyocabinet/
RUN make
RUN sudo make install
WORKDIR /usr/local/tokyotyrant/
RUN sudo ln -s /usr/local/tokyocabinet/lib/libtokyocabinet.so.8 lib



WORKDIR /home/audio-fingerprinting/
RUN git clone git://github.com/echonest/echoprint-server.git
RUN echo "java -Dsolr.solr.home=$PWD/echoprint-server/solr/solr/solr/ -Djava.awt.headless=true -jar start.jar" > start_solr_server.sh
RUN echo "/usr/local/tokyotyrant/bin/ttserver" > start_tokyo_server.sh
RUN echo "python $PWD/echoprint-server/API/api.py 8080" > start_web_api.sh



RUN git clone https://github.com/echonest/echoprint-codegen.git
WORKDIR /home/audio-fingerprinting/echoprint-codegen/src
RUN make
WORKDIR /home/audio-fingerprinting/echoprint-codegen/
RUN ln -s $PWD/echoprint-codegen /usr/local/bin
WORKDIR /home/audio-fingerprinting/



RUN sudo apt-get autoremove