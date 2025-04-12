#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let data_augumentation = [

= Data Augmentation

Effective training of Large Language Models (LLMs) to develop abstract reasoning capabilities for Abstract Reasoning Corpus (ARC) tasks requires addressing the inherent limitations of the original dataset. The standard ARC benchmark provides only 1,000 tasks, which presents a significant challenge: models trained on such a limited dataset are prone to memorization rather than developing generalizable reasoning abilities. Without proper augmentation, a model might simply learn to retrieve the appropriate output for a given task based on specific input patterns rather than understanding the underlying logical principles.

== Analysis of Original Dataset Characteristics

To establish a foundation for our augmentation strategy, we first examined the statistical properties of the original ARC training dataset. @task-count-distribution illustrates the distribution of training and test examples across the task corpus.

#figure(
  image("../assets/screenshots/task_count_distribution.png", width: 100%),
  caption: [Distribution of ARC tasks based on the number of train and test examples per task. The Y-axis uses a logarithmic scale. @lukhausen2025dataaugmentation],
) <task-count-distribution>

The distribution analysis reveals several statistical outliers that deviate from the normal distribution pattern. @outlier-examples presents two representative examples of these outliers.

#figure(
  grid(
    columns: 1,
    gutter: 2mm,
    image("../assets/screenshots/8dab14c2.png", width: 100%),
    image("../assets/screenshots/794b24be.png", width: 100%),
  ),
  caption: "Task 8dab14c2 with 4 test inputs and 794b24be with 10 train inputs"
) <outlier-examples>

== Geometric Transformation Techniques

Building upon methodologies established in prior research @franzen2024architect, we implemented systematic geometric transformations to preserve task structure while expanding the dataset. Our approach leverages the fact that only eight unique operations can be performed without introducing redundancy:

1. Identity (original orientation)
2. 90° rotation
3. 180° rotation
4. 270° rotation
5. Horizontal mirroring
6. Horizontal mirroring + 90° rotation
7. Horizontal mirroring + 180° rotation
8. Horizontal mirroring + 270° rotation

Notably, vertical mirroring was excluded as it produces outcomes identical to the combination of horizontal mirroring and 180° rotation, which would create duplicates in the augmented dataset.

The initial rotation transformations expanded the dataset from 1,000 to 4,000 tasks. Subsequent application of horizontal mirroring further increased the corpus to 8,000 tasks.

== Advanced Augmentation Strategies

To further diversify the dataset while maintaining task integrity, we implemented additional transformations designed to challenge the model's pattern recognition capabilities without altering the fundamental task logic.

=== Boundary Padding

We introduced a stochastic padding mechanism that adds uniform boundary elements around task grids. This transformation was applied independently to inputs and outputs with a 50% probability for each, resulting in four possible outcomes for any given task (no padding, input padding only, output padding only, or both input and output padding). This approach generated approximately 6,000 additional tasks, as the combined probability of applying padding to at least one component is 75% per task.

#figure(
  image("../assets/screenshots/train_example_variants.png", width: 100%),
  caption: [Visualization of augmentations applied to the first training example (input/output pair) from ARC task 8dab14c2. Each column represents a different transformation (Original, Horizontal Mirror (mh), Padding (pXcZ), Rotation (rX), or a combination), applied to both the input grid (top row) and the output grid (bottom row). @lukhausen2025dataaugmentation],
)

This phase of augmentation yielded approximately 14,000 tasks. While recent research suggests that even modest datasets can effectively guide LLM adaptation to novel behaviors @wu2024far100samplesgo—with OpenAI reporting successful fine-tuning with as few as 10 tasks @openai2025fine_tuning—we implemented several additional augmentation techniques to enhance dataset diversity without introducing statistical biases.

== Structural Modifications and Randomization

=== Test Pair Isolation

To facilitate single-task inference, we restructured tasks containing multiple test pairs. For each task with _n_ test pairs, we generated _n_ separate tasks, each preserving the original training examples but containing only a single test example. This restructuring ensures compatibility with the LLM's inference paradigm, which processes one test case at a time.

