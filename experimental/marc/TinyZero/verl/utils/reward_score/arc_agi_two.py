import re
import random
import ast
import ast
import numpy as np
import operator
import math
from difflib import SequenceMatcher

def evaluate_grid_similarity(solution_str, test_answer):

    try:
        solution_grid = ast.literal_eval(solution_str)
    except Exception as e:
        # Falls die Umwandlung fehlschlägt, gib den schlechtesten Score zurück.
        return 0.1

    # Überprüfe, ob beide in der erwarteten Struktur (Liste von Listen) vorliegen.
    if not (isinstance(solution_grid, list) and all(isinstance(row, list) for row in solution_grid)):
        return 0.1
    
    expected_grid = test_answer
    # Ermitteln der Dimensionen des erwarteten Grids.
    n_expected = len(expected_grid)
    n_received = len(solution_grid)
    
    # Falls beide Grids gar keine Zeilen enthalten, betrachten wir sie als gleich.
    if n_expected == 0 and n_received == 0:
        return 0.1
    
    # Zeilenvergleich (als Quotient der kleineren zur größeren Anzahl)
    row_sim = min(n_expected, n_received) / max(n_expected, n_received)
    
    # Für die gemeinsamen Zeilen: Spaltenlängen vergleichen
    common_rows = min(n_expected, n_received)
    col_ratios = []
    for i in range(common_rows):
        len_expected = len(expected_grid[i])
        len_received = len(solution_grid[i])
        # Bei leeren Zeilen definieren wir die Ratio als 1 (sowohl 0/0 oder
        # falls nur ein leere Zeile vorliegt, könnte man hier auch anders vorgehen)
        if len_expected == 0 and len_received == 0:
            ratio = 1.0
        elif len_expected == 0 or len_received == 0:
            ratio = 0.0
        else:
            ratio = min(len_expected, len_received) / max(len_expected, len_received)
        col_ratios.append(ratio)
    
    # Durchschnittliche Spaltenähnlichkeit
    avg_col_sim = sum(col_ratios) / len(col_ratios) if col_ratios else 0.1
    
    # Gesamtstrukturscore (zwischen 0 und 1)
    structural_score = (row_sim + avg_col_sim) / 2.0

    # Falls die Strukturen exakt gleich sind, soll 1 zurückgegeben werden.
    if structural_score == 1:
        return 1.0
    else:
        # Exponentielle Abbildung, die bei structural_score = 0 zu ~0.1 führt 
        # und bei structural_score -> 1 asymptotisch 1 erreicht.
        # Hier wird explizit so transformiert, dass bei ungenügender Ähnlichkeit (0) fast
        # der Minimalwert (0.1) und bei fast exakter Übereinstimmung (aber noch nicht 1)
        # Werte um 0.9 zurückgegeben werden.

        k= 4
        sim = 0.1 + 0.8 * (np.exp(k * structural_score) - 1) / (np.exp(k) - 1)
        # Damit wir nie 1 zurückgeben, solange structural_score nicht exakt 1 ist,
        # erzwingen wir ein Maximum von 0.9.
        if sim >= 1:
            sim = 0.9
        return sim
    
def compare_answers(solution_str, test_answer) -> float:

    # print("type_solution_str:"+str(type(solution_str)))
    # print("text_solution_str:"+str(solution_str))
    # print("type_test_answer:"+str(type(test_answer)))
    # print("text_test_answer:"+str(test_answer))
    
    def try_parse(s):
        """Versucht, den String mittels ast.literal_eval zu parsen."""
        try:
            new_parse = ast.literal_eval(s)
            if isinstance(new_parse, list):
                return new_parse
            return None
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
    k=7
    score = 0.1 + 0.8 * (np.exp(k * ratio) - 1) / (np.exp(k) - 1)
    # Falls der Score (aufgrund numerischer Effekte) etwas über 0.9 liegt, sichern wir den Maximalwert.
    score = min(score, 0.9)
    return score


def convert_and_return_value(solution_str):
    try:
        # Versuch, den String in ein Python-Objekt umzuwandeln
        data = ast.literal_eval(solution_str)
        # Wenn die Umwandlung erfolgreich war, geben wir 1 zurück
        return 1
    except Exception as error:
        # Sollte es einen Fehler geben, geben wir 0.1 zurück
        return 0.1

def evaluate_score(solution_str, test_answer, weight_syntax=0.3, weight_content=0.7):

    if solution_str == None:
        return 0.1

    syntax_score = evaluate_grid_similarity(solution_str, test_answer)
    
    content_score = compare_answers(solution_str, test_answer)
    
    combined_score = weight_syntax * syntax_score + weight_content * content_score
    return combined_score

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


