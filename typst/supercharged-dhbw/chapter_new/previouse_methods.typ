#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let previouse_methods = [
= Previous Methodologies and Approaches

This chapter presents an examination of leading methodological frameworks that have demonstrated significant performance on the ARC-AGI Benchmark. While OpenAI's proprietary models currently occupy prominent positions on the leaderboard, our analysis focuses on two independent research teams—"ARChitects" and "Icecuber"—whose open methodologies have achieved substantial results across both the ARC-AGI-1 and ARC-AGI-2 Benchmarks, as illustrated in @arc-leaderboard-mini.

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
) <arc-leaderboard-mini>

== The ARChitects: A Perspective-Based Approach to ARC-AGI


The methodology developed by "The ARChitects" in "The LLM ARChitect: Solving ARC-AGI Is A Matter of Perspective" @franzen2024architect presents significant advancements in addressing the challenges posed by the Abstraction and Reasoning Corpus (ARC) benchmark. Their approach implements multiple methodological innovations that collectively enhance model performance on spatial reasoning tasks.

=== Model Selection and Dataset Augmentation

The research team employed the Mistral-NeMo-Minitron-8B-Base model—a distilled variant of Mistral optimized by NVIDIA for inference efficiency while maintaining high performance characteristics. This foundation model underwent fine-tuning on a comprehensive dataset comprising @sreenivas2024llmpruningdistillationpractice:

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

A central innovation in their methodology was the systematic application of data transformations to enhance pattern recognition capability. These transformations included:

- Spatial transformations (the group of eight symmetries of a square: the four rotational symmetries (0°, 90°, 180°, 270°) and the four reflection symmetries - denoted D#sub[8])
- Color permutations (rearrangements of the 10 possible color values)
- Example order permutations (varying the sequence of training examples)

These augmentation strategies expanded the effective training dataset to 531,318 examples, enhancing the model's ability to recognize pattern invariants across different representations.

=== Inference Optimization Framework

The ARChitects' approach implements a three-stage inference optimization framework:

+ *Multi-perspective task presentation*: The system applies the same transformations used during training to generate 8-16 alternative perspectives of each input problem, enabling the model to approach problems from angles where the underlying pattern might be more apparent.

+ *Depth-First Search (DFS) candidate generation*: Rather than selecting the single 'best' next token at every step, the model branches out (as in DFS), following several almost-as-good next tokens all the way to the end of the answer and multiplying the probabilities along each branch. It then retains the branch with the highest total product (overall confidence), meaning that a slightly less probable intermediate token can still be successful if it leads to a much more definitive final answer.

+ *Cross-perspective candidate evaluation*: The selection strategy aggregates model confidence scores across multiple transformed perspectives of the same task, using the product of probabilities to identify consistently confident solutions.

This selection stage improved their score by approximately 25% over baseline approaches, demonstrating the effectiveness of multi-perspective evaluation.

---


== The Icecuber: A Search-Based Approach

The submission by Johan Wind (known as "Icecuber") represents an wildly different approach to the ARC benchmark that diverges from conventional machine learning methods. @top-quarks_ARC_solution Instead of training a neural network, Wind developed a system that searches for sequences of image transformations to solve each task.

=== Core Approach

Wind's approach consisted of three main components:

- *Transformation Library*: A collection of 142 image processing operations derived from 42 core concepts. These operations included basic functions such as rotating images, isolating specific colours, identifying the largest shape and combining image components. Wind identified these operations manually by analysing approximately 200 ARC tasks and noting frequently recurring visual patterns, thus ensuring broad coverage of common task-solving primitives.

- *Search Process*: A systematic exploration of possible combinations of these transformations (up to four operations in sequence) until a sequence was found that correctly transformed all training examples for a given task. To optimise this search, every intermediate image was hashed (converted into a compact numerical fingerprint). If the solver encountered a state it had already seen, it skipped further exploration of that branch. This 'state deduplication' allowed the system to efficiently traverse a significantly larger search space within the competition’s computational limits.

- *Efficient implementation*: The entire system was built in C++ with careful optimisation for speed and memory usage, enabling deeper exploration of solution sequences within tight time constraints. Additionally, for tasks where no single sequence could solve all the training examples, the system employed a pragmatic 'greedy stacking' strategy. It found the best-performing sequence for each example individually and then combined these partial solutions, selecting whichever transformation worked best for each specific case. This enabled Wind's solver to handle complex tasks that a single universal sequence could not solve, thereby significantly boosting the overall success rate without imposing excessive computational demands.

=== Solution Strategy

The search process worked by:

+ Starting with an input images
+ Applying each possible transformation to create many intermediate images
+ Continuing this process up to 4 steps deep
+ Selecting the transformation sequence that correctly solved all training examples


=== Performance Enhancement Techniques

Wind employed several techniques to improve results:

1. *Multiple Perspectives*: Running separate searches on transformed versions of the tasks (particularly diagonal flips), which helped solve problems that were easier to recognize from different orientations.

2. *Color Normalization*: Preprocessing the images to standardize colors, helping the system focus on patterns rather than specific color values.

3. *Ensemble Approach*: Running multiple configurations with different parameters and selecting the best result based on training accuracy.



Interestingly, the perspective-based approach pioneered by Wind in 2020 was later adopted and expanded upon by "The ARChitects" team in their work "The LLM ARChitect: Solving ARC-AGI Is A Matter of Perspective" . The ARChitects similarly utilized multiple perspectives through spatial transformations and achieved a reported 25% performance improvement using this technique. @franzen2024architect

]