#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let background = [

= #acr("ARC")-AGI Benchmark
== Introduction
In 2019, François Chollet, a researcher at Google, introduced a framework to define and measure the intelligence of computational systems @chollet2019measureintelligence. Chollet differentiated between two distinct categories of intelligence: narrow, skill-based intelligence and generalization-capable intelligence. Narrow intelligence describes systems that excel at singular, predefined tasks but lack flexibility in adapting their knowledge to new or unfamiliar situations. \ 
Conversely, generalization-capable intelligence encompasses systems that can effectively transfer learned patterns and experiences to novel tasks, adapting their understanding dynamically.
Chollet observed that most contemporary #acr("RL") and #acr("ML") systems exhibited proficiency in narrow, task-specific scenarios but struggled significantly with generalization. To address this shortcoming, he proposed a comprehensive definition of intelligence.

#quote(attribution: [François Chollet @chollet2019measureintelligence], ["The intelligence of a system is a measure of its skill-acquisition efficiency over a scope
of tasks, with respect to priors, experience, and generalization difficulty"])

Central to this definition is a system's capability to generalize effectively, leveraging prior knowledge and past experiences to adapt quickly and efficiently to new challenges. This insight led to the creation of the #acrf("ARC") #acr("AGI") Benchmark @arcprize_arcagi_2024. The #acr("ARC") Benchmark assesses a system's proficiency in spatial reasoning and ability to infer novel information from limited prior examples. Through tasks designed to mimic human-like abstract reasoning, #acr("ARC") provides a robust evaluation framework for generalization-capable intelligence, advancing research in artificial general intelligence.


== Dataset

The ARC Dataset's fundamental concept is that its tasks are not memorizable, requiring LLMs to employ genuine reasoning rather than regurgitating previously encountered information. LLMs typically reproduce statistical patterns observed in their training data—learning which words frequently follow others in specific contexts. This baseline capability is evident in earlier iterations of the GPT series:

 #llm-interaction(
 model: [gpt-3.5-turbo-instruct #footnote("This model is deprecated and no longer available via the OpenAI Platform. This example has been generated in July 2024")],
 [The DHBW is
],
 [ a dual university that combines academic studies with practical training in a company. [...]]
 )

However, this pattern recognition capability does not necessarily translate to abstract conceptual understanding. Even after question-answer fine-tuning, models demonstrate limited abstract reasoning capabilities. To investigate this hypothesis systematically, we examined the performance of contemporary LLMs on the ARC dataset, first establishing a clear understanding of the dataset's structure through visualization.

#figure(
 image("../assets/screenshots/arc_example_input.png", width: 80%),
 caption: [Examples from the ARC dataset showing three input-output pairs (left) and a test input (right). (training set task 392: f8ff0b80.json) @chollet2019arc],
) <arc-example>

Humans readily identify the pattern in this example: colors are arranged based on frequency in the input grid, with the most prevalent color appearing first. After observing just a few demonstrations, this abstract rule can be immediately applied to new examples.

#figure(
 image("../assets/screenshots/arc_example_solution.png", height: 15%),
 caption: [Solution showing the completed transformation, where colors are arranged vertically in descending order of their frequency in the original input grid. (training set task 392: f8ff0b80.json) @chollet2019arc],
) <arc-example-solution>

For LLMs, however, this transformation is considerably less intuitive. We evaluated GPT-4o's performance on this specific task, providing only the unmodified JSON input with a temperature setting of 1 to ensure deterministic output. The dataset utilizes numerical values (0-9) rather than colors for grid representation:

#figure(
 caption: [The actual representation of the task as it is represented in the JSON file #footnote("This is a simplified representation of the JSON structure for better readability. (training set task 392: f8ff0b80.json)")],
  ```json
    "train": 
        "input":
 [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
 [0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0],
 [...]]
        "output": 
 [[3], [2], [8]]
        "input": [...]
        "output": [...]
 [...]
    "test":
      "input": 
 [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
 [0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0],
 [...]]
      "output": "Searching this. Find out how to create this output."
      

 ```
)

GPT-4o responded with the following analysis:

