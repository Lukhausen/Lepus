#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction
#import "../utils/note.typ": note

#let data_augumentation = [

= Data Augmentation <data_aug>

Effective training of Large Language Models (LLMs) to develop abstract reasoning capabilities for Abstract Reasoning Corpus (ARC) tasks requires addressing the inherent limitations of the original dataset. The standard ARC benchmark provides only 1,000 tasks, which presents a significant challenge: models trained on such a limited dataset are prone to memorization rather than developing generalizable reasoning abilities. Without proper augmentation, a model might simply learn to retrieve the appropriate output for a given task based on specific input patterns rather than understanding the underlying logical principles.

== Analysis of Original Dataset Characteristics

To establish a foundation for our augmentation strategy, we first examined the statistical properties of the original ARC training dataset. @task-count-distribution illustrates the distribution of training and test examples across the task corpus.

#figure(
  image("../assets/screenshots/task_count_distribution.png", width: 100%),
  caption: [Distribution of ARC tasks based on the number of train and test examples per task. The Y-axis uses a logarithmic scale. @lukhausen2025dataaugmentation],
) <task-count-distribution>

The chart displays the number of tasks (y-axis, logarithmic scale) categorized by the number of training (blue) and testing (orange) examples per task (x-axis).

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

This analysis provides a clear statistical image of the task distribution, establishing a baseline understanding of the dataset's composition. The following sections detail our approach to enriching this dataset while preserving the semantic integrity of the original tasks.

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

We introduced a stochastic padding mechanism that adds uniform boundary elements around task grids. This transformation was applied independently to inputs and outputs with a 50% probability for each. For any given task, padding was applied consistently across all its constituent examples: the same boundary was added to all training and test inputs, and likewise for all outputs. This consistent application ensures the padding can be learned as a deductible, non-semantic feature, resulting in four possible structural variants for each task (no padding, input padding only, output padding only, or both). This approach generated approximately 6,000 additional tasks, as the combined probability of applying padding to at least one component is 75% per task.

#figure(
  image("../assets/screenshots/train_example_variants.png", width: 100%),
  caption: [Visualization of augmentations applied to the first training example (input/output pair) from ARC task 8dab14c2. Each column represents a different transformation (Original, Horizontal Mirror (mh), Padding (pXcZ), Rotation (rX), or a combination), applied to both the input grid (top row) and the output grid (bottom row). @lukhausen2025dataaugmentation],
)

This phase of augmentation yielded approximately 14,000 tasks. While recent research suggests that even modest datasets can effectively guide LLM adaptation to novel behaviors @wu2024far100samplesgo - with OpenAI reporting successful fine-tuning with as few as 10 tasks @openai2025fine_tuning - we implemented several additional augmentation techniques to enhance dataset diversity without introducing statistical biases.

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

While Hodl's Re-ARC approach @hodel2024addressingabstractionreasoningcorpus provides substantially more training data through procedural generation, we chose not to adopt this methodology to avoid a critical local minimum problem. Hodl's dataset is primarily derived from ARC-AGI-1 tasks, which exhibit a significantly smaller learning curve compared to the more complex ARC-AGI-2 tasks that constitute our evaluation benchmark. Including such a massive volume of ARC-AGI-1-derived examples would risk the model converging to a local minimum optimized for the simpler ARC-AGI-1 patterns, potentially preventing effective learning of the more challenging ARC-AGI-2 task structures. Since our objective is to develop reasoning capabilities specifically for ARC-AGI-2 performance, we deliberately maintained focus on a smaller but more targeted dataset to avoid this pattern optimization trap.

= Prompt Structure Optimization

Building upon our data augmentation efforts, we investigate how to optimally present training data to language models through systematic prompt design and tokenization analysis.

== Prompt Engineering Context and Challenges

The optimization of prompt structures for abstract reasoning tasks necessitates addressing multiple interdependent variables that significantly impact model performance. Our systematic analysis of current literature on few-shot prompting revealed factors affecting reasoning capabilities within the Abstract Reasoning Corpus (ARC) task domain.

