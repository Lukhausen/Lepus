#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let arcprize = [
= #acr("ARC")-AGI Benchmark
  == Introduction
In 2019, François Chollet, a researcher at Google, introduced a framework to define and measure the intelligence of computational systems @chollet2019measureintelligence. Chollet differentiated between two distinct categories of intelligence: narrow, skill-based intelligence and generalization-capable intelligence. Narrow intelligence describes systems that excel at singular, predefined tasks but lack flexibility in adapting their knowledge to new or unfamiliar situations. \ 
Conversely, generalization-capable intelligence encompasses systems that can effectively transfer learned patterns and experiences to novel tasks, adapting their understanding dynamically.
Chollet observed that most contemporary #acr("RL") and #acr("ML") systems exhibited proficiency in narrow, task-specific scenarios but struggled significantly with generalization. To address this shortcoming, he proposed a comprehensive definition of intelligence

#quote(attribution: [François Chollet @chollet2019measureintelligence], ["The intelligence of a system is a measure of its skill-acquisition efficiency over a scope
of tasks, with respect to priors, experience, and generalization difficulty"])

Central to this definition is a system's capability to generalize effectively, leveraging prior knowledge and past experiences to adapt quickly and efficiently to new challenges. This insight led to the creation of the #acrf("ARC") #acr("AGI") Benchmark @arcprize_arcagi_2024. The #acr("ARC") Benchmark assesses a system's proficiency in spatial reasoning and ability to infer novel information from limited prior examples. Through tasks designed to mimic human-like abstract reasoning, #acr("ARC") provides a robust evaluation of generalization-capable intelligence, aiming to push the boundaries of artificial general intelligence research.


== Dataset

The idea behind the ARC Dataset is that the tasks are not memorizable, so 
that the LLM trying to solve the task actually needs to reason instead of 
regurgitating previously seen information. In many cases, an LLM is just 
regurgitating information observed in its training data. This is its basic 
ability: an LLM that has not yet passed the fine-tuning on question-answer 
pairs has just learned the statistics of what words typically 
follow what other words in what context. We can observe this behavior in early versions of the GPT series:

  #llm-interaction(
    model: [gpt-3.5-turbo-instruct #footnote("This model is deprecated and no longer available via the OpenAI Platform. This example has been generated in July 2024")],
    [The DHBW is
],
    [ a dual university that combines academic studies with practical training in a company. [...]]
  )

Yet this behavior does not make the models understand abstract ideas. In fact, even after the fine-tuning on question-answer pairs, the models still seem to have limited capabilities of abstract reasoning. To test this hypothesis, we will take a look at the performance of a regular LLM on the ARC dataset. But to better understand how the dataset looks, let us visualize it. 

#figure(
  image("../assets/screenshots/arc_example_input.png", width: 80%),
  caption: [Examples from the ARC dataset showing three input-output pairs (left) and a test input (right). (training set task 392: f8ff0b80.json) @chollet2019arc],
) <arc-example>

Humans can quickly deduce the pattern in this example: colors are arranged based on their frequency in the input grid, with the most prevalent color appearing first. This abstract rule can be immediately applied to new examples after observing just a few demonstrations.

#figure(
  image("../assets/screenshots/arc_example_solution.png", height: 15%),
  caption: [Solution showing the completed transformation, where colors are arranged vertically in descending order of their frequency in the original input grid. (training set task 392: f8ff0b80.json) @chollet2019arc],
) <arc-example-solution>

Yet for an LLM, this is less obvious. Let's test this specific task on GPT-4o. #footnote("OpenAI API was used")

In the following example, only the full JSON input was used; no prompt was applied, and the model ran at a temperature of 1 to ensure a deterministic output. The Dataset itself uses numbers between 0 and 9 instead of colours.

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

This is, waht GPT-4o answered.

#llm-output(
  model: [gpt-4o],
  [
    [...]

    *Observations*

    - The output lists the unique numbers present in the input grid.
    - The numbers are listed in descending order of their first appearance from top to bottom in the grid.

    *Test Input Analysis*

    For the test input, we have the following numbers in the grid:

    - 3 appears first.
    - 1 appears next.
    - 6 appears last.

    *Applying the Pattern*

    Based on the pattern observed, the output for the test input should be:

    - [3], [1], [6]

    This lists the unique numbers in the order they first appear from top to bottom in the grid.
  ]
)

The LLM did not have the understanding that the colors are sorted in descending order of their frequency of occurrence in the original input. 

