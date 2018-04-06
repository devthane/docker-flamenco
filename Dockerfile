FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y build-essential software-properties-common \
    python-software-properties curl && add-apt-repository ppa:deadsnakes/ppa && \
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh && bash nodesource_setup.sh && \
    rm nodesource_setup.sh && apt install -y git nodejs python3.6-dev python-pip mongodb-clients curl virtualenv \
    redis-tools netcat screen && pip install --upgrade pip && rm -rf /var/lib/apt/lists/*

RUN mkdir ~/envs && virtualenv -p $(which python3.6) ~/envs/flamenco

RUN mkdir /data && cd /data && git clone git://git.blender.org/flamenco.git && \
    git clone git://git.blender.org/pillar.git && git clone git://git.blender.org/pillar-python-sdk.git

COPY layout.pug /data/pillar/src/templates/layout.pug

RUN /bin/bash -c "source ~/envs/flamenco/bin/activate && cd /data/flamenco && pip install -r requirements-dev.txt && \
    pip install -e . && npm install && node node_modules/gulp/bin/gulp && cd /data/pillar && pip install -e . && \
    npm install && node node_modules/gulp/bin/gulp && cd /data/pillar-python-sdk && pip install -e ."

COPY config_local.py /data/flamenco/config_local.py
COPY manage.py /data/flamenco/manage.py
COPY runserver.py /data/flamenco/runserver.py
COPY run.sh /data/flamenco/run.sh

RUN mkdir -p /tmp/output

WORKDIR /data/flamenco

CMD bash ./run.sh