Empirical research quantified the substantial impact of example sequencing, demonstrating performance variance from 54% to 93% on sentiment analysis benchmarks based solely on permutations of identical training examples. @zhao2021calibrateuseimprovingfewshot This finding carries significant implications for abstract reasoning tasks where pattern recognition is highly context-dependent. Further investigations have documented a recency bias phenomenon in large language models (LLMs), whereby models assign disproportionate weight to examples appearing later in the sequence, potentially compromising generalization capabilities. @cleary2025fewshot

Contrary to conventional assumptions regarding few-shot learning efficacy, recent findings from experiments with test-time compute models (@test-time-compute) indicate performance degradation. Researchers at OpenAI and Microsoft @nori2024medprompto1explorationruntime observed statistically significant decreases in task performance when applying few-shot prompting to the o1 model architecture. These results align with independent observations by DeepSeek regarding their test-time compute model DeepSeek-R1, suggesting a fundamental limitation in current few-shot learning paradigms for certain model architectures. @deepseekai2025deepseekr1incentivizingreasoningcapability

== Prompt Structure Development

Our approach to prompt optimization established a framework with three primary objectives:

1. Implementation of explicit demarcation between examples using consistent syntactic indicators (e.g., "\#Example 1")
2. Standardization of delimiter systems to enhance input parsing reliability
3. Transformation of complex data structures into formats optimized for model processing

These structural imperatives were derived from theoretical considerations regarding token-level processing in transformer-based architectures and subsequently validated through empirical testing.

== Tokenization Analysis for Qwen2.5-3B Model <tokenization-analysis>

A critical component of our research involved tokenization analysis of the Qwen2.5-3B model @bai2023qwen when processing numerical grid representations. Given the central importance of grid-based pattern recognition in ARC tasks, this investigation was essential for establishing an empirical foundation for subsequent optimization strategies.

#figure(  
 grid(  
 rows: 2,  
 gutter: 2mm,  
 image("../assets/screenshots/example_tokenization_1.png", width: 60%),  
 image("../assets/screenshots/example_tokenization_2.png", width: 100%),  
 ),  
 caption: [Token Visualization of Different Strings. Each colored segment represents an individual token as processed by the model. @lukhausen2025tokenvisualisation]  
)

Our analysis revealed a distinctive tokenization pattern wherein Qwen2.5-3B encodes individual numerals as discrete tokens, contrasting with the encoding mechanisms employed in GPT-3 model architectures. This tokenization characteristic aligns with research documenting enhanced mathematical processing capabilities through appropriate numerical tokenization strategies. @sun2023tokenizationconsistencymattersgenerative @bostrom2020bytepairencodingsuboptimal @singh2024tokenizationcountsimpacttokenization For ARC tasks specifically, this property facilitates precise numeric pattern recognition, a capability essential for abstract reasoning functions.

To establish tokenization consistency across varying syntactic contexts, we conducted experiments examining numeral tokenization in the absence of delimiting characters:

#figure(  
 image("../assets/screenshots/example_tokenization_3.png", width: 100%),  
 caption: [Token Visualization of Different Strings @lukhausen2025tokenvisualisation]  
)

The experimental results confirmed consistent preservation of individual token status for numerals regardless of delimiter presence, suggesting potential optimization opportunities for grid representation efficiency.

== Array Representation Optimization

Building upon our tokenization findings, we hypothesized that delimiter-free representations could substantially reduce computational overhead while maintaining structural integrity. We designed and implemented a compression that transformed standard JSON array notation into a more efficient string format:

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

Comparative tokenization analysis between these representational formats provided quantitative validation of the efficiency improvements:

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

This optimization approach reduced the token count by 18 (from 29 to 11), a 62% reduction, in our experimental implementation while preserving all structural information necessary for pattern recognition, a significant efficiency enhancement with potential implications for computational resource utilization in the subsequent training runs.

== Model Output Format Preference Analysis

To assess the practical viability of implementing delimiter-free representations, we evaluated the model's innate format preferences through systematic generative testing. We analyzed the Qwen2.5-3B model's representation tendencies by prompting it to generate matrix structures.

When tasked with generating a "matrix structure consisting of 3×3 numbers," the model demonstrated a statistically significant preference (70% of outputs across 30 independent trials) for traditional nested array formats:

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