So Far we have been using the ARC-AGI 1 Dataset. As While we were working on this paper, the ARG AGI2 dataset was released (March 24th), from here on we will continute using the ARC AGI 2 dataset. Every single Experiment in this paper was conducted on the ARC AGI 2 dataset for consitency. Below is a table Showcasing the current Benchmarks of different models on the ARC AGI-2 Dataset. @arcprize_leaderboard



#let models = (
  ("Human", "100.0%"),
  ("o3 (low)", "4.0%"),
  ("o1 (high)", "3.0%"),
  ("o3-mini (medium)", "1.7%"),
  ("Gemini 2.0 Flash", "1.3%"),
  ("Deepseek R1", "1.3%"),
  ("Gemini-2.5-Pro-Exp-03-25", "1.3%"),
  ("Claude 3.7 (8K)", "0.9%"),
  ("GPT-4.5", "0.8%"),
  ("o1 (low)", "0.8%"),
  ("GPT-4o", "0.0%"),
  ("GPT-4o-mini", "0.0%"),
) 

#table(
  columns: (1fr, auto),
  table.header(
    [*Model* #footnote("Multiplpe other models and approaches were omited to reduce the table length, yet no models with higher scroes were ommited.")], [*ARC-AGI-2 Score*],
  ),
  ..models.flatten()
) 
  == How Far Can Prompt Engineering Go?

 



Running GPT 4o with the following prompt:
#figure(
  caption: [The USed Prompt Structre],
  ```python
SYSTEM_PROMPT_TEMPLATE = (
    "You are an ARC puzzle solver. Analyze the train examples (input/output pairs). "
    "Apply the deduced rule to the test input grid. "
    "Output your reasoning and then a JSON array in a Codeblock for the predicted test output grid."
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

This prompt was completedwith a whopping 0 of 120 correct prediecitons. This is a succes rate of 0%. We have only tested oncewith a temperature setting of 1 for GPT-4o as a single benchmarking of the 120 evaluation tasks (consiting of in total 172 tasks as some tasks have more than a single test we need to pass.) whcih resuklts in roughly over 2 million tokens send and recieved, summing a single evaluation to roughly 5 dollars. 
Out of this reason we are not averaging multiple runs, even though this would be statistically more accurate. Yet also the official numbers for the ARG AGI Benchmark are at 0% for the GPT-4o model. @arcprize_leaderboard To see the full experiment: @marschhausen_lepus_benchmark

The high price here is caused by the toklenisation that is appied to the raw input of the task, as in the raw jsons tring nearly every single character is a new token. 

#figure(
  image("../assets/screenshots/excessive-tokenisation-example.png", width: 60%),
  caption: [Tokenisation of the Input to the llm for task 0934a4d8 @openai_tokenizer],
) <excessive-tokenisazion-example>

Our first idea to make teh input a) clearer for the llm to understand, as a raw json string is normaly not what a llm is trains on, and b reduce the evaluations costs, was to trasnfrom the json string into a more human readable grid repesentation of the task data
Interestingsly the Tokenizer still tonekizes nearly every single single character when inputting a grid fromat like the folloing: 

#figure(
  image("../assets/screenshots/excessive-tokenisation-example2.png", width: 60%),
  caption: [Tokenisation of the Input to the llm for task 0934a4d8 @openai_tokenizer],
) <excessive-tokenisazion-example>

Yet, this is the closest we can repsent it as text, without using the vision capabilites of GPT 4o. In theory a representation using unicode colour blocks (🟥,🟦,🟧,🟨,🟩,🟪,🟫,⬛,⬜,🔲,🔳) could be used but its unliketly to yield better results. For now lets adjust the Prompt to encoperate Chain of HTought Thinking and Step by step verification to potentially improve the results of the benchamrk. Those techniques are shown to dignificantely improve model resoning skills @lightman2023letsverifystepstep @wei2023chainofthoughtpromptingelicitsreasoning

Here is the New prompt Structrue we used:

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


This run resulted as expected with a 0% solve rate. 
The Problem is that the LLM does not understand the logic behind the trasnformations at all. Most Trasnfromations rely on world knowledge like Dravity, suctions, rotation, mirroring, etc but the lmm has no way of abstracting this to the task at hand. This run sumed up to be 865k Input tokens and 174 Requests to the API (120 task, with 172 test, 2 needed to be sent again beacucse of API errors Which is roughly 5€ in api costs.)

#figure( 
  image("../assets/screenshots/benchmark-run-2-results.png", width: 50%),
  caption: [The Type of Failure of the Second Run. To See full run: @marschhausen_lepus_benchmark_2],
)


As we are not moving forwards here, we can conclude that simply prompting a state of the art model with a more complex prompt does not yield any better results. In facht, it yields no results at all.

]