#!/usr/bin/env python3
import torch
import os
from transformers import AutoTokenizer, AutoModelForCausalLM
import logging

# Setup basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    # --- Configuration ---
    # Use os.path.join for cross-platform compatibility
    # Assumes the script is run from the directory containing the model folder
    script_dir = os.path.dirname(os.path.abspath(__file__))
    model_dir = os.path.join(script_dir, "qwen_2.5_7B_ARC_v0.2")
    prompt = "Explain the concept of artificial intelligence in simple terms."
    device_map = "auto" # Recommended for multi-GPU or large models
    torch_dtype = torch.bfloat16 # Use bfloat16 instead of float16
    use_fast_tokenizer = False # As per original script, can help with compatibility
    trust_remote_code = True # Often required for models like Qwen

    logging.info(f"Model directory: {model_dir}")
    logging.info(f"Using device_map='{device_map}', dtype={torch_dtype}")
    logging.info(f"Using fast tokenizer: {use_fast_tokenizer}")
    logging.info(f"Trusting remote code: {trust_remote_code}")

    # --- Check Model Directory ---
    if not os.path.isdir(model_dir):
        logging.error(f"Model directory not found: {model_dir}")
        logging.error("Please ensure the model is downloaded correctly. Run install.sh.")
        return 1 # Indicate error

    # --- Load Tokenizer ---
    try:
        logging.info("Loading tokenizer...")
        tokenizer = AutoTokenizer.from_pretrained(
            model_dir,
            use_fast=use_fast_tokenizer,
            trust_remote_code=trust_remote_code
        )
        logging.info("Tokenizer loaded successfully.")
    except Exception as e:
        logging.error(f"Failed to load tokenizer: {e}")
        logging.error("Check if tokenizer files exist and are not corrupted (e.g., LFS pointers).")
        return 1 # Indicate error

    # --- Load Model ---
    try:
        logging.info("Loading model...")
        model = AutoModelForCausalLM.from_pretrained(
            model_dir,
            device_map=device_map,
            torch_dtype=torch_dtype,
            trust_remote_code=trust_remote_code
            # Consider adding low_cpu_mem_usage=True if RAM is limited during loading
            # low_cpu_mem_usage=True
        )
        logging.info("Model loaded successfully.")
        logging.info(f"Model device map: {model.hf_device_map}")
    except Exception as e:
        # Catch the specific error if possible, otherwise generic Exception
        if "HeaderTooLarge" in str(e) or "SafetensorError" in str(e):
             logging.error(f"Failed to load model weights: {e}")
             logging.error("This VERY LIKELY means the .safetensors files are still Git LFS pointers.")
             logging.error("Please re-run install.sh or manually run 'git lfs pull' inside the '{model_dir}' directory.")
        else:
            logging.error(f"An unexpected error occurred loading the model: {e}")
        return 1 # Indicate error

    # --- Tokenize Prompt ---
    logging.info(f"Prompt: \"{prompt}\"")
    try:
        # Send inputs to the same device as the model (especially important with device_map)
        inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
        logging.info("Prompt tokenized.")
    except Exception as e:
        logging.error(f"Failed to tokenize prompt: {e}")
        return 1

    # --- Generate Output ---
    logging.info("Generating response...")
    try:
        with torch.no_grad(): # Disable gradient calculations for inference
            output_ids = model.generate(
                **inputs,
                max_new_tokens=200,
                temperature=0.7,
                top_p=0.9,
                do_sample=True,
                pad_token_id=tokenizer.eos_token_id # Important for sampling
            )
        logging.info("Generation complete.")
    except Exception as e:
        logging.error(f"Error during generation: {e}")
        return 1

    # --- Decode and Print ---
    try:
        response = tokenizer.decode(output_ids[0], skip_special_tokens=True)
        logging.info("Decoding complete.")
        print("\n--- Response ---")
        print(response)
        print("------ End -----")
    except Exception as e:
        logging.error(f"Failed to decode output: {e}")
        return 1

    return 0 # Indicate success

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)