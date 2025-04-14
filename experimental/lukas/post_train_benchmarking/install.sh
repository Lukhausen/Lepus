#!/bin/bash

# ----- Install system packages -----
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git git-lfs

# Initialize Git LFS (if it's recognized by your system)
git lfs install || echo "git-lfs not recognized. Ensure git-lfs is installed properly."

# ----- Clone the model repo if not already present -----
if [ ! -d "qwen_2.5_7B_ARC_v0.2" ]; then
  git clone https://huggingface.co/Lukhausen/qwen_2.5_7B_ARC_v0.2
  cd qwen_2.5_7B_ARC_v0.2
  git lfs pull || echo "git lfs pull failed. Large files might not be pulled."
  cd ..
else
  echo "Model repo qwen_2.5_7B_ARC_v0.2 already exists."
fi

# ----- Create (if needed) and activate a Python virtual environment -----
if [ ! -d "qwen_env" ]; then
  python3 -m venv qwen_env
fi
source qwen_env/bin/activate

# ----- Upgrade pip -----
pip install --upgrade pip

# ----- Install required Python packages -----
# You can adjust the Torch/CUDA version index URL if needed
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Transformers >= 4.37.0 supports Qwen; also installing protobuf explicitly
pip install transformers>=4.37.0 accelerate huggingface_hub sentencepiece protobuf

# ----- Create the run_qwen.py script (overwrite existing if any) -----
cat << 'EOF' > run_qwen.py
#!/usr/bin/env python3
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

def main():
    model_dir = "./qwen_2.5_7B_ARC_v0.2"

    # Load tokenizer and model from local directory
    tokenizer = AutoTokenizer.from_pretrained(model_dir)
    model = AutoModelForCausalLM.from_pretrained(
        model_dir,
        device_map="auto",
        torch_dtype=torch.float16
    )

    # Simple preset prompt
    prompt = "Explain the concept of artificial intelligence in simple terms."

    # Generate output
    inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
    with torch.no_grad():
        output_ids = model.generate(
            **inputs,
            max_new_tokens=200,
            temperature=0.7,
            top_p=0.9,
            do_sample=True
        )

    # Decode and print the response
    response = tokenizer.decode(output_ids[0], skip_special_tokens=True)
    print("Response:\n", response)

if __name__ == "__main__":
    main()
EOF

# Make run_qwen.py executable
chmod +x run_qwen.py

# ----- Run the script -----
./run_qwen.py
