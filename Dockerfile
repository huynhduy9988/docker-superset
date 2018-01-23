FROM python:2.7.13-slim
ENV DEBIAN_FRONTEND noninteractive

ARG REGION
ARG CN_MIRROR='\
deb http://mirrors.163.com/debian/ jessie main non-free contrib\n\
deb http://mirrors.163.com/debian/ jessie-updates main non-free contrib\n\
deb http://mirrors.163.com/debian/ jessie-backports main non-free contrib\n\
deb-src http://mirrors.163.com/debian/ jessie main non-free contrib\n\
deb-src http://mirrors.163.com/debian/ jessie-updates main non-free contrib\n\
deb-src http://mirrors.163.com/debian/ jessie-backports main non-free contrib\n\
deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib\n\
deb-src http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib\n\
'
RUN if [ "${REGION}" = "cn" ]; then echo ${CN_MIRROR} > /etc/apt/sources.list; fi

# Install nodejs and yarn
ARG BUILD_DEPS='apt-utils apt-transport-https curl git'
RUN apt-get -y update && apt-get -y install ${BUILD_DEPS}
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get -y update && apt-get install -y yarn
RUN if [ "${REGION}" = "cn" ]; then yarn config set registry https://registry.npm.taobao.org; fi

# prepare superset depandences
ARG DEPS='build-essential libssl-dev libffi-dev python-dev libsasl2-dev libldap2-dev'
RUN apt-get -y install ${DEPS}
RUN pip install --upgrade setuptools pip

# clone superset from github
WORKDIR /usr/local
ARG SUPERSET_VERSION=master
RUN git clone -b ${SUPERSET_VERSION} https://github.com/apache/incubator-superset.git
RUN pip install ${PIP_DEPS}
RUN pip install -e incubator-superset

# init superset
RUN fabmanager create-admin --app superset --username admin --password admin --firstname admin --lastname admin --email admin@fab.org
RUN superset db upgrade
RUN superset load_examples
RUN superset init

# build js
WORKDIR /usr/local/incubator-superset/superset/assets
RUN yarn && yarn run build
# todo: starts with mapbox token

WORKDIR /root

# remove dependent packages if on production
# RUN apt-get remove --purge -y ${BUILD_DEPS} nodejs yarn
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# RUN rm -rf /usr/local/incubator-superset/superset/assets/node_modules

EXPOSE 8088
ENTRYPOINT ["superset"]
