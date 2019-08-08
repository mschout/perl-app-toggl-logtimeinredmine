FROM mschout/perl-moosex-app-plugin-configxdg:latest

COPY . /usr/src
WORKDIR /usr/src

RUN && cpanm -q --skip-satisfied --installdeps . \
    && perl Makefile.PL \
    && make install \
    && rm -rf $HOME/.cpanm \
    && rm -rf /usr/src/* \
