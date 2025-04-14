#!/usr/bin/env python3
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

def main():
    # Define the model name from the Hugging Face repository
    model_name = "Lukhausen/qwen_2.5_7B_ARC_v0.2"
    
    print("Loading tokenizer...")
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    
    print("Loading model on GPU...")
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        device_map="auto",         # Automatically place layers on available GPUs
        torch_dtype=torch.float16  # Use half-precision for efficient GPU usage
    )
    
    print("Model loaded successfully!")
    
    # Define your preset prompt
    prompt = "Explain the concept of artificial intelligence in simple terms."
    print("\nPreset Prompt:", prompt)
    
    # Encode the prompt and shift it to the GPU
    inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
    
    # Generate output from the model
    with torch.no_grad():
        output_ids = model.generate(
            **inputs,
            max_new_tokens=200,  # Maximum new tokens for this generation
            do_sample=True,      # Use sampling; for deterministic output, set to False
            temperature=0.7,     # Controls randomness in generation
            top_p=0.9            # Nucleus sampling probability
        )
    
    # Decode generated tokens to a string, skipping any special tokens
    response = tokenizer.decode(output_ids[0], skip_special_tokens=True)
    
    print("\nResponse:\n")
    print(response)

if __name__ == "__main__":
    main()
