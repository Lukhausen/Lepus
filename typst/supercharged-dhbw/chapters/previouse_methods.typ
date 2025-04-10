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

- Spatial transformations (rotations and reflections forming D8 symmetry operations)
- Color permutations (rearrangements of the 10 possible color values)
- Example order permutations (varying the sequence of training examples)

These augmentation strategies expanded the effective training dataset to 531,318 examples, enhancing the model's ability to recognize pattern invariants across different representations.

=== Inference Optimization Framework

The ARChitects' approach implements a three-stage inference optimization framework:

+ *Multi-perspective task presentation*: The system applies the same transformations used during training to generate 8-16 alternative perspectives of each input problem, enabling the model to approach problems from angles where the underlying pattern might be more apparent.
+ *Depth-First Search (DFS) candidate generation*: Traditional token selection methods were replaced with a custom DFS algorithm that explores solution paths with cumulative probability exceeding a specified threshold, efficiently identifying solutions with highest overall confidence.
+ *Cross-perspective candidate evaluation*: The selection strategy aggregates model confidence scores across multiple transformed perspectives of the same task, using the product of probabilities to identify consistently confident solutions.

This selection stage improved their score by approximately 25% over baseline approaches, demonstrating the effectiveness of multi-perspective evaluation.

---


== The Icecuber: A Search-Based Approach

The submission by Johan Wind (known as "Icecuber") represents an wildly different approach to the ARC benchmark that diverges from conventional machine learning methods. @top-quarks_ARC_solution Instead of training a neural network, Wind developed a system that searches for sequences of image transformations to solve each task.

=== Core Approach

Wind's approach consisted of three main components:

+ *Transformation Library*: A collection of 142 different image operations derived from 42 core concepts. These operations included basic functions like rotating images, isolating specific colors, finding the largest shape, and combining image components.

+ *Search Process*: A systematic exploration of possible combinations of these transformations (up to 4 operations in sequence) until finding a sequence that correctly transformed all training examples for a given task.

+ *Efficient Implementation*: The entire system was built in C++ with careful optimization for speed and memory usage, allowing the search process to explore more possibilities within the competition's time constraints.


The DSL implementation encapsulated fundamental visual reasoning primitives including component segmentation, color manipulation, geometric transformation, and compositional operations. This transformation library was empirically derived through manual analysis of approximately 200 ARC tasks, ensuring comprehensive coverage of recurring visual patterns. The search process implemented state deduplication mechanisms through efficient hashing techniques, enabling the exploration of substantially larger solution spaces than would otherwise be feasible within the competition's computational constraints. For tasks where no single transformation sequence solved all training examples, the system employed a "greedy stacking" approach that combined multiple partial solutions by selecting the most effective transformation for each specific example.

== Solution Strategy

The search process worked by:

+ Starting with an input images
+ Applying each possible transformation to create many intermediate images
+ Continuing this process up to 4 steps deep
+ Selecting the transformation sequence that correctly solved all training examples


== Performance Enhancement Techniques

Wind employed several techniques to improve results:

1. *Multiple Perspectives*: Running separate searches on transformed versions of the tasks (particularly diagonal flips), which helped solve problems that were easier to recognize from different orientations.

2. *Color Normalization*: Preprocessing the images to standardize colors, helping the system focus on patterns rather than specific color values.

3. *Ensemble Approach*: Running multiple configurations with different parameters and selecting the best result based on training accuracy.



Interestingly, the perspective-based approach pioneered by Wind in 2020 was later adopted and expanded upon by "The ARChitects" team in their work "The LLM ARChitect: Solving ARC-AGI Is A Matter of Perspective" . The ARChitects similarly utilized multiple perspectives through spatial transformations and achieved a reported 25% performance improvement using this technique. @franzen2024architect

]