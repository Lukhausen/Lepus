#!/bin/bash

# 1. Install system packages (if already installed, this will do nothing)
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git git-lfs

# 2. Initialize git-lfs
git lfs install

# 3. Clone the Qwen 2.5 7B ARC v0.2 model repository (if not already present)
if [ ! -d "qwen_2.5_7B_ARC_v0.2" ]; then
  git clone https://huggingface.co/Lukhausen/qwen_2.5_7B_ARC_v0.2
  cd qwen_2.5_7B_ARC_v0.2
  git lfs pull
  cd ..
else
  echo "The model repository qwen_2.5_7B_ARC_v0.2 already exists."
fi

# 4. Create and activate a virtual environment
if [ ! -d "qwen_env" ]; then
  python3 -m venv qwen_env
fi
source qwen_env/bin/activate

# 5. Upgrade pip and install required Python packages
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install transformers accelerate huggingface_hub sentencepiece

# 6. Create the run_qwen.py script
cat << 'EOF' > run_qwen.py
#!/usr/bin/env python3
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch

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

# Make the Python script executable
chmod +x run_qwen.py

# 7. Run the script
./run_qwen.py
