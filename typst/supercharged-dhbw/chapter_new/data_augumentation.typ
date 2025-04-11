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
]