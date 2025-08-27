#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let reward = [
= Defining a Reward Function

Paramount to a successful training in RL is to have a reward function that actually reflects what we want to achieve in the RL training run. It's important to first of all achieve the foundational goals before heading to more advanced goals. In our case, one of the most foundational goals of the LLM is to produce algorithmically parsable output so we can even start to compare it to the actually desired result.

== Insights from MORLAIF
The paper 'Multi-Objective Reinforcement Learning from AI Feedback' @williams2024multiobjectivereinforcementlearningai (MORLAIF) provides valuable insights into the optimisation of AI evaluation systems by separating different evaluation aspects. These findings can be applied to the development of a two-stage evaluation structure that evaluates syntax and content agreement separately.

MORLAIF demonstrates that decomposing complex evaluation tasks into more specific subtasks leads to better overall results. Rather than using a single preference algorithm that covers all aspects of evaluation simultaneously, the paper shows clear advantages of developing separate models for different principles such as factuality, toxicity and comprehensibility.

This realisation can be applied directly to the evaluation of AI expenditure. Instead of using a single evaluation metric that covers all aspects, the separation into syntactic and content evaluation dimensions is logical and effective.

== Application to Grid-based Output
If you apply this to our goal, you get two evaluation aspects: firstly, compliance with the required list format and the correct grid dimensions, and secondly, compliance of the content result with the requirement.

The advantages of such a separate evaluation of syntax and content are confirmed by the MORLAIF paper: 'By breaking down preference modelling into specific principles, the feedback collection and preference model training becomes a more straightforward and well-defined task, which we hypothesize will lead to improved preference model performance.' This hypothesis was confirmed in the experiments, with the specific models achieving significantly higher accuracy than individual models.

== Scalarisation for Combined Evaluation
We also use scalarisation functions to combine the separate ratings. These functions offer flexible methods for combining the two evaluation dimensions (syntax and content) into an overall evaluation. By merging them, we can then utilise and evaluate the reward score more efficiently.

== Dual-Faceted Score Management
The score management in our evaluation system is designed around the insight that separating evaluation into distinct facets — syntax and content — can lead to a more nuanced and effective reward mechanism for our RL training. Building on the MORLAIF-inspired architecture, we decompose the problem into two specific evaluations.

== Evaluation Framework for Grid and Content Similarity
To assign a reliable reward score, we rely on two complementary functions @reward_score_arc_agi_two_py. *evaluate_grid_similarity* checks whether the model's output adheres to the expected grid structure (syntax evaluation), while *compare_answers* verifies that each cell's content matches the target solution (content evaluation). Together, they form a dual evaluation scheme for measuring both format and meaning.

=== Syntax (Structural) Evaluation
The *evaluate_grid_similarity* function takes two inputs *solution_str*, a string encoding of a candidate grid, and *test_answer*, a Python list of lists representing the expected grid-and returns a floating-point similarity score between 0.1 and 1.0. Internally, it proceeds in three main phases: parsing and structure validation, computation of a raw structural similarity metric, and finally an exponential mapping of that metric into the "reward" range.

First, the function attempts to parse *solution_str* into a Python object using *ast.literal_eval*. This is a safe way to interpret a string as a Python literal (list, tuple, dict, etc.) without executing arbitrary code. If parsing fails for any reason-bad syntax, unexpected types, etc.-the function immediately returns the baseline score of 0.1, indicating essentially no structural match. Assuming no exception is raised, the parsed object (named *solution_grid*) is checked to ensure it is exactly a list of lists; if it is not (for example, if it is a flat list, or contains non-list elements), the function again returns

