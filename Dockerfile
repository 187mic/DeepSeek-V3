# DeepSeek-V3 inference container
# Requires NVIDIA GPU with CUDA 12.1+ and the NVIDIA Container Toolkit.
#
# Build:
#   docker build -t deepseek-v3 .
#
# Run (interactive chat):
#   docker run --gpus all -it --rm \
#     -v /path/to/DeepSeek-V3-Demo:/models \
#     deepseek-v3 \
#     --ckpt-path /models \
#     --config /app/inference/configs/config_671B.json \
#     --interactive --temperature 0.7 --max-new-tokens 200

FROM pytorch/pytorch:2.4.1-cuda12.1-cudnn9-runtime

WORKDIR /app

# Install Python dependencies from the inference requirements file.
# torch is already pre-installed in the base image with CUDA support, so
# we skip it to avoid replacing it with a potentially non-CUDA PyPI wheel.
COPY inference/requirements.txt /app/requirements.txt
RUN grep -v '^torch==' /app/requirements.txt > /tmp/requirements-no-torch.txt && \
    pip install --no-cache-dir -r /tmp/requirements-no-torch.txt && \
    rm /tmp/requirements-no-torch.txt

# Copy inference source code and configs
COPY inference/ /app/inference/

WORKDIR /app/inference

# Default entrypoint runs the generation script directly.
# Pass extra arguments (--ckpt-path, --config, --interactive, …) at runtime.
ENTRYPOINT ["python", "generate.py"]
