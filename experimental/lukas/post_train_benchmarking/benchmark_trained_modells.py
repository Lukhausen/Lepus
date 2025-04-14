#!/usr/bin/env python3
from difflib import SequenceMatcher
import numpy as np
import torch
import os
import ast
from transformers import AutoTokenizer, AutoModelForCausalLM
import logging
import re
from datasets import Dataset, load_dataset

# Setup basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logging.getLogger("transformers.generation.utils").setLevel(logging.WARNING) # Quieter generation
    
def compare_answers(solution_str, test_answer) -> float:

    # print("type_solution_str:"+str(type(solution_str)))
    # print("text_solution_str:"+str(solution_str))
    # print("type_test_answer:"+str(type(test_answer)))
    # print("text_test_answer:"+str(test_answer))
    
    def try_parse(s):
        """Versucht, den String mittels ast.literal_eval zu parsen."""
        try:
            new_parse = ast.literal_eval(s)
            if not (isinstance(new_parse, list) and all(isinstance(row, list) for row in new_parse)):
                return None
            return new_parse
        except Exception:
            return None

    def flatten(lst):
        """Flacht eine (verschachtelte) Liste in eine einfache Liste ab."""
        if isinstance(lst, (list, np.ndarray)):
            res = []
            for item in lst:
                res.extend(flatten(item))
            return res
        else:
            return [lst]
    
    # Parse den TestAnswer-String (sollte korrekt sein).
    # test_parsed = try_parse(test_answer)
    # if test_parsed is None:
    #     raise ValueError("TestAnswer ist nicht korrekt formatiert.")
    test_parsed = test_answer
    # Versuch, solution_str zu parsen.
    sol_parsed = try_parse(solution_str)
    
    # Falls beide korrekt geparst werden
    if sol_parsed is not None:
        # Falls die beiden Listen exakt gleich sind, gebe 1.0 zurück.
        if sol_parsed == test_parsed:
            return 1.0
        # Andernfalls vergleiche die flachen Versionen.
        # print("type_test_parsed:"+str(type(test_parsed)))
        # print("text_test_parsed:"+str(test_parsed))
        # print("type_sol_parsed:"+str(type(sol_parsed)))
        # print("text_sol_parsed:"+str(sol_parsed))
        flat_test = flatten(test_parsed)
        flat_sol = flatten(sol_parsed)
        # print("type_flat_test:"+str(type(flat_test)))
        # print("text_flat_test:"+str(flat_test))
        # print("type_flat_sol:"+str(type(flat_sol)))
        # print("text_flat_sol:"+str(flat_sol))
        ratio = SequenceMatcher(a=flat_test, b=flat_sol).ratio()
    else:
        # Fallback: Es können Formatierungsprobleme in solution_str vorliegen.
        # Mit Regex alle Zahlen extrahieren und als Ganzzahlen interpretieren.
        test_answer = str(test_parsed)
        nums_test = list(map(int, re.findall(r'-?\d+', test_answer)))
        nums_sol = list(map(int, re.findall(r'-?\d+', solution_str)))
        # Prüfe, ob die extrahierten Zahlen gleich sind.
        if nums_test == nums_sol:
            return 1.0
        ratio = SequenceMatcher(a=nums_test, b=nums_sol).ratio()
    
    # Mapping: Ist die similarity nicht exakt 1,
    # wird der Wert linear in den Bereich [0.1, 0.9] abgebildet.
    k=4
    score = 0.1 + 0.8 * (np.exp(k * ratio) - 1) / (np.exp(k) - 1)
    # Falls der Score (aufgrund numerischer Effekte) etwas über 0.9 liegt, sichern wir den Maximalwert.
    score = min(score, 0.9)
    return score