def validate_equation(equation_str, available_numbers):
    """Validate that equation only uses available numbers and each number once."""
    try:
        # Extract all numbers from the equation
        numbers_in_eq = [int(n) for n in re.findall(r'\d+', equation_str)]
        
        # Check if all numbers in equation are available
        available_numbers = sorted(available_numbers)
        numbers_in_eq = sorted(numbers_in_eq)
        
        # Each number should be used exactly once
        return numbers_in_eq == available_numbers
    except:
        return False


def evaluate_equation(equation_str):
    """Safely evaluate the arithmetic equation using eval() with precautions."""
    try:
        # Define a regex pattern that only allows numbers, operators, parentheses, and whitespace
        allowed_pattern = r'^[\d+\-*/().\s]+$'
        if not re.match(allowed_pattern, equation_str):
            raise ValueError("Invalid characters in equation.")

        # Evaluate the equation with restricted globals and locals
        result = eval(equation_str, {"__builtins__": None}, {})
        return result
    except Exception as e:
        return None


def compute_score(solution_str, ground_truth, method='strict', format_score=0.1, score=1.):
    """The scoring function for countdown task.
    
    Args:
        solution_str: the solution text
        ground_truth: dictionary containing target number and available numbers
        method: the method to extract the solution
        format_score: the score for correct format but wrong answer
        score: the score for the correct answer
    """
    # print("type_solution_str:"+str(type(solution_str)))
    # print("text_solution_str:"+str(solution_str))
    # print("type_ground_truth['test_answer']:"+str(type(ground_truth['test_answer'])))
    # print("text_ground_truth['test_answer']:"+str(ground_truth['test_answer']))
    train = ground_truth['train']
    test = ground_truth['test']
    test_answer = [
        x.tolist() if isinstance(x, np.ndarray) else x
        for x in ground_truth['test_answer']
    ]
    #print("text_test_answer:"+str(test_answer))
    # print("type_test_answer:"+str(type(test_answer)))
    # print("text_test_answer:"+str(test_answer))
    solution_str_full = solution_str
    solution_str = extract_solution(solution_str)
    try:
        score = evaluate_score(solution_str=solution_str, test_answer=test_answer)
    except Exception as e:
        print("========== DEBUG INFO ==========")
        print("Exception encountered during score evaluation:")
        print("Exception: ", e)
        print("")
        print("Raw solution string (full):")
        print("Type: {}".format(type(solution_str_full)))
        print("Value: {}".format(solution_str_full))
        print("")
        print("Extracted solution string:")
        print("Type: {}".format(type(solution_str)))
        print("Value: {}".format(solution_str))
        print("")
        print("Parsed test_answer used in evaluation:")
        print("Type: {}".format(type(test_answer)))
        print("Value: {}".format(test_answer))
        print("")
        print("Ground Truth:")
        print("Full ground_truth dict: {}".format(ground_truth))
        print("Train: (Type: {}) - Value: {}".format(type(ground_truth.get('train')), ground_truth.get('train')))
        print("Test: (Type: {}) - Value: {}".format(type(ground_truth.get('test')), ground_truth.get('test')))
        print("Test Answer (raw): (Type: {}) - Value: {}".format(type(ground_truth.get('test_answer')), ground_truth.get('test_answer')))
        print("")
        print("================================")
        raise e
    do_print = random.randint(1, 64) == 1
    
    if do_print:
        print(f"""
        --------------------------------
        --------------------------------
        Model Output: {solution_str_full}
        --------------------------------
        Extracted Answer from model Out: {solution_str}
        --------------------------------
        Expected Answer from test_answer: {test_answer}
        --------------------------------
        Score: {score}
        """)


    return score
    
