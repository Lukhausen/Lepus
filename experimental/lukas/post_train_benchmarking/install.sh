#!/bin/bash

echo "🚀 Starting Qwen 2.5 7B ARC v0.2 setup..."

# Set environment name
ENV_NAME="qwen_env"

# Install system dependencies (optional, comment out if already done)
echo "📦 Installing basic system tools..."
sudo apt update && sudo apt install -y python3 python3-pip python3-venv git

# Create virtual environment if it doesn't exist
if [ ! -d "$ENV_NAME" ]; then
    echo "🐍 Creating Python virtual environment: $ENV_NAME"
    python3 -m venv $ENV_NAME
else
    echo "✅ Virtual environment already exists."
fi

# Activate the virtual environment
echo "🔁 Activating virtual environment..."
source $ENV_NAME/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install required Python packages
echo "📦 Installing Python dependencies..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install transformers>=4.37.0 accelerate huggingface_hub sentencepiece

# Check if the run script exists
if [ ! -f "run_qwen.py" ]; then
    echo "❌ run_qwen.py not found! Please create it in the same directory."
    exit 1
fi

# Run the Python script
echo "🚀 Running Qwen 2.5 7B ARC v0.2 model..."
python run_qwen.py
