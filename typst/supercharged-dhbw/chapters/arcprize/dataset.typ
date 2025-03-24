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
]