=== Task Duplication and Color Permutation

We duplicated the entire task corpus and applied distinct color transformations to each copy. This process involved creating a random color-to-color mapping for each task and applying it uniformly across all elements within that task. Unlike previous approaches, we deliberately included background colors in our mapping strategy to encourage the model to develop a more abstract concept of background rather than consistently associating it with a specific color value (typically 0).

#figure(
  image("../assets/screenshots/train_example_variants_colour_shuffled.png", width: 100%),
  caption: [Visualization of augmentations and color shuffle applied to the first training example (input/output pair) from ARC task 8dab14c2. @lukhausen2025dataaugmentation],
)

=== Training Example Permutation

As a final augmentation step, we randomly shuffled the order of training examples within each task. This transformation does not alter the logical structure of the tasks, as the model processes all training data during inference regardless of sequence. However, it introduces additional variation that discourages memorization by creating superficially different presentations of identical logical problems.

#figure(
  grid(
    columns: 2,
    gutter: 2mm,
    image("../assets/screenshots/8dab14c2_processed_original.png", width: 100%),
    image("../assets/screenshots/8dab14c2_processed_copy.png", width: 100%),
  ),
  caption: "Task 8dab14c2: Two copies of the same task with shuffled colors"
)

#figure(
  grid(
    columns: 2,
    gutter: 2mm,
    image("../assets/screenshots/8dab14c2_processed_original_shuffled.png", width: 100%),
    image("../assets/screenshots/8dab14c2_processed_copy_shuffled.png", width: 100%),
  ),
  caption: "Task 8dab14c2: Two copies of the same task with shuffled train order and colors"
)

== Summary of Augmentation Process

Our comprehensive augmentation methodology expanded the original 1,000-task dataset to approximately 28,000 tasks through a systematic application of geometric transformations (rotations and reflections), boundary modifications (padding), color permutations, and structural reorganizations (test pair isolation and training example reordering). The augmented dataset was formatted as JSONL for subsequent model training.

= Creating the Prompt

== Prompt Engineering Context and Challenges

The development of effective prompts for abstract reasoning tasks requires addressing several key considerations in prompt formatting and tokenization. Our review of current literature on few-shot prompting identified important factors that influenced our prompt design decisions for the Abstract Reasoning Corpus (ARC) tasks.

Zhao et al. (2021) have demonstrated that the ordering of training examples can significantly impact model performance, with their study showing performance variance from 54% to 93% on sentiment analysis benchmarks based solely on example ordering. Similarly, research indicates that LLMs exhibit recency bias, giving greater weight to examples appearing later in sequences (Cleary, 2025). Additionally, recent findings by Nori et al. (2024) and DeepSeek AI (2025) suggest that few-shot prompting may actually reduce performance in test-time compute models like o1 and DeepSeek-R1.

== Prompt Structure Development

For our implementation with the ARC tasks, we focused on developing optimal prompt structures that would:

- Clearly separate examples using consistent indicators (e.g., "\#Example 1")
- Implement standardized delimiters between examples ("\n\n")
- Transform JSON structures into formats better aligned with model processing capabilities

== Tokenization Analysis for Qwen2.5-3B Model

A critical aspect of our research involved understanding the tokenization behavior of the Qwen2.5-3B model when processing numerical grid representations. This analysis was essential for optimizing prompt structure for the ARC tasks, which rely heavily on grid-based pattern recognition.

#figure(  
  grid(  
    rows: 2,  
    gutter: 2mm,  
    image("../assets/screenshots/example_tokenization_1.png", width: 60%),  
    image("../assets/screenshots/example_tokenization_2.png", width: 100%),  
  ),  
  caption: [Token Visualisation of Different Strings @lukhausen2025tokenvisualisation]  
)

