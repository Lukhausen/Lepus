#import "@preview/supercharged-dhbw:3.4.0": acr, acrf

#let prompt-engineering = [
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
  image("../../assets/screenshots/excessive-tokenisation-example.png", width: 60%),
  caption: [Tokenisation of the Input to the llm for task 0934a4d8 @openai_tokenizer],
) <excessive-tokenisazion-example>

Our first idea to make teh input a) clearer for the llm to understand, as a raw json string is normaly not what a llm is trains on, and b reduce the evaluations costs, was to trasnfrom the json string into a more human readable grid repesentation of the task data
Interestingsly the Tokenizer still tonekizes nearly every single single character when inputting a grid fromat like the folloing: 

#figure(
  image("../../assets/screenshots/excessive-tokenisation-example2.png", width: 60%),
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
  image("../../assets/screenshots/benchmark-run-2-results.png", width: 50%),
  caption: [The Type of Failure of the Second Run. To See full run: @marschhausen_lepus_benchmark_2],
)


As we are not moving forwards here, we can conclude that simply prompting a state of the art model with a more complex prompt does not yield any better results. In facht, it yields no results at all.

]