def extract_solution(solution_str):
    """Extract the equation from the solution string."""
    # Remove everything before the first "Assistant:"
    if "Assistant:" in solution_str:
        solution_str = solution_str.split("Assistant:", 1)[1]
    elif "<|im_start|>assistant" in solution_str:
        solution_str = solution_str.split("<|im_start|>assistant", 1)[1]
    else:
        return None
    #solution_str = solution_str.split('\n')[-1]

    # answer_pattern = r'<answer>(.*?)</answer>'
    # match = re.finditer(answer_pattern, solution_str)
    # matches = list(match)
    # if matches:
    #     final_answer = matches[-1].group(1).strip()
    # else:
    #     final_answer = None

    answer_pattern = r'<output>(.*?)</output>'
    
    # Find all matches in the string (using DOTALL if multiline content is expected)
    matches = list(re.finditer(answer_pattern, solution_str, flags=re.DOTALL))
    
    # If at least one match exists, use the last one; otherwise, return None.
    if matches:
        final_answer = matches[-1].group(1).strip()
    else:
        final_answer = None

    # If the answer contains square brackets, extract and return the bracketed part
    if final_answer is not None:
        start_index = final_answer.find('[')
        if start_index != -1:
            final_answer = final_answer[start_index:]
        
        end_index = final_answer.rfind(']')
        if end_index != -1:
            final_answer = final_answer[:end_index+1]
        
        # Return substring from the first '[' to the first ']' (including ']')
        final_answer = final_answer.replace("\n","")

        final_answer = final_answer.replace("0","0,")
        final_answer = final_answer.replace("1","1,")
        final_answer = final_answer.replace("2","2,")
        final_answer = final_answer.replace("3","3,")
        final_answer = final_answer.replace("4","4,")
        final_answer = final_answer.replace("5","5,")
        final_answer = final_answer.replace("6","6,")
        final_answer = final_answer.replace("7","7,")
        final_answer = final_answer.replace("8","8,")
        final_answer = final_answer.replace("9","9,")



    return final_answer


def get_score(solution_str, sub_task_answer):

    def try_parse(s):
        """Versucht, den String mittels ast.literal_eval zu parsen."""
        try:
            new_parse = ast.literal_eval(s)
            if not (isinstance(new_parse, list) and all(isinstance(row, list) for row in new_parse)):
                return None
            return new_parse
        except Exception:
            return None
        
    solution = try_parse(solution_str)

    if solution != None:
        if solution == sub_task_answer:
            return True
    return False

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

    raw_dataset = load_dataset('Lukhausen/arc-agi-lepus-v1-evaluation', split='train')

    correct = 0
    wrong = 0
    reward_score = 0

    for task in raw_dataset:
        task_train = task["train"]
        correct_task = 0
        wrong_task = 0
        reward_score_task = 0
        teiler = 0
        for i in range(len(task["test"])):
            sub_task_test = task["test"][i]
            sub_task_answer = task["test_answer"][i]
            
            formatted_prompt = format_dataset_prompt(task_train, sub_task_test)

            try:
                inputs = tokenizer(formatted_prompt, return_tensors="pt").to(model.device)
            except Exception as e:
                logging.error(f"Failed to tokenize prompt: {e}")
                print(f"Failed to tokenize prompt: {e}")
                continue # Ask for input again

            # Generate
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

                # Decode the full output (including the prompt part generated by the template)
                # We want the raw model output here, including <think> etc.
                # The slicing output_ids[0, inputs.input_ids.shape[1]:] is NOT needed here
                # because the prompt template already includes the start of the assistant turn.
                response = tokenizer.decode(output_ids[0], skip_special_tokens=True)

                solution_str = extract_solution(response)

                if get_score(solution_str, sub_task_answer):
                    correct_task = correct_task + 1
                else:
                    wrong_task = wrong_task + 1

                content_score = compare_answers(solution_str, sub_task_answer)

                reward_score_task = reward_score_task + content_score
                teiler = teiler + 1

            except Exception as e:
                logging.error(f"Error during generation or decoding: {e}")
                print(f"Error during generation or decoding: {e}")
            
        if wrong_task == 0 and correct_task == len(task["test"]):
            correct = correct + 1
        else:
            wrong = wrong + 1

        reward_score = reward_score + (reward_score_task / teiler)

         
    print("arc-agi-lepus-v1-evaluation")
    print(f"Correct: {correct}")
    print(f"Wrong: {wrong}")
    print(f"Score: {correct/len(raw_dataset)}")
    print(f"RewardScore: {reward_score}")
    print("Exiting.")
    return 0

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)