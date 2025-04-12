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
The score management in our evaluation system is designed around the insight that separating evaluation into distinct facets—syntax and content—can lead to a more nuanced and effective reward mechanism for our RL training. Building on the MORLAIF-inspired architecture, we decompose the problem into two specific evaluations.

== Evaluation Framework for Grid and Content Similarity

=== Syntax (Structural) Evaluation
The first component focuses on syntax evaluation, ensuring that LLM output adheres to the required grid format. The *evaluate_grid_similarity* function handles this assessment through several key steps:

1. *Input Parsing* : Both the expected answer and solution are parsed into Python objects using a safe literal evaluation method. If parsing fails or the structure doesn't match the expected format (a list of lists), a minimal baseline score (0.1) is assigned.

2. *Structural Comparison*: The function measures similarity by first comparing the number of rows (calculating a row similarity ratio), then iterating through common rows to compute column-level similarity. For each row, it calculates the ratio between the lengths of corresponding rows.

3. *Score Mapping*: An exponential transformation is applied to the structural score: $ "score" = 0.1 + 0.8 dot frac(e^"structural_score" - 1, e -1) $ where structural_score is a combined metric reflecting both the row and column similarity of the grids

This mapping ensures the syntax score remains continuous and responsive to incremental improvements while only reaching a full score when there's an exact match.

=== Content (Semantic) Evaluation
The second component evaluates content quality through the compare_answers function:

1. *Direct and Fallback Parsing:* The function attempts to parse both expected and actual answers. With successful parsing, it performs direct comparison.

2. *Flattening Technique:* When exact matches aren't achieved, the function "flattens" nested lists to create a simplified comparison baseline and uses SequenceMatcher to calculate content alignment.

3. *Regex Fallback:* For solutions that resist direct parsing due to formatting issues, a regex-based mechanism extracts numbers and computes a similarity ratio between expected and provided values.

4. *Similarity Scoring:* The content similarity is transformed using: $ "score" = 0.1 + 0.8 dot frac(1 - e^(-"k" dot "ratio"),1- e^(-"k")) $ where ratio measures the similarity between the expected and actual answers, and k (set to 0.5) controls the sensitivity of the exponential scaling.

This dual evaluation approach—assessing both structure and content—provides a comprehensive framework for measuring how closely LLM-generated grid outputs match expected answers, with graduated scoring that rewards incremental improvements while maintaining high standards for complete accuracy.

== Reward Range Design Principles
The decision to confine our reward score within the range of 0.1 to 0.9 for partial matches—with 0.1 representing the worst-case outcome and 0.9 representing nearly optimal performance, and a perfect score of 1.0 reserved only for an exact match—is driven by two key concepts: normalization/scaling and reward clipping.@10014846

== Normalization and Scaling:
In reinforcement learning, especially within complex multi-objective frameworks like those discussed in MORLAIF, it is crucial to ensure that the reward signal remains within a manageable and meaningful range. By normalizing our partial reward scores to lie between 0.1 and 0.9, we ensure that the signal is neither too weak nor excessively large. This scaling prevents issues such as reward saturation, where excessively high rewards may lead the model to overestimate the value of its predictions or cause instability during training. Inspired by approaches in modern RL systems—as also observed in studies on deep reinforcement learning for congestion control—the normalized range serves as a consistent baseline that fosters smoother gradient updates and more stable policy learning. Essentially, even when the model produces an output that is only partially correct, it still receives a non-zero reward (at least 0.1), which guarantees that the learning signal persists throughout the training process.

== Reward Clipping:
Reward clipping is another important mechanism that helps control the variance and stability of the training process. By capping partial rewards at 0.9, we deliberately prevent the model from receiving a near-perfect reward for outputs that are still not completely accurate. This technique mirrors the clipping practices observed in advanced RL algorithms like those implemented in PPO and as demonstrated in the ablation studies for DRL-based congestion control systems. In those studies, omitting clipping often led to erratic policy updates and convergence issues. Clipping ensures that while partial correctness is rewarded, it never reaches the level of an exact match. This careful capping of the reward avoids excessive optimism in the policy updates, ensuring that only the completely correct outputs garner the full reward of 1.0.

== Putting It All Together:
By setting the reward range from 0.1 to 0.9 for any output that is not an exact match, we integrate both normalization/scaling and clipping methods into our reward design. The scaling ensures that the model's learning dynamics remain stable and that the gradients are suitably informative even when outputs are only partially correct. Meanwhile, clipping keeps the reward signal bounded, which helps to prevent overshooting during policy updates and maintains a clear distinction between near-perfect performance (0.9) and absolute correctness (1.0).

This approach, inspired by the insights from MORLAIF and corroborated by empirical findings in related reinforcement learning ablation studies, ultimately leads to a more robust and efficient training process—one where the reward function accurately reflects progress toward both the foundational goal of producing algorithmically parsable output and the advanced goal of content accuracy.

== Final Score Calculation
Finally, the main function evaluate_score combines both dimensions using scalarisation. It applies a scalarisation function that immediately returns a perfect score (1.0) if the solution exactly matches the expected answer. Otherwise, it computes the final score as a weighted sum of the syntax score and the content score. By default, both aspects are weighted equally (0.5 each), but these weights can be adjusted to better reflect their relative importance in different contexts.

== Benefits of the Bifurcated Approach
By managing the score with this bifurcated approach, our method encourages foundational correctness by prioritizing the creation of algorithmically parsable output, establishing a solid structural foundation before delving into more sophisticated content verification. It also improves accuracy by isolating the evaluation into more specific tasks, helping in pinpointing and rewarding improvements in both structure and semantic quality, akin to the benefits observed in the MORLAIF study. Additionally, it provides flexibility through the use of scalarisation functions, allowing us to finely tune the overall reward, so that improvements in either syntax or content result in a corresponding improvement in the final score, leading to more efficient and targeted model training. This careful separation and subsequent recombination of evaluation aspects not only mirrors the empirical findings of MORLAIF but also ensures that our reward function accurately reflects the foundational and advanced goals necessary for successful reinforcement learning training.

]