When the experimental prompt was modified to request a "grid structure consisting of 6×6 numbers," we observed a shift in representational preference toward space-delimited formats (72% of outputs):

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

A particularly notable finding from our experimental series was the complete absence of delimiter-free representations across 60 generation attempts. This empirical observation suggests that despite the computational advantages of such representations, their practical implementation would necessitate increased training to establish reliable processing capabilities. This could potentially divert computational resources from the primary abstract reasoning objectives. Furthermore, the model clearly showed a preference for delimiter-separated outputs.

== Grid Structure Comprehension Analysis

Our experimental investigation further examined the impact of different grid representations on structural interpretation capabilities. Through controlled testing of space-delimited grid presentations without explicit structural indicators, we identified a significant limitation in the model's ability to recognize spatial relationships:

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

This pattern of structural misinterpretation demonstrated remarkable consistency across multiple experimental iterations (15/15 outputs), revealing a fundamental constraint in the model's capacity to infer unified grid structures from space-delimited representations. Instead of recognizing the spatial relationships that define grid structures, the model interpreted each line as containing discrete, unrelated values, essentially decomposing the two-dimensional representation into a one-dimensional sequence and thereby losing the critical spatial context necessary for abstract pattern recognition.

== Optimizing the Prompt Structure

Our investigations revealed a fundamental methodological tension between tokenization efficiency and structural comprehension integrity. While delimiter-free representations offered substantial computational advantages through token reduction, they simultaneously introduced significant structural interpretation challenges that would require dedicated training to overcome.

Through iterative testing and systematic evaluation of this performance trade-off, we established that structural comprehension reliability must precede tokenization efficiency for effective abstract reasoning task performance. Therefore, our final prompt design employed nested arrays with explicit structural indicators while eliminating superfluous whitespace characters:

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

This optimized format systematically addresses multiple performance constraints:

1. Explicit structural demarcation through standardized array notation, enhancing grid relationship recognition
2. Computational efficiency through whitespace elimination
3. Alignment with empirically validated model representation preferences, reducing cognitive dissonance during pattern identification and generation

#note[
Despite identifying the nested array format with delimiters as optimal for model comprehension, computational limitations forced a compromise. The semantically optimal variant generated 22,000-token prompts, creating unacceptable overhead during training on our dual H200 GPU setup and significantly slowing backpropagation.

We implemented a hybrid format that preserved structural integrity while reducing computational demands by maintaining brackets for hierarchical structure but eliminating internal delimiters between numerical elements (e.g., `[[123],[456]]` instead of `[[1,2,3],[4,5,6]]`). This optimization substantially reduced token count while preserving essential spatial relationship processing capabilities.
]

== System Prompt Implementation

Our investigation into prompt structure optimization extends to the fundamental mechanisms through which language models process sequential input during training procedures. While the structural elements of prompts establish semantic frameworks, their implementation within neural language model architectures requires token-level control mechanisms that directly interface with the model's generative processes.
Language models operate fundamentally as conditional probability distribution functions that predict subsequent tokens based on the preceding context. When transitioning from API-mediated interactions to direct model training, we must engage with the underlying token-level architecture through control sequences:

```
<|im_start|>system\nYou will be provided with example inputs and outputs. Analyze the train examples. Your Goal is to find common Transformation pattern among those and apply the found patterns to the test input to create the Test Output.<|im_end|>\n<|im_start|>user\n {train} \n\n\n {test}\n\n Figure out how to create the Test Output. Use <think> </think> tags to reason about the problem. Return the final answer in <answer> </answer> tags as a nested list.<|im_end|>\n<|im_start|>assistant\nLet me solve this step by step.\n<think>
```


These control tokens (<|im_start|> and <|im_end|>) serve as attentional anchors within the model's representational space, establishing contextual boundaries that modulate next-token prediction dynamics. Unlike conventional interface abstractions, these tokens directly influence the attention mechanisms and hidden state transformations that govern the model's generative behavior. Each role designation (system, user, assistant) activates distinct parameter configurations encoded during the model's pre-training phase, effectively constraining the probability distribution toward role-appropriate output patterns.





The full JSONL dataset of train, test, and train_answer pairs employing this prompt structure can be found on Hugging Face @lukhausen2025arcagi.

]