Our tokenization analysis revealed that Qwen2.5-3B encodes individual numerals as separate tokens, unlike GPT-3 models. This tokenization pattern aligns with research showing improved mathematical capabilities through appropriate numerical tokenization (Sun et al., 2023; Bostrom & Durrett, 2020; Singh et al., 2024). For the ARC tasks, this property is particularly important as it enables precise numeric pattern recognition.

We then tested whether this tokenization pattern remained consistent when numerals appeared without delimiting characters:

#figure(  
  image("../assets/screenshots/example_tokenization_3.png", width: 100%),  
  caption: [Token Visualisation of Different Strings @lukhausen2025tokenvisualisation]  
)

The results confirmed that numerals maintain their individual token status regardless of delimiter presence, suggesting potential token efficiency opportunities for grid representation.

== Array Representation Optimization

Based on our tokenization findings, we hypothesized that delimiter-free representations could significantly reduce token count while preserving essential structural information. We developed and tested a compression technique that transformed standard JSON array notation into a more compact string format:

#figure(
  grid(
    columns: (auto, auto, auto),
    gutter: 15mm,
    align(center + horizon, 
      ```
      [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ]
      ```
    ),
    align(center + horizon, text(size: 20pt, weight: "bold", $arrow.r$)),
    align(center + horizon, 
      ```
      123\n
      456\n
      789
      ```
    )
  ),
  caption: [Array representation (left) converted to space-efficient string format (right) for optimal tokenization in Qwen2.5-3B model. This transformation reduces token count while preserving grid structure for ARC tasks.]
)

Visualizing the tokenization differences between these representations confirmed the efficiency gains:

#figure(
  grid(
    columns: 3,
    gutter: 2mm,
    column-gutter: (13mm, 0mm),
    row-gutter: 0mm,
    
    align(center + horizon, 
      image("../assets/screenshots/example_tokenization_4.png", width: 90%)
    ),
    
    align(center + horizon, 
      text(size: 20pt, weight: "bold", $arrow.r$)
    ),
    
    align(center + horizon, 
      image("../assets/screenshots/example_tokenization_5.png", width: 50%)
    ),
  ),
  caption: [Tokenization visualization comparing nested array representation (left) with compressed string format (right). Individual tokens are color-coded, demonstrating how the string format reduces token count while preserving grid structure for ARC tasks. @lukhausen2025tokenvisualisation]
)

This compression approach reduced token count from 29 to 11 tokens in our experimental case—a 62% reduction while preserving all structural information.

== Model Output Format Preference Analysis

To assess the feasibility of implementing the delimiter-free representation in practice, we conducted systematic preference testing with the Qwen2.5-3B model. We analyzed the model's natural tendency to represent grid structures by prompting it to generate matrices of various dimensions.

When asked to "create a matrix structure consisting of 3×3 numbers," the model consistently produced traditional nested array formats in 70% of outputs (21/30 attempts):

#align(center)[
  #block(
    width: auto,
    inset: 10pt,
    fill: luma(240),
    radius: 4pt,
    align(left)[
      ```
      [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ]
      ```
    ]
  )
]

When prompted to "create a grid structure consisting of 6×6 numbers," the model shifted preference to space-delimited formats in 72% of cases:

#align(center)[
  #block(
    width: auto,
    inset: 10pt,
    fill: luma(240),
    radius: 4pt,
    align(left)[
      ```
      1 2 3 4 5 6
      7 8 9 10 11 12
      13 14 15 16 17 18
      19 20 21 22 23 24
      25 26 27 28 29 30
      31 32 33 34 35 36
      ```
    ]
  )
]

Notably, our delimiter-free representation never appeared in 60 generation attempts. This finding indicated that despite its tokenization efficiency, such a representation would require additional training effort for the model to reliably process, potentially diverting resources from the primary reasoning task.

== Grid Structure Comprehension Analysis

Our experimental evaluation further examined how different grid representations affected the model's understanding of structural relationships. When testing space-delimited grid presentations without explicit structural indicators, we discovered a significant comprehension limitation:

