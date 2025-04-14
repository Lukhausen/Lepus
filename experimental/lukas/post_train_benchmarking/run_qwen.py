#!/usr/bin/env python3
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

def main():
    # Path to the locally downloaded model repository
    model_dir = "./qwen_2.5_7B_ARC_v0.2"

    # Load the tokenizer and model from the local directory
    tokenizer = AutoTokenizer.from_pretrained(model_dir)
    model = AutoModelForCausalLM.from_pretrained(
        model_dir,
        device_map="auto",         # Automatically allocate across available GPUs
        torch_dtype=torch.float16  # Use half-precision for efficiency
    )

    # Define a preset prompt
    prompt = "Explain the concept of artificial intelligence in simple terms."
    print("Prompt:", prompt)
    
    # Encode the prompt and send input tensors to GPU
    inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
    
    # Generate output
    with torch.no_grad():
        output_ids = model.generate(
            **inputs,
            max_new_tokens=200,   # Generate up to 200 new tokens
            temperature=0.7,      # Control randomness; lower is more deterministic
            top_p=0.9,            # Nucleus sampling parameter
            do_sample=True        # Enable sampling to generate varied outputs
        )

    # Decode and print the generated output
    response = tokenizer.decode(output_ids[0], skip_special_tokens=True)
    print("\nResponse:\n", response)

if __name__ == "__main__":
    main()
