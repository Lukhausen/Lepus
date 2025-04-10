#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let reward = [
  = Defining a Reward Function

Paramount to a successful training in RL is to have a reward function that actually reflects what we want to achieve in the RL training run. It's important to first of all achieve the foundational goals before heading to more advanced goals. In our case, one of the most foundational goals of the LLM is to produce algorithmically parsable output so we can even start to compare it to the actually desired result.

The paper ‘Multi-Objective Reinforcement Learning from AI Feedback’ @williams2024multiobjectivereinforcementlearningai (MORLAIF) provides valuable insights into the optimisation of AI evaluation systems by separating different evaluation aspects. These findings can be applied to the development of a two-stage evaluation structure that evaluates syntax and content agreement separately.
MORLAIF demonstrates that decomposing complex evaluation tasks into more specific subtasks leads to better overall results. Rather than using a single preference algorithm that covers all aspects of evaluation simultaneously, the paper shows clear advantages of developing separate models for different principles such as factuality, toxicity and comprehensibility.
This realisation can be applied directly to the evaluation of AI expenditure. Instead of using a single evaluation metric that covers all aspects, the separation into syntactic and content evaluation dimensions is logical and effective.
If you apply this to our goal, you get two evaluation aspects: firstly, compliance with the required list format and the correct grid dimensions, and secondly, compliance of the content result with the requirement.
The advantages of such a separate evaluation of syntax and content are confirmed by the MORLAIF paper: ‘By breaking down preference modelling into specific principles, the feedback collection and preference model training becomes a more straightforward and well-defined task, which we hypothesize will lead to improved preference model performance.’ This hypothesis was confirmed in the experiments, with the specific models achieving significantly higher accuracy than individual models.
We also use scalarisation functions to combine the separate ratings. These functions offer flexible methods for combining the two evaluation dimensions (syntax and content) into an overall evaluation. By merging them, we can then utilise and evaluate the reward score more efficiently.

]