#llm-interaction(
  model: "Qwen2.5-3B",
   
    [*Train Example 1:*\
Input:\
3 1\
1 4\
Output:\
[...]]
,
[
[...]
*Train Example 1 Analysis:*\
The input consists of two numbers, 3 and 1.\
For each row in the output, we repeat one number twice (forming the pattern: \<number>\<number>). [...] \

*Train Example 2 Analysis:*\
The input consists of two numbers, 9 and 0. [...]
]
)

This structural misinterpretation persisted across multiple generation attempts (10/10 outputs), revealing that the model failed to consistently recognize space-delimited grids as unified structures. Instead, it interpreted each line as containing discrete unrelated values, losing the critical spatial relationships necessary for abstract pattern recognition.

== Optimizing the Prompt Structure

Our empirical analysis revealed a fundamental tension between tokenization efficiency and structural comprehension. While delimiter-free representations offered substantial token savings, they created significant structural interpretation challenges that would require additional training to overcome.

Based on systematic testing of this trade-off, we determined that structural clarity must take precedence over tokenization efficiency for reliable abstract reasoning. Our final prompt design implementation utilized nested arrays with explicit structural indicators while eliminating unnecessary whitespace:

#figure(
  align(center)[
    #grid(
      columns: 2,
      gutter: 15mm,
      
      // Left side - Train Example
      block(
        width: auto,
        inset: 10pt,
        fill: luma(240),
        radius: 4pt,
        align(left)[
          ```
          ### Train Example 1:
          Input:
          [
          [3,1],
          [1,4],
          ]

          Output:
          [
          [3,1,3,1,3,1],
          [1,4,1,4,1,4],
          [1,3,1,3,1,3],
          [4,1,4,1,4,1],
          [3,1,3,1,3,1],
          [1,4,1,4,1,4],
          ]
          ```
        ]
      ),
      
      // Right side - Test Input
      block(
        width: auto,
        inset: 10pt,
        fill: luma(240),
        radius: 4pt,
        align(left)[
          ```
 ### Test Input:
[
[6,5],
[9,3],
]
          ```
        ]
      )
    )
  ],
  caption: [Prompt structure left: {train}, right: {test}]
)

This format balances several critical requirements:
1. Clear structural demarcation via explicit array notation
2. Moderate token efficiency through whitespace minimization
3. Alignment with the model's demonstrated representation preferences

== System Prompt Implementation

Our research integrated the optimized example format within a specialized system prompt framework for direct LLM interaction:

```
<|im_start|>system\nYou will be provided with example inputs and outputs. Analyze the train examples. Your Goal is to find common Trasnformation pattern among those and apply the found patterns to the test input to create the Test Output.<|im_end|>\n<|im_start|>user\n {train} \n\n\n {test}\n\n Figure out how to create the Test Output. Use <think> </think> tags to reason about the problem. Return the final answer in <answer> </answer> tags as a nested list.<|im_end|>\n<|im_start|>assistant\nLet me solve this step by step.\n<think>
```

This prompt structure differs from conventional API-based interactions, as it engages directly with the model's token prediction mechanism. The specialized control tokens (`<|im_start|>` and `<|im_end|>`) precisely demarcate message boundaries with role designations (system, assistant, or user) that structure the interaction sequence.

== Conclusion

Our tokenization and prompt format research provides empirical evidence for the importance of balancing tokenization efficiency with structural clarity in abstract reasoning tasks. While our analysis identified potential optimization pathways through delimiter-free representations, controlled experimentation demonstrated that structural comprehension constraints ultimately necessitate formats that explicitly preserve grid relationships.

The final prompt structure we developed represents a systematic optimization that balances:
1. Token efficiency through minimal whitespace
2. Structural clarity through explicit array notation
3. Alignment with the model's demonstrated representational preferences

This optimized prompt structure was implemented within our ARC dataset, combining train, test, and ground truth values in a format uploaded to Hugging Face (Lukhausen, 2025) for further abstract reasoning research.

]

