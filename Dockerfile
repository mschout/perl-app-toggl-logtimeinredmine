FROM mschout/perl-moosex-app-plugin-configxdg:latest

COPY . /usr/src
WORKDIR /usr/src

RUN apt-get update \
    && apt-get install -y build-essential \
    && cpanm -q --notest --skip-satisfied --installdeps . \
    && perl Makefile.PL \
    && make install \
    && rm -rf $HOME/.cpanm \
    && rm -rf /usr/src/* \
    && apt-get remove -y build-essential \
    && apt-get autoremove -y \
    && rm -rf /var/cache/apt/*
