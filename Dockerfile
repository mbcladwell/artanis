FROM        debian:sid-slim
MAINTAINER  Mu Lei
ENV         LANG C.UTF-8
ADD         sources.list /etc/apt/
RUN     apt-get update \
        && apt-config dump | grep -we Recommends -e Suggests | sed s/1/0/ | tee /etc/apt/apt.conf.d/99norecommend \
        && apt-get install --no-install-recommends -y texinfo guile-3.0 guile-3.0-dev build-essential automake git autoconf libtool default-libmysqlclient-dev libmariadbd-dev libnss3 libnss3-dev redis redis-server gettext libcurl4-nss-dev \
        && rm -rf /var/lib/apt/lists/* \
	&& git config --global http.sslverify false

ARG CACHE_DBI=1
RUN set -ex \
        && git clone --depth 1 https://github.com/opencog/guile-dbi.git \
        && cd guile-dbi/guile-dbi && ./autogen.sh && ./configure && make -j \
        && make install && ldconfig && cd .. \
        \
        && cd guile-dbd-mysql \
        && ./autogen.sh && ./configure && make -j \
        && make install && ldconfig && cd ../../ && rm -fr guile-dbi

ARG CACHE_CURL=1
RUN set -ex \
         && git clone --depth 1 https://github.com/spk121/guile-curl.git \
         && cd guile-curl && ./bootstrap && ./configure --prefix=/usr && make -j \ 
         && make install \
         && ln -s /usr/lib/guile/3.0/extensions/libguile-curl.* /usr/lib/ \
         && ldconfig

ARG CACHE_ARTANIS=1
RUN     git clone --depth 1 --single-branch --branch master git://git.savannah.gnu.org/artanis.git \
        && cd artanis \
	&& ./autogen.sh \
	&& ./configure \
	&& make -j \
        && make install && cd .. && rm -fr artanis
