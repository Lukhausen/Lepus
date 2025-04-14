#!/usr/bin/env python3
import torch
import os
from transformers import AutoTokenizer, AutoModelForCausalLM
import logging
import readline # Optional: Improves input editing in the terminal

# Setup basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logging.getLogger("transformers.generation.utils").setLevel(logging.WARNING) # Quieter generation

def get_multiline_input(prompt_message):
    """Helper function to get multi-line input from the user."""
    print(f"{prompt_message} (Type 'END_INPUT' on a new line when done, or 'quit' to exit):")
    lines = []
    while True:
        try:
            line = input()
            if line.strip().upper() == "END_INPUT":
                break
            if line.strip().lower() == "quit":
                return None # Signal to exit
            lines.append(line)
        except EOFError: # Handle Ctrl+D
            break
    return "\n".join(lines)

def format_dataset_prompt(train_examples, test_input):
    """Replicates the exact prompt structure from your PPO preprocessing."""
    # NOTE: This template MUST exactly match the one used for training
    #       (make_prefix function with template_type='qwen-instruct')
    template = f"""<|im_start|>system
You will be provided with example inputs and outputs. 
Analyze the train examples. Your goal is to find common transformation patterns among those and apply the found patterns to the test input to create the test output.<|im_end|>
<|im_start|>user
 {train_examples} 


 {test_input}

 Figure out how to create the test output. Show me your Work in <think> </think> tags. Return the final answer in <output> </output> tags as a nested list.<|im_end|>
<|im_start|>assistant
<think>
Let me solve this step by step. """ # Note: Ends exactly here, model generates the rest
    return template

def main():
    # --- Configuration ---
    script_dir = os.path.dirname(os.path.abspath(__file__))
    model_dir = os.path.join(script_dir, "qwen_2.5_7B_ARC_v0.2") # Your fine-tuned model
    device_map = "auto"
    torch_dtype = torch.bfloat16 # Keep bfloat16 as it worked
    use_fast_tokenizer = False
    trust_remote_code = True

    # --- Generation Parameters ---
    max_new_tokens = 1024 # Adjust as needed for expected output length
    temperature = 0.7     # Use same settings as before or adjust if needed
    top_p = 0.9
    do_sample = True      # Set to False if you want deterministic output (usually True for creative/complex tasks)

    logging.info(f"Model directory: {model_dir}")
    logging.info(f"Using device_map='{device_map}', dtype={torch_dtype}")

    if not os.path.isdir(model_dir):
        logging.error(f"Model directory not found: {model_dir}")
        return 1

    # --- Load Tokenizer ---
    try:
        logging.info("Loading tokenizer...")
        tokenizer = AutoTokenizer.from_pretrained(
            model_dir,
            use_fast=use_fast_tokenizer,
            trust_remote_code=trust_remote_code
        )
        if tokenizer.pad_token is None:
            logging.warning("Tokenizer lacks pad token, setting to eos_token.")
            tokenizer.pad_token = tokenizer.eos_token
        logging.info("Tokenizer loaded successfully.")
    except Exception as e:
        logging.error(f"Failed to load tokenizer: {e}")
        return 1

    # --- Load Model ---
    try:
        logging.info("Loading model...")
        model = AutoModelForCausalLM.from_pretrained(
            model_dir,
            device_map=device_map,
            torch_dtype=torch_dtype,
            trust_remote_code=trust_remote_code
        )
        logging.info("Model loaded successfully.")
    except Exception as e:
        logging.error(f"An unexpected error occurred loading the model: {e}")
        return 1

    # --- Input and Generation Loop ---
    print("\n--- Dataset Replication Interface ---")
    print("Provide 'Train Examples' and 'Test Input' mimicking your dataset.")

    while True:
        print("-" * 30)
        train_input = get_multiline_input("Enter Train Examples")
        if train_input is None: # User typed 'quit'
            break

        test_input = get_multiline_input("Enter Test Input")
        if test_input is None: # User typed 'quit'
            break

        if not train_input.strip() or not test_input.strip():
            print("Both Train and Test inputs are required. Please try again.")
            continue

        # Format the prompt exactly like the training data
        formatted_prompt = format_dataset_prompt(train_input, test_input)
        logging.info("Formatted prompt ready for model.")
        # Optional: Print the exact prompt being sent (for debugging)
        # print("\n--- Sending Prompt to Model ---")
        # print(formatted_prompt)
        # print("--- End Prompt ---")


        # Tokenize
        try:
            inputs = tokenizer(formatted_prompt, return_tensors="pt").to(model.device)
        except Exception as e:
            logging.error(f"Failed to tokenize prompt: {e}")
            continue # Ask for input again

        # Generate
        logging.info("Generating response...")
        try:
            with torch.no_grad():
                output_ids = model.generate(
                    inputs.input_ids,
                    attention_mask=inputs.attention_mask,
                    max_new_tokens=max_new_tokens,
                    temperature=temperature,
                    top_p=top_p,
                    do_sample=do_sample,
                    pad_token_id=tokenizer.pad_token_id,
                    eos_token_id=tokenizer.eos_token_id # Use EOS token if available
                )
            logging.info("Generation complete.")

            # Decode the full output (including the prompt part generated by the template)
            # We want the raw model output here, including <think> etc.
            # The slicing output_ids[0, inputs.input_ids.shape[1]:] is NOT needed here
            # because the prompt template already includes the start of the assistant turn.
            response = tokenizer.decode(output_ids[0], skip_special_tokens=True)

            print("\n--- Model Response ---")
            print(response)
            print("------ End Response ------")

        except Exception as e:
            logging.error(f"Error during generation or decoding: {e}")

    print("Exiting.")
    return 0

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)