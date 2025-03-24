#import "@preview/supercharged-dhbw:3.4.0": acr, acrf

#let introduction = [
  == Introduction
In 2019, François Chollet, a researcher at Google, introduced a framework to define and measure the intelligence of computational systems @chollet2019measureintelligence. Chollet differentiated between two distinct categories of intelligence: narrow, skill-based intelligence and generalization-capable intelligence. Narrow intelligence describes systems that excel at singular, predefined tasks but lack flexibility in adapting their knowledge to new or unfamiliar situations. \ 
Conversely, generalization-capable intelligence encompasses systems that can effectively transfer learned patterns and experiences to novel tasks, adapting their understanding dynamically.
Chollet observed that most contemporary #acr("RL") and #acr("ML") systems exhibited proficiency in narrow, task-specific scenarios but struggled significantly with generalization. To address this shortcoming, he proposed a comprehensive definition of intelligence

#quote(attribution: [François Chollet @chollet2019measureintelligence], ["The intelligence of a system is a measure of its skill-acquisition efficiency over a scope
of tasks, with respect to priors, experience, and generalization difficulty"])

Central to this definition is a system's capability to generalize effectively, leveraging prior knowledge and past experiences to adapt quickly and efficiently to new challenges. This insight led to the creation of the #acrf("ARC") #acr("AGI") Benchmark @arcprize_arcagi_2024. The #acr("ARC") Benchmark assesses a system's proficiency in spatial reasoning and ability to infer novel information from limited prior examples. Through tasks designed to mimic human-like abstract reasoning, #acr("ARC") provides a robust evaluation of generalization-capable intelligence, aiming to push the boundaries of artificial general intelligence research.
] 