#llm-output(
 model: [gpt-4o],
 [
 [...]

    *Observations*

 - The output lists the unique numbers present in the input grid.
 - The numbers are listed in descending order based on their first appearance from top to bottom in the grid.

    *Test Input Analysis*

 For the test input, we have the following numbers in the grid:

 - 3 appears first.
 - 1 appears next.
 - 6 appears last.

    *Applying the Pattern*

 Based on the pattern observed, the output for the test input should be:

 - [3], [1], [6]

 This lists the unique numbers in the order they appear from top to bottom in the grid.
 ]
)

The analysis demonstrates that the LLM failed to identify the correct transformation rule—sorting colors in descending order of their frequency within the original input.

Our initial experiments utilized the ARC-AGI-1 Dataset. However, with the release of the ARC-AGI-2 dataset in March 2024, we transitioned to this updated Benchmark for all subsequent experiments to maintain methodological consistency. The table below presents current performance benchmarks for various models on the ARC-AGI-2 Dataset @arcprize_leaderboard.



#let models = (

 ("Human", "100.0%", "98.0%"),
 ("o3 (low)", "4.0%", "75.7%"),
 ("o1 (high)", "3.0%", "32.0%"),
 ("o3-mini (medium)", "1.7%", "29.1%"),
 ("Gemini 2.0 Flash", "1.3%", "N/A"),
 ("Deepseek R1", "1.3%", "15.8%"),
 ("Gemini-2.5-Pro-Exp-03-25", "1.3%", "12.5%"),
 ("Claude 3.7 (8K)", "0.9%", "21.2%"),
 ("GPT-4.5", "0.8%", "10.3%"),
 ("o1 (low)", "0.8%", "25.0%"),
 ("GPT-4o", "0.0%", "4.5%"),
 ("GPT-4o-mini", "0.0%", "N/A"),
)
#figure(
table(
 columns: (1fr, auto, auto),
 table.header(
 [*Model* #footnote("Multiple other models and approaches were omitted to reduce the table length, yet no models with higher scores were omitted.")], [*ARC-AGI-2 Score*], [ARC-AGI-1 Score],
 ),
  ..models.flatten(),
),
caption: [The current ARC AGI Leaderboard. @arcprize_leaderboard]
) <arc_leaderboard>

  == Investigation of Prompt Engineering Efficacy

To evaluate prompt engineering's potential for improving abstract reasoning capabilities, we implemented a systematic evaluation framework using two distinct prompting strategies across all 120 ARC-AGI-2 evaluation tasks.

Our initial experimental condition utilized GPT-4o with the following prompt architecture:

#figure(
 caption: [The Used Prompt Structure],
  ```python
SYSTEM_PROMPT_TEMPLATE = (
    "You are an ARC puzzle solver. Analyze the train examples (input/output pairs). "
    "Apply the deduced rule to the test input grid. "
    "Output your reasoning and then a JSON array in a codeblock for the predicted test output grid."
)

USER_PROMPT_TEMPLATE = (
    "**TRAIN EXAMPLES:**\n"
    "{train_examples_string}\n\n"
    "**TEST INPUT GRID:**\n"
    "{test_input_string}\n\n"
    "**PREDICTED OUTPUT GRID:**"
)
 ```
)

The experimental results revealed complete inefficacy, with zero correct predictions across all 120 evaluation tasks (0% success rate). Our experimental design utilized a temperature setting of 1 for GPT-4o across the comprehensive evaluation suite comprising 172 individual tests (as some tasks contain multiple test conditions). This methodology resulted in approximately 1 million tokens processed during evaluation, with associated computational costs of approximately €5 per complete benchmark evaluation.

Given these resource constraints, we prioritized experimental breadth over replicated trials, though we acknowledge that averaging across multiple runs would enhance statistical robustness. Our findings align with official ARC-AGI-Benchmark metrics, which report 0% performance for GPT-4o @arcprize_leaderboard. @marschhausen_lepus_benchmark.

Our computational efficiency analysis identified tokenization overhead as a significant contributor to processing costs, with raw JSON string representations resulting in inefficient token utilization—nearly every character requiring individual tokenization.

#figure(
 image("../assets/screenshots/excessive-tokenisation-example.png", width: 60%),
 caption: [Tokenization of the Input to the LLM for task 0934a4d8 @openai_tokenizer],
) <excessive-tokenisazion-example>

To address these limitations, we implemented an alternative representation strategy with dual objectives: First, enhancing semantic interpretability by transforming JSON structures into human-readable grid formats, and second, optimizing computational efficiency through reduced token consumption. Interestingly, our analysis revealed that even with grid-formatted input, the tokenization pattern remained highly granular:

#figure(
 image("../assets/screenshots/excessive-tokenisation-example2.png", width: 60%),
 caption: [Tokenization of the Input to the LLM for task 0934a4d8 @openai_tokenizer],
) <excessive-tokenisazion-example>

This tokenization behavior can be attributed to architectural attention mechanisms that benefit from precise information representation. Comparative analysis between GPT-3 and GPT-4 tokenization strategies reveals significant evolutionary improvements in numerical data processing—GPT-4 implements consistent tokenization where each number is processed as a discrete token regardless of contextual whitespace, whereas earlier models treated "3" and "3 " (with trailing space) as entirely distinct tokens.

This tokenization refinement directly enhances mathematical reasoning capabilities by maintaining referential integrity across computational contexts. Empirical research demonstrates that consistent tokenization significantly impacts arithmetic performance. Studies further indicate that models trained with consistently tokenized instances achieve enhanced cross-domain performance, accelerated convergence, and reduced hallucination. @sun2023tokenizationconsistencymattersgenerative @bostrom2020bytepairencodingsuboptimal @singh2024tokenizationcountsimpacttokenization.

#figure(
 image("../assets/screenshots/tokenizer-comparison.png", width: 100%),
 caption: [Tokenization Comparison between GPT-4o and GPT-3 @openai_tokenizer],
)

After evaluating multiple representation strategies, we determined that our approach optimized tokenization efficiency within text-based constraints without leveraging GPT-4o's visual processing capabilities. While theoretical alternatives exist—such as Unicode color block representation (🟥, 🟦, 🟧, 🟨, 🟩, 🟪, 🟫, ⬛, ⬜, 🔲, 🔳)—our analysis suggested minimal potential performance improvements from such adaptations.

For our second experimental condition, we implemented an enhanced prompt incorporating Chain of Thought reasoning and step-by-step verification methodologies—techniques empirically demonstrated to significantly improve model reasoning capabilities @lightman2023letsverifystepstep @wei2023chainofthoughtpromptingelicitsreasoning:

#figure(
 caption: [The New Prompt Structure],
  ```python
SYSTEM_PROMPT_TEMPLATE = (
"""
You will be provided with example inputs and outputs. Analyze the train examples. These tasks follow the style of ARC (Abstraction and Reasoning Corpus) problems, where the objective is to deduce transformation rules from visual or structural patterns.

Your goal is to find common rules that are applied to the input to be transformed into the output.  
To achieve this, do the following:  
1. Find possible rules that could be applied in combination to achieve the transformation from the input to the output. Be really precise in the rule definition. What transformations have to be applied exactly? What are they based upon?  
2. Test those rules by applying them to all the available train examples and seeing if they reproduce the desired output. You have to verify that the deduced ruleset actually works with the train examples before proceeding to the test.  
If the desired output is achieved in all present examples, then apply those found rules to the given test input.  
If the ruleset you deduced fails at any of the train examples, begin again from step one and modify the rules you deduce.  
Then test again for all train examples before proceeding to the test. (Output your final solution as a JSON array in a code block)
"""
)

# Adjusted template slightly to ensure good spacing with multi-line grids
USER_PROMPT_TEMPLATE = (
    "**TRAIN EXAMPLES:**\n\n"
    "{train_examples_string}\n\n\n\n"
    "**TEST INPUT GRID:**\n\n"
    "{test_input_string}\n\n"
)
```


)

Despite these methodological enhancements, experimental results maintained a 0% solve rate. Our analysis indicates that current LLMs fundamentally lack the necessary abstraction capabilities to understand the transformation logic underpinning ARC tasks—particularly those requiring world knowledge concepts such as gravity, suction, rotation, and mirroring. This experimental condition processed 865,000 input tokens across 174 API requests (120 tasks comprising 172 tests, plus 2 repeated requests due to API errors), with approximate computational costs of €5.

#figure( 
 image("../assets/screenshots/benchmark-run-2-results.png", width: 50%),
 caption: [The Type of Failure of the Second Run. For full run details, see  @marschhausen_lepus_benchmark_2],
)

Based on these experimental findings, we conclude that prompt engineering alone — even employing methodologies such as Chain of Thought reasoning and step-by-step verification — cannot overcome the fundamental abstraction limitations preventing LLMs from solving ARC-AGI-tasks.

]



