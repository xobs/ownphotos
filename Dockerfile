FROM ubuntu:16.04
MAINTAINER Sean Cross <sean@xobs.io>

VOLUME /data

COPY . /code
WORKDIR /code

RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
    apt-get install -y \
    libsm6 \
    libboost-all-dev \
    libglib2.0-0 \
    libxrender-dev \ 
    python3-tk \
    libffi-dev \
    libssl-dev \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    curl \
    nginx \
    cmake git \
    libopenblas-dev liblapack-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install wheel && \
    /venv/bin/pip install cython && \
    /venv/bin/pip install https://download.pytorch.org/whl/cpu/torch-0.4.1-cp35-cp35m-linux_x86_64.whl && \
    /venv/bin/pip install torchvision && \
    /venv/bin/pip install spacy==2.0.16 && \
    /venv/bin/python -m spacy download en_core_web_sm && \
    /venv/bin/pip install https://github.com/owncloud/pyocclient/archive/78984391ded8b72dd0742c67968310a469b15063.zip && \
    echo "Building and installing dlib" && \
    (cd / && \
        git clone https://github.com/davisking/dlib.git && \
        mkdir /dlib/build && \
        cd /dlib/build && \
        cmake .. -DDLIB_USE_CUDA=0 -DUSE_AVX_INSTRUCTIONS=0 && \
        cmake --build . && \
        cd /dlib && \
        /venv/bin/python setup.py install --no USE_AVX_INSTRUCTIONS --no DLIB_USE_CUDA \
    ) && \
    /venv/bin/pip install -r requirements.txt && \
    (cd /code/api/places365 && \
        wget https://s3.eu-central-1.amazonaws.com/ownphotos-deploy/places365_model.tar.gz && \
        tar xf places365_model.tar.gz && \
        rm -f places365_model.tar.gz \
    ) && \
    (cd /code/api/im2txt && \
        wget https://s3.eu-central-1.amazonaws.com/ownphotos-deploy/im2txt_model.tar.gz && \
        tar xf im2txt_model.tar.gz && \
        rm -f im2txt_model.tar.gz && \
        wget https://s3.eu-central-1.amazonaws.com/ownphotos-deploy/im2txt_data.tar.gz && \
        tar xf im2txt_data.tar.gz && \
        rm -f im2txt_data.tar.gz) && \
    apt-get remove --purge -y cmake git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mv /code/config_docker.py /code/config.py

EXPOSE 80 3000 5000

ENV MAPZEN_API_KEY=mapzen-XXXX \
    MAPBOX_API_KEY=mapbox-XXXX \
    ALLOWED_HOSTS=* \
    ADMIN_EMAIL=admin@dot.com \
    ADMIN_USERNAME=admin \
    ADMIN_PASSWORD=changeme \
    SECRET_KEY=supersecretkey \
    DEBUG=true  \
    DB_BACKEND=postgresql \
    DB_NAME=ownphotos \
    DB_USER=ownphotos \
    DB_PASS=ownphotos \
    DB_HOST=database \
    DB_PORT=5432 \
    BACKEND_HOST=localhost \
    FRONTEND_HOST=localhost \
    REDIS_HOST=redis \
    REDIS_PORT=11211 \
    TIME_ZONE=UTC

ENTRYPOINT ./entrypoint.sh
