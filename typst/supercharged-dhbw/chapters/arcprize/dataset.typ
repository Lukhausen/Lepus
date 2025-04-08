#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../../utils/llm.typ": llm-input, llm-output, llm-interaction

// Commenting out codly package that's causing the error
// #import "@preview/codly:1.3.0": *
// #show: codly-init

#let dataset = [
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
  image("../../assets/screenshots/arc_example_input.png", width: 80%),
  caption: [Examples from the ARC dataset showing three input-output pairs (left) and a test input (right). (training set task 392: f8ff0b80.json) @chollet2019arc],
) <arc-example>

Humans can quickly deduce the pattern in this example: colors are arranged based on their frequency in the input grid, with the most prevalent color appearing first. This abstract rule can be immediately applied to new examples after observing just a few demonstrations.

#figure(
  image("../../assets/screenshots/arc_example_solution.png", height: 15%),
  caption: [Solution showing the completed transformation, where colors are arranged vertically in descending order of their frequency in the original input grid. (training set task 392: f8ff0b80.json) @chollet2019arc],
) <arc-example-solution>

Yet for an LLM, this is less obvious. Let's test this specific task on GPT-4o. #footnote("OpenAI API was used")

In the following example, only the full JSON input was used; no prompt was applied, and the model ran at a temperature of 1 to ensure a deterministic output.

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

So Far we have been using the ARC-AGI 1 Dataset. As While we were working on this paper, the ARG AGI2 dataset was released (March 24th), from here on we will continute using the ARC AGI 2 dataset. The ARC AGI Dataset 1 
]