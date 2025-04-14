#!/usr/bin/env python3
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

def main():
    # Path to the locally downloaded model repository
    model_dir = "./qwen_2.5_7B_ARC_v0.2"

    # Load the tokenizer and model from the local directory
    # Using non-fast tokenizer and trusting the remote code helps in custom implementations
    tokenizer = AutoTokenizer.from_pretrained(
        model_dir,
        use_fast=False,
        trust_remote_code=True
    )
    model = AutoModelForCausalLM.from_pretrained(
        model_dir,
        device_map="auto",
        torch_dtype=torch.float16,
        trust_remote_code=True
    )

    # Define a preset prompt
    prompt = "Explain the concept of artificial intelligence in simple terms."
    print("Prompt:", prompt)
    
    # Tokenize the prompt and send the input tensors to GPU
    inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
    
    # Generate output from the model
    with torch.no_grad():
        output_ids = model.generate(
            **inputs,
            max_new_tokens=200,
            temperature=0.7,
            top_p=0.9,
            do_sample=True
        )

    # Decode and print the generated text
    response = tokenizer.decode(output_ids[0], skip_special_tokens=True)
    print("\nResponse:\n", response)

if __name__ == "__main__":
    main()
