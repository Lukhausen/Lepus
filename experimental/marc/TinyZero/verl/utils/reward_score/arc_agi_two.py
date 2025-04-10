import re
import random
import ast
import operator
import math
from difflib import SequenceMatcher

def evaluate_grid_similarity(solution_str, test_answer):

    try:
        expected_grid = ast.literal_eval(test_answer)
        solution_grid = ast.literal_eval(solution_str)
    except Exception as e:
        # Falls die Umwandlung fehlschlägt, gib den schlechtesten Score zurück.
        return 0.1

    # Überprüfe, ob beide in der erwarteten Struktur (Liste von Listen) vorliegen.
    if not (isinstance(expected_grid, list) and all(isinstance(row, list) for row in expected_grid)):
        return 0.1
    if not (isinstance(solution_grid, list) and all(isinstance(row, list) for row in solution_grid)):
        return 0.1

    # Ermitteln der Dimensionen des erwarteten Grids.
    n_expected = len(expected_grid)
    n_received = len(solution_grid)
    
    # Falls beide Grids gar keine Zeilen enthalten, betrachten wir sie als gleich.
    if n_expected == 0 and n_received == 0:
        return 1.0
    
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
    avg_col_sim = sum(col_ratios) / len(col_ratios) if col_ratios else 1.0
    
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
        sim = 0.1 + 0.9 * (math.exp(structural_score) - 1) / (math.e - 1)
        # Damit wir nie 1 zurückgeben, solange structural_score nicht exakt 1 ist,
        # erzwingen wir ein Maximum von 0.9.
        if sim >= 1:
            sim = 0.9
        return sim
    
def compare_answers(solution_str: str, test_answer: str) -> float:
    
    def try_parse(s: str):
        """Versucht, den String mittels ast.literal_eval zu parsen."""
        try:
            return ast.literal_eval(s)
        except Exception:
            return None

    def flatten(lst):
        """Flacht eine (verschachtelte) Liste in eine einfache Liste ab."""
        if isinstance(lst, list):
            res = []
            for item in lst:
                res.extend(flatten(item))
            return res
        else:
            return [lst]
    
    # Parse den TestAnswer-String (sollte korrekt sein).
    test_parsed = try_parse(test_answer)
    if test_parsed is None:
        raise ValueError("TestAnswer ist nicht korrekt formatiert.")
    
    # Versuch, solution_str zu parsen.
    sol_parsed = try_parse(solution_str)
    
    # Falls beide korrekt geparst werden
    if sol_parsed is not None:
        # Falls die beiden Listen exakt gleich sind, gebe 1.0 zurück.
        if sol_parsed == test_parsed:
            return 1.0
        # Andernfalls vergleiche die flachen Versionen.
        flat_test = flatten(test_parsed)
        flat_sol = flatten(sol_parsed)
        ratio = SequenceMatcher(a=flat_test, b=flat_sol).ratio()
    else:
        # Fallback: Es können Formatierungsprobleme in solution_str vorliegen.
        # Mit Regex alle Zahlen extrahieren und als Ganzzahlen interpretieren.
        nums_test = list(map(int, re.findall(r'-?\d+', test_answer)))
        nums_sol = list(map(int, re.findall(r'-?\d+', solution_str)))
        # Prüfe, ob die extrahierten Zahlen gleich sind.
        if nums_test == nums_sol:
            return 1.0
        ratio = SequenceMatcher(a=nums_test, b=nums_sol).ratio()
    
    # Mapping: Ist die similarity nicht exakt 1,
    # wird der Wert linear in den Bereich [0.1, 0.9] abgebildet.
    k=0.5
    score = 0.1 + 0.8 * (1 - math.exp(-k * ratio)) / (1 - math.exp(-k))
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

def evalute_score(solution_str, test_answer):

    if solution_str == test_answer:
        return 1

    grid_similarity_score = evaluate_grid_similarity(solution_str, test_answer)

    answer_imilarity_score = compare_answers(solution_str, test_answer)

    return grid_similarity_score * 0.5 + answer_imilarity_score * 0.5

    print("test")

