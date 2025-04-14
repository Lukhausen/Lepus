#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "INFO: Updating package lists..."
apt update # No sudo needed if running as root

echo "INFO: Installing Git and Git LFS..."
apt install -y git git-lfs # No sudo

# Initialize Git LFS system-wide (ensures hooks are set up)
# Do this *after* installing git-lfs
git lfs install --system

MODEL_REPO_NAME="qwen_2.5_7B_ARC_v0.2"
MODEL_REPO_URL="https://huggingface.co/Lukhausen/qwen_2.5_7B_ARC_v0.2"

# Clone the model repository or ensure LFS files are downloaded if it exists
if [ ! -d "$MODEL_REPO_NAME" ]; then
  echo "INFO: Cloning model repository $MODEL_REPO_URL..."
  # Use GIT_LFS_SKIP_SMUDGE=1 to prevent automatic LFS download during clone.
  # We'll explicitly pull LFS files after cloning to ensure it happens correctly.
  GIT_LFS_SKIP_SMUDGE=1 git clone "$MODEL_REPO_URL" "$MODEL_REPO_NAME"
  if [ $? -ne 0 ]; then
      echo "ERROR: Failed to clone repository."
      exit 1
  fi
  echo "INFO: Entering repository directory: $MODEL_REPO_NAME"
  cd "$MODEL_REPO_NAME"
  echo "INFO: Pulling LFS files..."
  git lfs pull
  if [ $? -ne 0 ]; then
      echo "ERROR: git lfs pull failed inside newly cloned repo. Check network or LFS setup."
      exit 1
  fi
  # Go back to the parent directory
  cd ..
else
  echo "INFO: Model repository '$MODEL_REPO_NAME' already exists."
  echo "INFO: Entering existing directory and attempting to pull LFS files to ensure completeness..."
  cd "$MODEL_REPO_NAME"
  git lfs pull
  if [ $? -ne 0 ]; then
      # This might not be fatal if files were manually placed, but it's a warning.
      echo "WARNING: git lfs pull failed in existing repo. Files might be incomplete, corrupted, or LFS might not be properly initialized for this repo."
      echo "WARNING: Attempting 'git lfs install' locally just in case."
      git lfs install # Try initializing locally if system-wide failed or wasn't picked up
      echo "WARNING: Retrying 'git lfs pull'..."
      git lfs pull
  fi
  # Go back to the parent directory
  cd ..
fi

echo "INFO: Upgrading pip..."
# Use --no-warn-script-location to suppress warnings when running as root
pip install --upgrade pip --no-warn-script-location

echo "INFO: Upgrading/Installing required Python libraries..."
# Upgrade safetensors first, as it was related to the original error
pip install --upgrade safetensors --no-warn-script-location

# Install PyTorch (ensure CUDA version matches your environment if needed, cu118 seems requested)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --no-warn-script-location

# Install transformers and related libraries
pip install transformers>=4.37.0 accelerate huggingface_hub sentencepiece protobuf --no-warn-script-location

echo "INFO: Installation and LFS download process complete."
echo "INFO: Checking sizes of potential large files in '$MODEL_REPO_NAME':"
# List sizes of common large files to help verify LFS download
ls -lh "$MODEL_REPO_NAME"/*.safetensors "$MODEL_REPO_NAME"/tokenizer.json 2>/dev/null || echo "INFO: No .safetensors or tokenizer.json found to list sizes for."