Once both *solution_grid* and the provided *test_answer* (aliased internally as *expected_grid*) are known to be list-of-list structures, the function measures two dimensions of similarity. The first is the row count similarity: if *n_expected* is the number of rows in the expected grid and *n_received* the number of rows in the candidate, the row similarity *row_sim* is defined as
```python
row_sim = min(n_expected, n_received) / max(n_expected, n_received)
```
so that identical row counts yield 1.0, and highly mismatched counts approach 0.0. The second dimension is column-length similarity computed across the first *common_rows = min(n_expected, n_received)* rows. For each shared row index *i*, the code compares the length of *expected_grid[i]* and *solution_grid[i]*. Two empty rows are considered a perfect match (*ratio = 1.0*), a single empty versus non-empty row becomes zero similarity, and otherwise the ratio of the smaller length to the larger length is taken. These per-row ratios are averaged (or, if there are no rows at all, defaulted to 0.1) to produce *avg_col_sim*.

These two components are combined into a single raw structural score:
```python
structural_score = (row_sim + avg_col_sim) / 2.0
```
This value lies between 0.0 (completely mismatched dimensions) and 1.0 (perfectly matching dimensions).\
In the final step, the function transforms *structural_score* with an exponential curve to emphasize reaching a fully correct grid structure. With a tunable parameter *k = 4*, the transformation is
```python
sim = 0.1 + 0.8 * (exp(k * structural_score) - 1) / (exp(k) - 1)
```
#figure(
  image("../assets/screenshots/syntax_graph.png", width: 80%),
  caption: [Exponential Score Mapping for Grid Structure Evaluation (k = 4)],
)
by construction, when *structural_score* is 0, *sim* ≈ 0.1; as structural_score approaches 1, sim approaches-but does not exceed-0.9. To allow the special case of a truly identical grid (where *structural_score == 1.0*), the function first checks for that exact match and returns 1.0 outright. Otherwise, if the exponential map were to slightly overshoot due to floating-point precision, it is capped at 0.9. This design both penalizes malformed or incomplete grids with a low floor and rewards incremental improvements in structural correctness, while reserving the top score only for exact structural replicas.


=== Content (Semantic) Evaluation
The second component evaluates content quality through the compare_answers function:

1. *Direct and Fallback Parsing:* The function attempts to parse both expected and actual answers. With successful parsing, it performs direct comparison.

2. *Flattening Technique:* When exact matches aren't achieved, the function "flattens" nested lists to create a simplified comparison baseline and uses SequenceMatcher to calculate content alignment.

==== SequenceMatcher Algorithm Details
The SequenceMatcher, based on the Ratcliff-Obershelp algorithm, works by finding the longest common subsequence between two flattened sequences. For example:
- Expected grid: `[[3,2],[7,8]]` becomes `[3,2,7,8]`
- Model output: `[[3,2],[7,9]]` becomes `[3,2,7,9]`

The algorithm identifies matching elements in sequence order:
1. Finds longest common subsequence: `[3,2,7]` (3 elements match)
2. Calculates ratio: `2.0 × matching_elements / total_elements = 2.0 × 3 / 8 = 0.75`
3. This ratio represents how much of the content aligns between expected and actual output

The key insight is that SequenceMatcher rewards not just individual correct values, but correct values *in the right sequence*, making it sensitive to both content accuracy and positional correctness within the flattened grid structure.

3. *Regex Fallback:* For solutions that resist direct parsing due to formatting issues, a regex-based mechanism extracts numbers and computes a similarity ratio between expected and provided values.

4. *Similarity Scoring:* The content similarity is transformed using: $ "score" = 0.1 + 0.8 dot frac(e^("k" dot "ratio") - 1,e^(-"k")-1) $ Where ratio measures the similarity between expected and actual answers, and k=7 controls the sensitivity of the exponential scaling.\ This higher k-value (k=7) was selected after testing various parameters. It prioritizes achieving those final percentage points of accuracy, as testing revealed the model already produces answers with high correlation to correct responses based solely on the examples provided. #figure(
  image("../assets/screenshots/content_graph.png", width: 80%),
  caption: [Exponential Score Mapping for Content Similarity Evaluation (k = 7)],
)

