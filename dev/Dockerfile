FROM ubuntu:14.04

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y \
  build-essential \
  libc6:i386 \
  libncurses5:i386 \
  libstdc++6:i386 \
  git \
  cmake \
  vim \
  tmux \
  python-dev \
  global \
  autoconf \
  automake \
  pkg-config \
  libevent-dev \
  libncurses5-dev \
  exuberant-ctags \
  curl \
  software-properties-common \
  python-software-properties

RUN add-apt-repository -y ppa:webupd8team/java

RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -

RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

run apt-get update && apt-get install -y \
  nodejs \
  oracle-java7-installer

COPY init.sh /tmp/
RUN /tmp/init.sh