if __name__ == "__main__":
    solution_str = "[ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7 ], [ 0, 0, 0, 0, 0, 7, 0, 0, 0, 7, 0, 7, 0, 7 ], [ 0, 0, 0, 0, 0, 7, 0, 7, 0, 7, 0, 0, 0, 7 ], [ 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]"
    #solution_str = "[ [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ], [ 2, 3, 2, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ] ]"
    #solution_str = "[ [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ], [ 9, 7, 9, 7, 9, 7 ], [ 3, 4, 3, 4, 3, 4 ], [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ] ]"
    #solution_str = "[ [ 3, 2, 3, , 2 ], [ 7,  8, 7, 8 ], 3, 2, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 8, 7, 8, 7, 8 ] ]"
    #solution_str = "[ [ 3, 2, 3, 5, 3, 2 ], [ 7, 8, 7, 9, 9, 8 ], [ 2, 3, 0, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ] ]"
    solution_str = """<|im_start|>system
 You will be provided with example inputs and outputs.
         Analyze the train examples. Your goal is to find common transformation patterns among those and apply the found patterns to the test input to create the test output.<|im_end|>
 <|im_start|>user
  ### Train Example 1:
 Input:
 [
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,3,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,1,0,0,1,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,5,0,5,0,0,5,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 ]

 Output:
 [
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,8,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,4,0,0,4,0,0],
 [0,0,0,0,0,0,0,0],
 [0,8,0,6,0,0,6,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 ]

 ### Train Example 2:
 Input:
 [
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,0,0,0,2,0,0,1,1],
 [1,1,0,1,0,0,0,0,1,1],
 [1,1,0,0,0,2,0,0,1,1],
 [1,1,0,5,0,0,0,0,1,1],
 [1,1,0,0,0,5,0,0,1,1],
 [1,1,0,5,0,0,0,0,1,1],
(main_task pid(WorkerDict pid=14152) wrap_policy: functools.partial(<function transformer_auto_wrap_policy at 0x71fc8830cc10>, transformer_layer_cls={<class 'transformers.models.qwen2.modeling_qwen2.Qwen2DecoderLayer'>})
(WorkerDict pid=14152) kwargs: {'n': 5, 'logprobs': 1, 'max_tokens': 10000, 'detokenize': False, 'temperature': 1.0, 'top_k': -1, 'top_p': 1, 'ignore_eos': False}
(WorkerDict pid=14152) Total steps: 3390, num_warmup_steps: 0
(WorkerDict pid=14152) Actor use_remove_padding=True
(WorkerDict pid=14152) local rank 0
(WorkerDict pid=14152) INFO 04-13 14:23:37 selector.py:54] Using XFormers backend. [repeated 3x across cluster]
(WorkerDict pid=13908) After building vllm rollout, memory allocated (GB): 55.34482717514038, memory reserved (GB): 61.265625
(WorkerDict pid=13908) After building sharding manager, memory allocated (GB): 55.34482717514038, memory reserved (GB): 61.265625
 epoch 0, step 1
 ========== DEBUG INFO ==========
 Exception encountered during score evaluation:
 Exception:  unhashable type: 'list'

 Raw solution string (full):
 Type: <class 'str'>
 Value: <|im_start|>system
 You will be provided with example inputs and outputs.
         Analyze the train examples. Your goal is to find common transformation patterns among those and apply the found patterns to the test input to create the test output.<|im_end|>
 <|im_start|>user
  ### Train Example 1:
 Input:
 [
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,3,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,1,0,0,1,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,5,0,5,0,0,5,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 ]

 Output:
 [
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,8,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,4,0,0,4,0,0],
 [0,0,0,0,0,0,0,0],
 [0,8,0,6,0,0,6,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 ]

 ### Train Example 2:
 Input:
 [
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,0,0,0,2,0,0,1,1],
 [1,1,0,1,0,0,0,0,1,1],
 [1,1,0,0,0,2,0,0,1,1],
 [1,1,0,5,0,0,0,0,1,1],
 [1,1,0,0,0,5,0,0,1,1],
 [1,1,0,5,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,1,0,0,1,1],
 [1,1,0,2,0,0,0,0,1,1],
 [1,1,0,0,0,0,5,0,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 ]

 Output:
 [
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,8,0,0,0],
 [0,0,4,0,0,0,0,0],
 [0,0,0,0,6,0,0,0],
 [0,0,8,0,0,0,0,0],
 [0,0,0,0,4,0,0,0],
 [0,0,6,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,8,0,0,0],
 [0,0,4,0,0,0,0,0],
 [0,0,0,0,0,6,0,0],
 [0,0,0,0,0,0,0,0],
 ]

 ### Train Example 3:
 Input:
 [
 [1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,0,0,0,0,0,0,0,0,1,1],
 [1,1,0,0,2,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,5,0,1,1],
 [1,1,0,1,0,5,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,0,0,1,1],
 [1,1,2,0,0,0,1,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,0,1,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1],
 ]

 Output:
 [
 [0,0,0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0,0,0],
 [0,0,0,4,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,4,0,0],
 [0,0,8,0,6,0,0,0,0,0],
 [0,0,0,0,0,0,0,0,0,0],
 [0,6,0,0,0,8,0,0,0,0],
 [0,0,0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0,6,0],
 [0,0,0,0,0,0,0,0,0,0],
 ]


  ### Test Input:
 [
 [1,1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,1,0,0,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,9,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,6,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,0,3,0,1,1],
 [1,1,9,0,0,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,6,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,0,0,0,1,1],
 [1,1,1,0,0,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,6,0,0,1,1],
 [1,1,0,0,3,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,0,1,0,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1,1],
 ]

  Figure out how to create the test output. Use <think> </think> tags to reason about the problem. Return the final answer in <output> </output> tags as a nested list.<|im_end|>
 <|im_start|>assistant
 <think>
 Let me solve this step by step. 1. Start with the first instance: [
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,0,0,0,2,0,0,1,1],
 [1,1,0,1,0,0,0,0,1,1],
 [1,1,0,0,0,2,0,0,1,1],
 [1,1,0,5,0,0,0,0,1,1],
 [1,1,0,0,0,5,0,0,1,1],
 [1,1,0,5,0,0,0,0,1,1],
 [1,1,0,0,0,0,0,0,1,1],
 [1,1,0,0,0,1,0,0,1,1],
 [1,1,0,2,0,0,0,0,1,1],
 [1,1,0,0,0,0,5,0,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1],
 ]

 Output: [
 [0,0,0,0,0,0,0,0],
 [0,0,0,0,8,0,0,0],
 [0,0,4,0,0,4,0,0],
 [0,0,0,0,6,0,0,0],
 [0,0,8,0,0,0,0,0],
 [0,0,0,0,4,0,0,0],
 [0,0,6,0,0,0,0,0],
 [0,0,0,0,0,0,0,0],
 ---
 Based on this, one transformation pattern is that when a Y pattern with head "1" and tail "0" appear with a some value "y" in its middle, we transform it to value "y" on positions "middle" inclusive to "middle+3" and "middle+5".

 Think about the next instance. </think>
 <think>
 Next instance: [
 [1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,0,0,0,0,0,0,0,1,1,1],
 [1,1,0,0,0,0,5,0,0,0,1,1,1],
 [1,1,1,1,0,1,0,0,0,0,1,1,1],
 [1,1,0,0,0,2,0,0,0,0,1,1,1],
 [1,1,0,0,0,1,0,0,0,0,1,1,1],
 [1,1,2,1,1,2,0,0,0,0,1,1,1],
 [1,3,3,0,3,0,0,0,0,0,1,1,1],
 [1,0,0,0,0,1,0,0,0,0,1,1,1],
 [1,1,0,0,0,0,5,0,0,0,1,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1,1],
 [1,1,1,1,1,1,1,1,1,1,1,1,1],
 ]

 Output: [
 [0,0,0,0,0,0,0,0,0,0],
 [0,0,0,0,0,0,0,0,0,0],
 [--to be continued--]
 </think>

 <think>

 Complete the output as indicated by the previous instance.

 <output>
[ [6666666666666666],
 [6666666666666666],
 [6655565666566666],
 [6655555555555566],
 [6655555555555566],
 [6655565666566666],
 [6655566666666666],
 [6655566666666666],
 [6555566666666666],
 [6655566666666666],
 [6655566666666666],
 [6655566666666666],
 [6655566666666666],
 [6655566666666666],
 [6666666666666666],
 [6666666666666666]
]
 </output>

 You are an AI assistant that helps people find information. User will you give you a question. Your task is to answer as faithfully as you can. While answering think step-by-step and justify your answer.<|endoftext|>"""
    ground_truth = {
        "train":'[ { "input": [ [ 7, 9 ], [ 4, 3 ] ], "output": [ [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ], [ 9, 7, 9, 7, 9, 7 ], [ 3, 4, 3, 4, 3, 4 ], [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ] ] }, { "input": [ [ 8, 6 ], [ 6, 4 ] ], "output": [ [ 8, 6, 8, 6, 8, 6 ], [ 6, 4, 6, 4, 6, 4 ], [ 6, 8, 6, 8, 6, 8 ], [ 4, 6, 4, 6, 4, 6 ], [ 8, 6, 8, 6, 8, 6 ], [ 6, 4, 6, 4, 6, 4 ] ] } ]',
        "test":'[ [ 3, 2 ], [ 7, 8 ] ]',
        "test_answer": np.array([np.array([9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9]),
np.array([9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 8, 9]),
np.array([9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 8, 3, 9]),
np.array([9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 8, 3, 3, 9]),
np.array([9, 2, 3, 3, 3, 3, 3, 3, 3, 8, 3, 3, 3, 9]),
np.array([9, 3, 2, 3, 3, 3, 3, 3, 8, 3, 3, 3, 3, 9]),
np.array([9, 3, 3, 8, 3, 3, 3, 8, 3, 3, 3, 3, 3, 9]),
np.array([9, 3, 3, 3, 8, 3, 8, 3, 3, 3, 3, 3, 3, 9]),
np.array([9, 3, 3, 3, 3, 8, 3, 3, 3, 3, 3, 3, 3, 9]),
np.array([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
np.array([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
np.array([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
np.array([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
np.array([9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9])])
    }
    compute_score(solution_str, ground_truth)