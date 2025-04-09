#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let previouse_methods = [
= Previous Methodologys and Approaches



#let models_2 = (
    ("Human Panel", "100.0%", "98.0%", "$17.00"),
    ("o3 (low)*", "4.0%", "75.7%", "$200.00"),
    ("o1 (high)", "3.0%", "32.0%", "$4.45"),
    ("ARChitects", "2.5%", "56.0%", "$0.200"),
    ("o3-mini (medium)", "1.7%", "29.1%", "$0.280"),
    ("Icecuber", "1.6%", "17.0%", "$0.130"),
)


#figure(
  table(
    columns: (1fr, auto, auto, auto),
    table.header(
      [*Model*], [*ARC-AGI-2 Score*], [ARC-AGI-1 Score #footnote("Provided for reference, yet not used in this paper.")], [*Cost/Task*],
    ),
    ..models_2.flatten(),
  ),
  caption: [The current top 5 of the ARC AGI Leaderboard. @arcprize_leaderboard]
)

Besides the Openai Models, which are closed source and do not lay open their workings, there are two independed teams, namely the "ARChitects" and "Icecuber" havin suceeded in reaching high scores for both the ARC AGI 1 and the ARC AGI 2 Benchmark. In This section of the paper we will investigate their approches.

== The ARChitects

This approac, dcumented in their paper "The LLM ARChitect: Solving ARC-AGI
Is A Matter of Perspective" @franzen2024architect, includes variouse optimisation to archive a higher score on the spacital reasing tasks presented by the ARC Benchmnark. They fine tuned a Mistral  model (namely Mistral-NeMo-Minitron-8B-Base, a Mistral model distilled by Nvidia to arcive higher perfronamce while lowering the required computational effort on inference) not just on the Arc Dataset, but on Abstractions and trasnformations on it. E.g. Re-Arc proceduarly generated tasks, that all copy the core concepts of the 400 ARG AGI 1 tasks. @hodel2024addressingabstractionreasoningcorpus or ConceptARC, a dataset similar to the ARC Dataset, consitng of 176 simmilar basic spacial reasoning tasks. @moskvichev2023the or ARC-Heavy, which are synthetically generated ARC tasks using llms. @li2024combininginductiontransductionabstract

Additionally they use Spacial Trasnformations like Rotations, Reflections, Colour permutations and Exmaple oder Permutations to increase the diversity of the dataset. This is also What we will do later in this paper to increase our dataset size. In total they produced 531,328 traing tasks this way.

#let training_data = (
  ([Re-ARC @hodel2024addressingabstractionreasoningcorpus], "Up to 257,600"),
  ([ARC-AGI Eval (75% used)], "Up to 51,200"),
  ([Concept-ARC @moskvichev2023the], "Up to 22,528"),
  ([ARC-Heavy @li2024combininginductiontransductionabstract], "Up to 200,000")
)

#figure(
  table(
    columns: (1fr, auto),
    table.header(
      [*Dataset*], [*Tasks Used in Training*],
    ),
    ..training_data.flatten(),
  ),
  caption: [Overview of datasets and the number of training tasks used.]
)


After Fine Tuning the Model on this newly formed dataset, they took some interesting steps dusriong the inference to increase the performance of the model.
Instead of just inputting a single arc task that the model is instructed to perfrom, they applied the same transformations to the arc task as to the task of the traing dataset - rotations, reflections, color remaps and example shuffling. This means they had multile inputs for a single taks. The inputs then were processed by my the model. Token Selection was not done via greedy samling (jsut samle the next token with the heighest probailty) or Multinomial sampling (using probailit distrucbution to sleect ext token) but by Depth first search for the most total confidence in the tokens. This created high conficnede outputs for each trasnormation. 


== The Icecuber


]