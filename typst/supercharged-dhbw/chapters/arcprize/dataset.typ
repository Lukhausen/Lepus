#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../../utils/llm.typ": llm-input, llm-output, llm-interaction

#let dataset = [
== Dataset

The Idea behind the ARC Dataset is that the Tasks are not momorizable, so 
that the LLM trying to solve the task actually needs to reason instead of 
regurgitating previousely seen infromation. in many cases an LLM is just 
regurgitating infromation observed in its traing data. Its its Basic 
ability. a LLM, that has not yet passed the finetuning on question 
answerrt pairs has jsut learend the statistics of what words typically 
fiollow what other words in what context. We can observer this behaviour in early version of the gpt series:

  #llm-interaction(
    model: [gpt-3.5-turbo-instruct #footnote("This model is depricated and no longer available via the openai PLatfrom. Tis exmaple has been generated in July 2024")],
    [The DHBW is
],
    [ a dual university that combines academic studies with practical training in a company. [...]]
  )

Yet this behaviour does not make the models abstract ideas. In fact evena fter the fine tuning on question answer pairs the models still seem to hae limited capabilites of abstrac reasoning. TO test this hypoithes, we will tkae a look at the peromance of a regualr llm on the arc dataset. but to better understand how the dataset looks let us visualize it. 

#figure(
  image("../../assets/screenshots/arc_example_input.png", width: 100%),
  caption: [Examples from the ARC dataset showing three input-output pairs (left) and a test input (right). Each pair demonstrates how a red line pattern transforms into a staircase pattern with green above and blue below. (training set task 255: a65b410d.json) @chollet2019arc],
) <arc-example>

As a human it seems to be immediately obviouse that everything below the red line is blue and everything above it is green and its a rreverse staircase from the bottom to the top. so we can create output based on this novel idea that we leraredn from jsut the 3 examples given to us.

#figure(
  image("../../assets/screenshots/arc_example_solution.png", width: 30%),
  caption: [Solution pattern showing the completed staircase transformation, where the red input line has been converted into a staircase pattern with green cells above and blue cells below. (training set task 255: a65b410d.json) @chollet2019arc],
) <arc-example-solution>

Yet for a LLM this is less obviouse. Lets test this specific task on GPT 4o.



]