This dual evaluation approach — assessing both structure and content — provides a comprehensive framework for measuring how closely LLM-generated grid outputs match expected answers, with graduated scoring that rewards incremental improvements while maintaining high standards for complete accuracy.

== Reward Range Design Principles
The decision to confine our reward score within the range of 0.1 to 0.9 for partial matches — with 0.1 representing the worst-case outcome and 0.9 representing nearly optimal performance, and a perfect score of 1.0 reserved only for an exact match — is driven by two key concepts: normalization/scaling and reward clipping.@10014846

== Normalization and Scaling:
In reinforcement learning, especially within complex multi-objective frameworks like those discussed in MORLAIF, it is crucial to ensure that the reward signal remains within a manageable and meaningful range. By normalizing our partial reward scores to lie between 0.1 and 0.9, we ensure that the signal is neither too weak nor excessively large. This scaling prevents issues such as reward saturation, where excessively high rewards may lead the model to overestimate the value of its predictions or cause instability during training. Inspired by approaches in modern RL systems — as also observed in studies on deep reinforcement learning for congestion control — the normalized range serves as a consistent baseline that fosters smoother gradient updates and more stable policy learning. Essentially, even when the model produces an output that is only partially correct, it still receives a non-zero reward (at least 0.1), which guarantees that the learning signal persists throughout the training process.

== Reward Clipping:
Reward clipping is another important mechanism that helps control the variance and stability of the training process. By capping partial rewards at 0.9, we deliberately prevent the model from receiving a near-perfect reward for outputs that are still not completely accurate. This technique mirrors the clipping practices observed in advanced RL algorithms like those implemented in #acr("PPO") (See @ppo-explanation), a policy gradient method that constrains policy updates through clipping mechanisms, and as demonstrated in the ablation studies for DRL-based congestion control systems. In those studies, omitting clipping often led to erratic policy updates and convergence issues. Clipping ensures that while partial correctness is rewarded, it never reaches the level of an exact match. This careful capping of the reward avoids excessive optimism in the policy updates, ensuring that only the completely correct outputs garner the full reward of 1.0.

== Putting It All Together:
By setting the reward range from 0.1 to 0.9 for any output that is not an exact match, we integrate both normalization/scaling and clipping methods into our reward design. The scaling ensures that the model's learning dynamics remain stable and that the gradients are suitably informative even when outputs are only partially correct. Meanwhile, clipping keeps the reward signal bounded, which helps to prevent overshooting during policy updates and maintains a clear distinction between near-perfect performance (0.9) and absolute correctness (1.0).

This approach, inspired by the insights from MORLAIF and corroborated by empirical findings in related reinforcement learning ablation studies, ultimately leads to a more robust and efficient training process — one where the reward function accurately reflects progress toward both the foundational goal of producing algorithmically parsable output and the advanced goal of content accuracy.

== Final Score Calculation
Finally, the main function evaluate_score combines both dimensions using scalarisation. It applies a scalarisation function that immediately returns a perfect score (1.0) if the solution exactly matches the expected answer. Otherwise, it computes the final score as a weighted sum of the syntax score and the content score. By default, both aspects are weighted equally (0.5 each), but these weights can be adjusted to better reflect their relative importance in different contexts.

== Benefits of the Bifurcated Approach
By managing the score with this bifurcated approach, our method encourages foundational correctness by prioritizing the creation of algorithmically parsable output, establishing a solid structural foundation before delving into more sophisticated content verification. It also improves accuracy by isolating the evaluation into more specific tasks, helping in pinpointing and rewarding improvements in both structure and semantic quality, akin to the benefits observed in the MORLAIF study. Additionally, it provides flexibility through the use of scalarisation functions, allowing us to finely tune the overall reward, so that improvements in either syntax or content result in a corresponding improvement in the final score, leading to more efficient and targeted model training. This careful separation and subsequent recombination of evaluation aspects not only mirrors the empirical findings of MORLAIF but also ensures that our reward function accurately reflects the foundational and advanced goals necessary for successful reinforcement learning training.

]