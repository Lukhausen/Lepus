#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "Starting Minimal TinyZero Setup..."
apt update
apt upgrade -y

# --- 1. System Dependencies (Minimal - as root) ---
echo "[1/6] Updating package lists and installing essential packages..."
apt-get update > /dev/null # Suppress verbose output
apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    curl \
    ca-certificates > /dev/null # Suppress verbose output
echo "    Done."

# Initialize Git LFS system-wide (needed before cloning LFS repos)
git lfs install --system

# --- 2. Miniconda Installation ---
echo "[2/6] Installing or Verifying Miniconda..."
# Check if Miniconda is already installed
if [ ! -d "/opt/miniconda3" ]; then
    echo "    Downloading Miniconda..."
    curl -s -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh # -s for silent
    echo "    Installing Miniconda..."
    bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 > /dev/null # Suppress verbose output
    rm ./Miniconda3-latest-Linux-x86_64.sh # Clean up installer
    echo "    Initializing Conda for future sessions..."
    eval "$(/opt/miniconda3/bin/conda shell.bash hook)"
    conda init bash > /dev/null # Suppress verbose output
else
    echo "    Miniconda already installed."
    eval "$(/opt/miniconda3/bin/conda shell.bash hook)" # Ensure conda command is available for this script
fi
# Source the bashrc *within the script* to ensure conda is usable now
source ~/.bashrc
echo "    Done."

# --- 3. Project Repo Clone ---
echo "[3/6] Cloning TinyZero repository..."
# Check if the directory exists
if [ ! -d "TinyZero" ]; then
    git clone https://github.com/Lukhausen/Lepus.git > /dev/null
else
    echo "    TinyZero directory already exists."
fi
cd ./Lepus/experimental/marc/TinyZero/
echo "    Done. Current directory: $(pwd)"

# --- 4. Conda Environment and Core Dependencies ---
echo "[4/6] Creating/Updating Conda environment 'zero' and installing packages..."
# Create the environment only if it doesn't exist
if ! conda env list | grep -q '\bzero\b'; then
    conda create -n zero python=3.9 -y > /dev/null
else
    echo "    Conda environment 'zero' already exists."
fi
# Activate environment *within the script* to install packages into it
conda activate zero

# Install essential packages (using pip within the conda env)
# -q for quieter pip output
pip install -q torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121
pip install -q vllm==0.5.4
pip install -q ray
pip install -q flash-attn --no-build-isolation
pip install -q wandb
pip install -q -e . # Installs 'verl' from local source

# Deactivate the environment - user must activate manually later
conda deactivate
echo "    Done. Python packages installed into 'zero' environment."

# --- 5. Model Download (using Git LFS) ---
echo "[5/6] Downloading Qwen2.5-3B model (if needed)..."
mkdir -p models/
# Check if model directory exists before cloning
if [ ! -d "models/Qwen2.5-3B/.git" ]; then # Check for .git to be more robust
    cd models/
    echo "    Cloning model repo (this uses LFS and may take time)..."
    # Clone the model - Git LFS is essential here
    git lfs clone https://huggingface.co/Qwen/Qwen2.5-3B # Keep output for progress
    cd ../ # Go back to TinyZero project root
    echo "    Model download complete."
else
    echo "    Model directory models/Qwen2.5-3B already exists."
fi

# --- 6. Final Instructions ---
echo "[6/6] Setup Script Finished!"
echo "-------------------------------------------------------------"
echo "Location: $(pwd)"
echo ""
echo "NEXT STEPS (MUST BE DONE MANUALLY in your terminal):"
echo ""
echo "A. Activate Conda Environment:"
echo "   IMPORTANT: If 'conda activate zero' fails with 'command not found',"
echo "   run this command first: source ~/.bashrc"
echo "   Then activate the environment: conda activate zero"
echo ""
echo "B. Prepare Data (while 'zero' env is active):"
echo "   python ./examples/data_preprocess/arc_agi_two.py --local_dir ./data/arc_agi_two"
echo ""
echo "C. Set Environment Variables (while 'zero' env is active):"
echo "   export N_GPUS=1"
echo "   export BASE_MODEL=./models/Qwen2.5-3B"
echo "   export DATA_DIR=./data/arc_agi_two"
echo "   export ROLLOUT_TP_SIZE=1"
echo "   export EXPERIMENT_NAME=arc_agi_two-qwen2.5-3B"
echo "   export VLLM_ATTENTION_BACKEND=XFORMERS"
echo "   export WANDB_API_KEY=\"724a473f54d00ed3c8fab36dc7abf32c23523360\"" # Using provided key
echo "   (Optional, for low VRAM GPUs): export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True"
echo "   (Optional, for low VRAM GPUs): export TRITON_BENCHMARK_FLUSH_CACHE=0"
echo ""
echo "D. Modify Training Script (Optional, for low VRAM GPUs like 24GB):"
echo "   Edit 'scripts/train_tiny_zero.sh' and apply optimized parameters:"
echo "   (You only NEED this if you encounter OutOfMemory errors later)"
echo "   - data.max_response_length=256"
echo "   - actor_rollout_ref.rollout.gpu_memory_utilization=0.05"
echo "   - actor_rollout_ref.model.enable_gradient_checkpointing=True"
echo "   - critic.model.enable_gradient_checkpointing=True"
echo "   - actor_rollout_ref.actor.ppo_micro_batch_size=1"
echo "   - critic.ppo_micro_batch_size=1"
echo "   - actor_rollout_ref.actor.fsdp_config.grad_offload=True"
echo "   - critic.model.fsdp_config.grad_offload=True"
echo "   - actor_rollout_ref.actor.fsdp_config.optimizer_offload=True"
echo "   - critic.model.fsdp_config.optimizer_offload=True"
echo ""
echo "E. Run Training (while 'zero' env is active):"
echo "   bash ./scripts/train_tiny_zero.sh"
echo "-------------------------------------------------------------"