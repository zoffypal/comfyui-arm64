FROM python:3.13-slim-bookworm

ARG COMFYUI_VERSION=v0.37.0

LABEL org.opencontainers.image.title="ComfyUI ARM64 CPU"
LABEL org.opencontainers.image.description="ComfyUI CPU image for ARM64 / Oracle Cloud Ampere"
LABEL org.opencontainers.image.source="https://github.com/Comfy-Org/ComfyUI"

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_NO_CACHE_DIR=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone \
    --depth 1 \
    --branch ${COMFYUI_VERSION} \
    https://github.com/Comfy-Org/ComfyUI.git

WORKDIR /opt/ComfyUI

# Install CPU-only ARM64 PyTorch
RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install \
      torch \
      torchvision \
      torchaudio \
      --index-url https://download.pytorch.org/whl/cpu

# Install ComfyUI dependencies
RUN python -m pip install -r requirements.txt

RUN mkdir -p \
    /opt/ComfyUI/models \
    /opt/ComfyUI/input \
    /opt/ComfyUI/output \
    /opt/ComfyUI/custom_nodes \
    /opt/ComfyUI/user

EXPOSE 8188

CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--cpu"]
