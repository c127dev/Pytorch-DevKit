FROM ubuntu:jammy

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install generic dependencies and Python 3.10
RUN apt update\
    && apt install -y --no-install-recommends curl ca-certificates gpg gpg-agent dirmngr\
    && echo "deb [signed-by=/etc/apt/keyrings/deadsnakes-ppa.gpg] http://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" | tee /etc/apt/sources.list.d/deadsnakes-ppa.list\
    && mkdir -p /root/.gnupg/\
    && gpg --no-default-keyring --keyring /etc/apt/keyrings/deadsnakes-ppa.gpg --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys BA6932366A755776\
    && rm -rf /root/.gnupg/\
    && apt update\
    && apt install -y --no-install-recommends python3.10 python3-pip python3-venv\
    && apt install -y --no-install-recommends sudo git neovim btop gosu software-properties-common tzdata libportaudio2 libasound-dev build-essential python3-dev iproute2 ffmpeg libsm6 libxext6\
    && apt upgrade -y\
    && apt clean\
    && rm -rf /var/lib/apt/lists/*\
    && cd /usr/bin&&\
    ln -s python3 python

# Setup unprivileged app user
RUN groupadd -g 1000 app\
    &&useradd -u 1000 -g 1000 -m -s /bin/bash app\
    &&usermod -aG sudo app\
    &&printf "app\napp" | passwd app\
    &&mkdir /app\
    &&chown app:app /app\
    &&chmod 750 /app

# Setup Python
USER app
WORKDIR /home/app
RUN bash -c "mkdir /home/app/venv\
    && python3 -m venv /home/app/venv\
    && source /home/app/venv/bin/activate\
    && pip install torch==2.5.0+rocm6.2 torchvision==0.20.0+rocm6.2 torchaudio==2.5.0+rocm6.2 --extra-index-url https://download.pytorch.org/whl/rocm6.2\
    && pip install pip==24.0\
    && pip install tqdm==4.67.1 resampy==0.4.3 fairseq==0.12.2 omegaconf==2.0.6 einops==0.7.0 numpy pyyaml pyworld torchcrepe Pillow"

RUN rm -rf /home/app/venv