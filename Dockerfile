FROM perl:5.26

COPY . /usr/src/
WORKDIR /usr/src

#  RUN apt-get update \
    # && apt-get install -y build-essential \
RUN cd vendor/MooseX-App-Plugin-ConfigXDG \
    && cpanm --notest --skip-satisfied --installdeps . \
    && perl Makefile.PL \
    && make install \
    && cd /usr/src \
    && cpanm --notest --skip-satisfied --installdeps . \
    && perl Makefile.PL \
    && make install \
    && rm -rf $HOME/.cpanm \
    && rm -rf /usr/src
 
