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

= Creating teh Prompt.

Prompt Engineering for Few Shot prompting, as this is exactly what we are going to implement here, is kind of hard to grasp. There are many factors that can influence the model performance. How do you signify what is an example and what is the input/output for that example that is expected? Does the training examples order affect the output performance of the model or not?  
It was actually found that the ordering of the training examples in the prompt can affect the output drastically. A study showed that merely reordering the training examples can create performance variance from 54% up to 93% on a sentiment analysis benchmark. @zhao2021calibrateuseimprovingfewshot Furthermore, LLMs seem to have a recency bias, where they weigh recently seen examples more heavily into their prediction than training examples further ago. Only providing a single example for few shot prompting is likely to worsen the performance as the model takes this example too strongly into consideration for the output it produces. @cleary2025fewshot  
Normally, few shot prompting improves output quality of every model, yet a study by OpenAI and Microsoft found that this does not seem to be the case for test-time compute models. @nori2024medprompto1explorationruntime The performance actually declined when applying few shot prompting to the o1 model. This was also observed by the DeepSeek team on their test-time compute model DeepSeek-R1 @deepseekai2025deepseekr1incentivizingreasoningcapability  

Furthermore, when giving examples, it is important to actually separate them visually. As we need to craft a prompt given to the model while training, we will apply the following tactics:  
- Separate each example clearly using indicators at the beginning like "\#Example 1" and using delimiters at the end "\n\n"  
- Remove the JSON structure from the task to produce a more accurate "human-readable" input.  

First, let us understand how the tokenization of the model we are going to use for our training actually works (Qwen2.5-3B). For our case, we will inspect how JSON strings are tokenized to pick the best fitting tokenization for our use case.


#figure(  
  grid(  
    rows: 2,  

    gutter: 2mm,  
    image("../assets/screenshots/example_tokenization_1.png", width: 60%),  
    image("../assets/screenshots/example_tokenization_2.png", width: 100%),  
  ),  
  caption: [Token Visualisation of Different Strings @lukhausen2025tokenvisualisation]  
)

We can see that numerals are encoded into separate tokens, unlike with the encoding of the GPT-3 models. So the tokenization used by the Qwen2.5-3B model already accounts for the finding of improved mathematical capabilities through correct number tokenization. @sun2023tokenizationconsistencymattersgenerative @bostrom2020bytepairencodingsuboptimal @singh2024tokenizationcountsimpacttokenization  
For our case, it is also really important that each numeral is encoded as a single token. Let's check if that holds true when not separating numerals by whitespaces, commas, or other delimiters.  

#figure(  
  image("../assets/screenshots/example_tokenization_3.png", width: 100%),  
  caption: [Token Visualisation of Different Strings @lukhausen2025tokenvisualisation]  
)  

The numerals are still tokenized with separate encodings for each numeral. For our case, this means separating the numerals by any delimiter likely is not adding toward the model performance. Actually, using whitespaces in our arrays as input will double the token amount without any advantage to the LLM. This is why we will parse the arrays of the ARC Tasks as numerals withotu seperation, indicating a new line by $"\\n"$ as a delimiter.

#figure(
  grid(
    columns: (auto, auto, auto),
    gutter: 15mm,  // Increased spacing between columns
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

#figure(
  grid(
    columns: 3,
    gutter: 2mm,
    column-gutter: (13mm, 0mm),  // Control spacing between columns more precisely
    row-gutter: 0mm,              // No vertical spacing needed
    
    // Left image - scaled appropriately
    align(center + horizon, 
      image("../assets/screenshots/example_tokenization_4.png", width: 90%)
    ),
    
    // Center arrow - positioned centrally
    align(center + horizon, 
      text(size: 20pt, weight: "bold", $arrow.r$)
    ),
    
    // Right image - adjusted width to match visual weight of left image
    align(center + horizon, 
      image("../assets/screenshots/example_tokenization_5.png", width: 50%)
    ),
  ),
  caption: [Tokenization visualization comparing nested array representation (left) with compressed string format (right). Individual tokens are color-coded, demonstrating how the string format reduces token count while preserving grid structure for ARC tasks. @lukhausen2025tokenvisualisation]
)

Using this structre we can reduce the Token count and still remain the core structure and currect and sperate tokenisation for all numerls. In this exmaple we reduced the input toklens from 29 to 11 tokens.  

Yet we ahve to think abut another point. While this reduces the Tokenisation count, It has to learn the structre of the task, as the structre of numerals without delimiters was not commonly see by the model during tis traing. To find out what the model considers the ebst sttructure, elts ask it how it would dispaly a grid / matrix.

#llm-input(
  "Please create a matrix structure consisting of 3x3 numbers."
)

in 70% (21/30 times) the model produced output looking like this: 

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

Reprasing teh qeustion to "Please create a grid structure consisting of 6x6 numbers." resulted in 72% of the output looking liek this: 


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

an importaint note her is tha not a single time of all 60 generations did it output the token optimized variant using no delimitors. This is caused because the model has learned to interpret numerals directly folloing one another as numbers and not as single tokens. Int heroy the mdoel would be able to realewrn this grid structure without any delimitors, yet it would take time and shift its focus from the actual task. fOR OUr CASE WE WILL THERFROE REFRAIN FROM USING THE TOKEN OPTMIZED STATEGY AND GO WITH fromatting the input as a grid to save on the comma tokens we would use in the matric structre and let the model output a matrix structre.



Also the longest output task in out traing set is 05a7bcf2 with 3675 tokns when using json fromat. 

Now concerning the prompt Strucre we have to Create Ancor Points for Each Exmaple and for the INpout and Output. 



]

