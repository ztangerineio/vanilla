# Create a perpetual instance of nvidia/cuda:12.1.1-devel-ubuntu22.04
## Base image for LLM development wtih GPU support
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

## Get a list of packages installed at origin, and save it to a file
RUN touch /tmp/.pre.origin-installed_packages.txt && \
    dpkg --get-selections > /tmp/.pre.origin-installed_packages.txt

## Update the package repository, auto-remove any unnecessary dependencies, and install first batch of essentials
RUN apt update && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt-get install -y \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    gcc \
    wget \
    sudo \
    apt-utils \
    curl \
    gnupg \
    openssl \
    ufw \
    nano \
    nvidia-cuda-toolkit \
    ocl-icd-opencl-dev opencl-headers clinfo \
    libclblast-dev libopenblas-dev && \
    mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

## Enter the usr and make room for your llm
RUN groupadd -r flynn && \
    mkdir -p /home/flynn/.local/bin && \
    useradd -r -g flynn flynn && \
    chsh -s /bin/bash flynn && \
    chown -R flynn:flynn /home/flynn && \
    chmod -R 700 /home/flynn && \
    usermod -aG sudo flynn && \
    usermod -aG root flynn && \
    openssl rand -base64 32 > /home/flynn/.password && \
    echo "flynn:$(cat /home/flynn/.password)" | chpasswd && \
    chmod 600 /home/flynn/.password && \
    echo "flynn ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    ulimit -c 0 && \
    ulimit -n 1024

# setting build related env vars
ENV CUDA_DOCKER_ARCH=all
ENV LLAMA_CUBLAS=1

# Install depencencies
RUN python3 -m pip install --upgrade pip pytest cmake scikit-build setuptools fastapi uvicorn sse-starlette pydantic-settings starlette-context huggingface-hub[cli] ctransformers[cuda]

# Install llama-cpp-python (build with cuda) - this must be done in the virtual environment
# RUN CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install llama-cpp-python --no-cache-dir

## Get a list of packages installed at origin, and save it to a file
RUN touch /tmp/.post.origin-installed_packages.txt && \
    dpkg --get-selections > /tmp/.post.origin-installed_packages.txt

## Set the default shell, generate an `openssl` password, `chpasswd`, for `root`, and secure access to `.password`.
RUN chsh -s /bin/bash root && \
    openssl rand -base64 32 > /root/.password && \
    echo "root:$(cat /root/.password)" | chpasswd && \
    chmod 600 /root/.password

## Copy your home files and directories to the usr
COPY --chown=flynn:flynn . /home/flynn

## Set the working directory to the usr's home directory
WORKDIR /home/flynn

## Set the default user to `flynn`
USER flynn

## Set the default shell to `bash`
SHELL ["/bin/bash", "-c"]

## Set the entrypoint to `bash`
ENTRYPOINT ["/bin/bash", "/home/flynn/.init.d/entrypoint.sh"]
# EOF