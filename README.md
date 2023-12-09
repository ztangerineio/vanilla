# A Vanilla Docker Container

## `LLM Application Development`

### Use this repository to build and run a new docker container for the development of LLM-based applications

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)

## Prerequisites

1. Ubuntu 22.04
2. Docker
   1. Docker installation instructions can be found at <https://docs.docker.com/engine/install/ubuntu/>
   2. Or, you can use the convenience script in this repo. (<https://github.com/ztangerineio/vanilla/blob/main/ubuntu-docker-installer.sh>)
3. A CUDA-capable GPU
4. Local docker environment and daemon prepped with nvidia container toolkit

### Preparing your local docker environment

```bash
# Import the GPG key for the NVIDIA container toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# Add the NVIDIA container toolkit repository to APT sources
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update APT repositories
sudo apt-get update

# Configure NVIDIA runtime for Docker
sudo nvidia-ctk runtime configure --runtime=docker

# Install the NVIDIA container toolkit
sudo apt-get install -y nvidia-container-toolkit

# Restart the Docker service
sudo systemctl restart docker

# Run a Docker container with NVIDIA GPU support to test
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

## Installation

To install build the `Vanilla` development container from scratch, follow these steps:

### Clone this repository

```bash
 git clone https://github.com/ztangerineio/vanilla.git
```

### Enter the the directory with the `Dockerfile` and `docker-compose.yaml` files

```bash
cd docker
```

### Build the image

```bash
docker build --no-cache -t alpha:cuda .
```

### Start the container

```bash
docker compose up
```

### Enter the container

```bash
docker exec -it --user [user] [container_name] bash
```

### Test the container's access to the host's GPU

```bash
nvidia-smi
```

### Make the `.local/bin`

```bash
mkdir -p ~/.local/bin
```

### Create the `.bashrc` and `PATH` for the installed dependencies

```bash
echo 'PATH="$PATH:/home/$USER/.local/bin"' > .bashrc
```

### Update the `PATH`

```bash
source ~/.bashrc
```

### Create the directory structure for your LLM model(s)

```bash
mkdir -p ~/.llm/vanilla/models/gguf
```

### Setup the virtual environment for Python and activate it

```bash
cd ~/.llm/vanilla && python3 -m venv venv && source venv/bin/activate
```

### Install the requirements

```bash
pip install -r ~/.init.d/requirements.txt
```

### Install `llama-cpp-python` with CUDA support

```bash
CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install llama-cpp-python --no-cache-dir
```

### Download a model to test the new environment

```bash
huggingface-cli download \
TheBloke/dolphin-2.2.1-mistral-7B-GGUF dolphin-2.2.1-mistral-7b.Q4_K_M.gguf \
--local-dir /home/"$USER"/.llm/vanilla/models/gguf --local-dir-use-symlinks False
```

### Load the model: Enter python3 cli and run the following

```python
from llama_cpp import Llama
llm = Llama(model_path="/home/$USER/.llm/vanilla/models/gguf/dolphin-2.2.1-mistral-7b.Q4_K_M.gguf", n_ctx=8192, n_threads=8, n_threads_batch=4, n_batch=2, n_gpu_layers=64, dtype="bf16", f16_kv=True, use_mlock=True)
```

> If you see the following lines in the loading output then your GPU is good to go. If not, you are running on CPU only.

```python
llm_load_tensors: using CUDA for GPU acceleration
llm_load_tensors: mem required  =   70.42 MiB
llm_load_tensors: offloading 32 repeating layers to GPU
llm_load_tensors: offloading non-repeating layers to GPU
llm_load_tensors: offloaded 35/35 layers to GPU
llm_load_tensors: VRAM used: 4095.06 MiB
.............................................................................................
```

> If you do not see the GPU in the loading output but you do see your GPU in the `nvidia-smi` output, then you need to do the following from the Linux command-line to tell `llama-cpp-python` that you have an CUDA-capabale GPU. So, exit the Python cli (exit() or CTRL+D) and run the following.

```bash
pip uninstall -y llama-cpp-python
CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install llama-cpp-python --no-cache-dir
```

> Then re-enter the Python cli, reload the model and continue to the next step.

### Test the model

```python
output = llm(
      "Q: Can you write a limerick about llamas with hats? A: ",
      max_tokens=3072,
      top_p=1.030301,
      top_k=42,
      temperature=0.96369,
      stop=["Q:"],
      echo=False
)
print(output)
del llm
```
