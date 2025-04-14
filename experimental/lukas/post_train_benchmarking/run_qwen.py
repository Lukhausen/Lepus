#!/usr/bin/env python3
import torch
import os
from transformers import AutoTokenizer, AutoModelForCausalLM, LogitsProcessorList, TemperatureLogitsWarper, TopPLogitsWarper
import logging
import readline # Optional: Improves input editing in the terminal

# Setup basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
# Suppress verbose logs from transformers during generation loop
logging.getLogger("transformers.generation.utils").setLevel(logging.WARNING)

def main():
    # --- Configuration ---
    script_dir = os.path.dirname(os.path.abspath(__file__))
    model_dir = os.path.join(script_dir, "qwen_2.5_7B_ARC_v0.2") # Your fine-tuned model
    device_map = "auto"
    torch_dtype = torch.bfloat16 # Keep bfloat16 as it worked
    use_fast_tokenizer = False # Keep False as per original
    trust_remote_code = True

    # --- Generation Parameters ---
    max_new_tokens = 512 # Max tokens to generate per turn
    temperature = 0.7
    top_p = 0.9
    do_sample = True

    logging.info(f"Model directory: {model_dir}")
    logging.info(f"Using device_map='{device_map}', dtype={torch_dtype}")
    logging.info(f"Using fast tokenizer: {use_fast_tokenizer}")
    logging.info(f"Trusting remote code: {trust_remote_code}")

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
        # Ensure pad token is set for generation
        if tokenizer.pad_token is None:
            logging.warning("Tokenizer does not have a pad token, setting to eos_token.")
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
        logging.info(f"Model device map: {model.hf_device_map}")
    except Exception as e:
        logging.error(f"An unexpected error occurred loading the model: {e}")
        return 1

    # --- Chat Loop ---
    print("\n--- Qwen Chat Interface ---")
    print("Type 'quit' or 'exit' to end the session.")
    print("Type 'clear' to reset the conversation history.")

    # Store conversation history as a list of dictionaries
    conversation_history = []

    while True:
        try:
            user_input = input("\nYou: ").strip()

            if user_input.lower() in ["quit", "exit"]:
                print("Exiting chat.")
                break

            if user_input.lower() == "clear":
                conversation_history = []
                print("Conversation history cleared.")
                continue

            if not user_input:
                continue

            # Add user message to history
            conversation_history.append({"role": "user", "content": user_input})

            # Apply the chat template to the history
            # This formats the input correctly for the model (e.g., with <|im_start|> tags)
            try:
                # We don't add the generation prompt here, as the template should handle the final 'assistant' turn start
                prompt_text = tokenizer.apply_chat_template(
                    conversation_history,
                    tokenize=False,
                    add_generation_prompt=True # Important: Adds the prompt for the assistant's turn
                )
            except Exception as e:
                 logging.error(f"Failed to apply chat template: {e}")
                 logging.warning("Falling back to simple concatenation (context might degrade).")
                 # Fallback (less ideal)
                 prompt_text = "\n".join([f"{msg['role']}: {msg['content']}" for msg in conversation_history]) + "\nassistant:"


            # Tokenize the formatted prompt
            inputs = tokenizer(prompt_text, return_tensors="pt", return_attention_mask=True).to(model.device)
            input_ids = inputs.input_ids
            attention_mask = inputs.attention_mask

            # Generate response
            logging.info("Generating response...")
            with torch.no_grad():
                # Generate output, feeding the attention mask is important for padding
                output_ids = model.generate(
                    input_ids,
                    attention_mask=attention_mask, # Pass the attention mask
                    max_new_tokens=max_new_tokens,
                    temperature=temperature,
                    top_p=top_p,
                    do_sample=do_sample,
                    pad_token_id=tokenizer.pad_token_id, # Use pad token ID
                    eos_token_id=tokenizer.eos_token_id # Stop generation at EOS token
                )
            logging.info("Generation complete.")

            # Decode only the newly generated tokens
            # The generated output_ids include the input_ids, so we slice them off
            new_tokens = output_ids[0, input_ids.shape[1]:]
            response = tokenizer.decode(new_tokens, skip_special_tokens=True).strip()

            print(f"\nAssistant: {response}")

            # Add assistant's response to history
            conversation_history.append({"role": "assistant", "content": response})

            # Optional: Limit history size to prevent excessive memory usage/context length
            # max_history_turns = 5 # Keep last 5 pairs (user + assistant)
            # if len(conversation_history) > max_history_turns * 2:
            #     conversation_history = conversation_history[-(max_history_turns * 2):]

        except KeyboardInterrupt:
            print("\nExiting chat due to KeyboardInterrupt.")
            break
        except Exception as e:
            logging.error(f"An error occurred in the chat loop: {e}")
            # Optionally clear history on error or allow user to decide
            # conversation_history = []
            # print("An error occurred. History might be cleared.")

    return 0

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)