#!/bin/bash

# Update package lists and install Git and Git LFS
sudo apt update
sudo apt install -y git git-lfs

# Initialize Git LFS
git lfs install || echo "Warning: git-lfs not recognized. Please ensure Git LFS is installed properly."

# Clone the model repository if not already present
if [ ! -d "qwen_2.5_7B_ARC_v0.2" ]; then
  echo "Cloning the model repository..."
  git clone https://huggingface.co/Lukhausen/qwen_2.5_7B_ARC_v0.2
  cd qwen_2.5_7B_ARC_v0.2
  git lfs pull || echo "Warning: git lfs pull failed. Some large files might be missing."
  cd ..
else
  echo "Model repository 'qwen_2.5_7B_ARC_v0.2' already exists."
fi

# Upgrade pip
pip install --upgrade pip

# Install required Python libraries globally
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install transformers>=4.37.0 accelerate huggingface_hub sentencepiece protobuf

echo "Installation complete."
