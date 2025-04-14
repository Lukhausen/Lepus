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
    k=5
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

def evaluate_score(solution_str, test_answer, weight_syntax=0.1, weight_content=0.9):

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
    
# if __name__ == "__main__":
#     solution_str = "[ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7 ], [ 0, 0, 0, 0, 0, 7, 0, 0, 0, 7, 0, 7, 0, 7 ], [ 0, 0, 0, 0, 0, 7, 0, 7, 0, 7, 0, 0, 0, 7 ], [ 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]"
#     #solution_str = "[ [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ], [ 2, 3, 2, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ] ]"
#     #solution_str = "[ [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ], [ 9, 7, 9, 7, 9, 7 ], [ 3, 4, 3, 4, 3, 4 ], [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ] ]"
#     #solution_str = "[ [ 3, 2, 3, , 2 ], [ 7,  8, 7, 8 ], 3, 2, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 8, 7, 8, 7, 8 ] ]"
#     #solution_str = "[ [ 3, 2, 3, 5, 3, 2 ], [ 7, 8, 7, 9, 9, 8 ], [ 2, 3, 0, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ] ]"
#     solution_str = """<|im_start|>system
# You will be provided with example inputs and outputs.
#         Analyze the train examples. Your goal is to find common transformation patterns among those and apply the found patterns to the test input to create the test output.<|im_end|>
# <|im_start|>user
#  ### Train Example 1:
# Input:
# [[22222222229199],
# [99922991229919],
# [99922199221919],
# [22222919229999],
# [22222999222222],
# [22222222222222],
# [99922222222222],
# [19922229999222],
# [99922229199222],
# [22222229919222],
# [22999229999222],
# [22999222222222],
# [22919222222222],
# [22999222222222]]

# Output:
# [[22222222222222],
# [99922222222222],
# [99922222222222],
# [22222222222222],
# [22222222222222],
# [22222222222222],
# [99922222222222],
# [19922222222222],
# [99922222222222],
# [22222222222222],
# [22999222222222],
# [22999222222222],
# [22919222222222],
# [22999222222222]]

# ### Train Example 2:
# Input:
# [[22222999222222],
# [22222919222222],
# [22192999222222],
# [22992222222222],
# [22222222299992],
# [22222222299992],
# [22991922299192],
# [22919922222222],
# [22999122222222],
# [22222222222222],
# [29122221992222],
# [21922229992222],
# [29922229192222],
# [22222222222222]]

# Output:
# [[22222999222222],
# [22222919222222],
# [22192999222222],
# [22992222222222],
# [22222222299992],
# [22222222299992],
# [22222222299192],
# [22222222222222],
# [22222222222222],
# [22222222222222],
# [22222222222222],
# [22222222222222],
# [22222222222222],
# [22222222222222]]

# ### Train Example 3:
# Input:
# [[2229992222222],
# [2229992222222],
# [9129192222222],
# [1929992221991],
# [2222222229199],
# [2222222229991],
# [9199222222222],
# [9991222222222],
# [9999229992222],
# [9199229192999],
# [2222221992999],
# [2999229912999],
# [2999229992999],
# [2919222222222],
# [2999222222222]]

# Output:
# [[2229992222222],
# [2229992222222],
# [2229192222222],
# [2229992222222],
# [2222222222222],
# [2222222222222],
# [2222222222222],
# [2222222222222],
# [2222222222222],
# [2222222222999],
# [2222222222999],
# [2999222222999],
# [2999222222999],
# [2919222222222],
# [2999222222222]]


#  ### Test Input:
# [[9912229999222],
# [9992229199299],
# [1912229999299],
# [9992229999299],
# [2222222222222],
# [2229919299992],
# [2229999291992],
# [2221999299992],
# [2222222299992],
# [2999222299192],
# [2999222299992],
# [2919222222222]]

#  Figure out how to create the test output. Use <think> </think> tags to reason about the problem. Return the final answer in <output> </output> tags as a nested list.<|im_end|>
# <|im_start|>assistant
# <think>
# Let me solve this step by step. 1). The first transformation of the 1st row is a transformed of the 2nd row by swapping the "2" and "9" element and modifying the "9" element to "9". 2).Similarly, the first transformation of the 2nd column is swapping "1" and "2" and replacing "2" with "9". 3). In the 3rd and 4th columns, "9" in the original item is replaced by "2". 4). Corresponding position in the 5th sequence is transformed as follow: 5). Both the 5th row and the 5th column are fluxed from 9 to 2. 6). For 7th to 10th column, each element is exchanged with "1" and "9" is replaced with "2". 7). Likewise, in the middle and left columns, the "2" in original item is exchanged with 9. </think>

#  <output>

# [{"1929992222222", "9199229192999", "1022222199222", "29922229919222", "9199222222222", "9992229999222",
#   "2229992222222", "2229992222222", "2299222222222", "2229192222222", "9992229199299",
#   "1912229999299", "9992229999299", "2222222222222", "2229919299992", "2229999291992",
#   "2221999299992", "2222222299992", "2999222299192", "2999222299992",
#   "2919222222222"}]

# </output><|endoftext|>"""
#     ground_truth = {
#         "train":'[ { "input": [ [ 7, 9 ], [ 4, 3 ] ], "output": [ [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ], [ 9, 7, 9, 7, 9, 7 ], [ 3, 4, 3, 4, 3, 4 ], [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ] ] }, { "input": [ [ 8, 6 ], [ 6, 4 ] ], "output": [ [ 8, 6, 8, 6, 8, 6 ], [ 6, 4, 6, 4, 6, 4 ], [ 6, 8, 6, 8, 6, 8 ], [ 4, 6, 4, 6, 4, 6 ], [ 8, 6, 8, 6, 8, 6 ], [ 6, 4, 6, 4, 6, 4 ] ] } ]',
#         "test":'[ [ 3, 2 ], [ 7, 8 ] ]',
#         "test_answer": np.array([np.array([9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9]),
# np.array([9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 8, 9]),
# np.array([9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 8, 3, 9]),
# np.array([9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 8, 3, 3, 9]),
# np.array([9, 2, 3, 3, 3, 3, 3, 3, 3, 8, 3, 3, 3, 9]),
# np.array([9, 3, 2, 3, 3, 3, 3, 3, 8, 3, 3, 3, 3, 9]),
# np.array([9, 3, 3, 8, 3, 3, 3, 8, 3, 3, 3, 3, 3, 9]),
# np.array([9, 3, 3, 3, 8, 3, 8, 3, 3, 3, 3, 3, 3, 9]),
# np.array([9, 3, 3, 3, 3, 8, 3, 3, 3, 3, 3, 3, 3, 9]),
# np.array([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
# np.array([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
# np.array([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
# np.array([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
# np.array([9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9])])
#     }
#     compute_score(solution_str, ground_truth)