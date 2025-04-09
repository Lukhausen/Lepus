
# Install the Hugging Face CLI
pip install -U "huggingface_hub[cli]"

# Login with your Hugging Face credentials
huggingface-cli login

# Push your dataset files
huggingface-cli upload Lukhausen/arc-test . --repo-type=dataset