def extract_solution(solution_str):
    """Extract the equation from the solution string."""
    # Remove everything before the first "Assistant:"
    if "Assistant:" in solution_str:
        solution_str = solution_str.split("Assistant:", 1)[1]
    elif "<|im_start|>assistant" in solution_str:
        solution_str = solution_str.split("<|im_start|>assistant", 1)[1]
    else:
        return None
    solution_str = solution_str.split('\n')[-1]

    answer_pattern = r'<answer>(.*?)</answer>'
    match = re.finditer(answer_pattern, solution_str)
    matches = list(match)
    if matches:
        final_answer = matches[-1].group(1).strip()
    else:
        final_answer = None
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
    train = ground_truth['train']
    test = ground_truth['test']
    test_answer = ground_truth['test_answer']
    
    final_answer = evalute_score(solution_str=solution_str, test_answer=test_answer)
    do_print = random.randint(1, 64) == 1
    
    if do_print:
        print(f"--------------------------------")
        print(f"Target: {train} | Numbers: {test}")
        print(f"Extracted answer: {final_answer}")
        print(f"Solution string: {solution_str}")

    # if final_answer is None:
    #     if do_print:
    #         print(f"No equation found")
    #     return 0
    
    # # Validate equation uses correct numbers
    # if not validate_equation(equation, numbers):
    #     if do_print:
    #         print(f"Invalid equation")
    #     return format_score
        
    # # Evaluate equation
    # try:
    #     result = evaluate_equation(equation)
    #     if result is None:
    #         if do_print:
    #             print(f"Could not evaluate equation")
    #         return format_score
            
    #     if abs(result - target) < 1e-5:  # Account for floating point precision
    #         if do_print:
    #             print(f"Correct equation: {equation} = {result}")
    #         return score
    #     else:
    #         if do_print:
    #             print(f"Wrong result: equation = {result}, target = {target}")
    #         return format_score
    # except:
    #     if do_print:
    #         print(f"Error evaluating equation")
    #     return format_score 
    
if __name__ == "__main__":
    solution_str = "[ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7 ], [ 0, 0, 0, 0, 0, 7, 0, 0, 0, 7, 0, 7, 0, 7 ], [ 0, 0, 0, 0, 0, 7, 0, 7, 0, 7, 0, 0, 0, 7 ], [ 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]"
    #solution_str = "[ [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ], [ 2, 3, 2, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ] ]"
    #solution_str = "[ [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ], [ 9, 7, 9, 7, 9, 7 ], [ 3, 4, 3, 4, 3, 4 ], [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ] ]"
    #solution_str = "[ [ 3, 2, 3, , 2 ], [ 7,  8, 7, 8 ], 3, 2, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 8, 7, 8, 7, 8 ] ]"
    #solution_str = "[ [ 3, 2, 3, 5, 3, 2 ], [ 7, 8, 7, 9, 9, 8 ], [ 2, 3, 0, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ] ]"
    
    ground_truth = {
        "train":'[ { "input": [ [ 7, 9 ], [ 4, 3 ] ], "output": [ [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ], [ 9, 7, 9, 7, 9, 7 ], [ 3, 4, 3, 4, 3, 4 ], [ 7, 9, 7, 9, 7, 9 ], [ 4, 3, 4, 3, 4, 3 ] ] }, { "input": [ [ 8, 6 ], [ 6, 4 ] ], "output": [ [ 8, 6, 8, 6, 8, 6 ], [ 6, 4, 6, 4, 6, 4 ], [ 6, 8, 6, 8, 6, 8 ], [ 4, 6, 4, 6, 4, 6 ], [ 8, 6, 8, 6, 8, 6 ], [ 6, 4, 6, 4, 6, 4 ] ] } ]',
        "test":'[ [ 3, 2 ], [ 7, 8 ] ]',
        "test_answer":'[ [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ], [ 2, 3, 2, 3, 2, 3 ], [ 8, 7, 8, 7, 8, 7 ], [ 3, 2, 3, 2, 3, 2 ], [ 7, 8, 7, 8, 7, 8 ] ]'
    }
    compute_score(solution_str, ground_truth)