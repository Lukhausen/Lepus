#!/bin/bash

# Update package lists and install Git and Git LFS (NO SUDO if running as root)
apt update
apt install -y git git-lfs

# Initialize Git LFS
git lfs install

# Clone the model repository if not already present
if [ ! -d "qwen_2.5_7B_ARC_v0.2" ]; then
  echo "Cloning the model repository..."
  # Consider adding authentication if needed for private repos
  git clone https://huggingface.co/Lukhausen/qwen_2.5_7B_ARC_v0.2
  cd qwen_2.5_7B_ARC_v0.2
  # Ensure git lfs pull runs successfully
  echo "Pulling LFS files..."
  git lfs pull
  if [ $? -ne 0 ]; then
      echo "Error: git lfs pull failed. Check network or LFS installation."
      # Optionally exit here: exit 1
  fi
  cd ..
else
  echo "Model repository 'qwen_2.5_7B_ARC_v0.2' already exists."
  # Optional: You might still want to pull LFS files in case they are missing
  # cd qwen_2.5_7B_ARC_v0.2
  # git lfs pull
  # cd ..
fi

# Upgrade pip
pip install --upgrade pip --no-warn-script-location

# Upgrade safetensors to help avoid header deserialization issues
pip install --upgrade safetensors --no-warn-script-location

# Install required Python libraries globally
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --no-warn-script-location
pip install transformers>=4.37.0 accelerate huggingface_hub sentencepiece protobuf --no-warn-script-location

echo "Installation complete."