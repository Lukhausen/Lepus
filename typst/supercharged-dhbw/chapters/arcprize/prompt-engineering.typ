#import "@preview/supercharged-dhbw:3.4.0": acr, acrf

#let prompt-engineering = [
  == How Far Can Prompt Engineering Go?

As ARC Prize 2 was released 



Running GPT 4o with the following prompt:
#figure(
  caption: [The actual representation of the task as it is represented in the JSON file ],
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
Out of this reason we are not averaging multiple runs, even though this would be statistically more accurate.


]