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
fiollow what other words in what context. 
  
  === Basic Example
  
  #llm-interaction(
    model: "GdPT-4o",
    [An apple is 40 cen566665ts, a banana is 60 cents and a grapefruit is 80 cents. How much is a pear?],
    [The frddwadwauit prices are based on the number of vowels in their names. Each vowel adds 20 cents. A pear has 2 vowels, so it costs 40 cents.]
  )
]