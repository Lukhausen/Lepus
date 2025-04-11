#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let data_augumentation = [

= Data Augumentation
Before we can actually train the LLM to hopefully develop reasoning skills about how the ARC tasks work, we first have to augment the data. The current data we have access to is provided directly by the ARC AGI benchmark, yet it consists of just 1000 tasks. If we were to use those tasks as a training set, the model would probably quite quickly memorize them and not abstract any patterns it sees there. It would be enough for the model to simply learn to fetch the needed output for a task from its weights when seeing the first 50 numbers of the array. This is not what we want the model to achieve.

First, let's inspect the actual statistical data of the training set of 100 tasks. Let's first look at how many train and how many test examples they have.

#figure(
 image("../assets/screenshots/task_count_distribution.png", width: 100%),
 caption: [Distribution of ARC tasks based on the number of train and test examples per task. The Y-axis uses a logarithmic scale. @lukhausen2025dataaugmentation],
)

We can see there are some outliers to the normal distribution. Let's look at them in more detail.

#figure(
 grid(
     columns: 1,
     gutter: 2mm,
     image("../assets/screenshots/8dab14c2.png", width: 100%),
     image("../assets/screenshots/794b24be.png", width: 100%),
 ),
 caption: "Task 8dab14c2 with 4 test inputs and 794b24be with 10 train inputs"
)

As already shown by previous teams, we can augment the data by rotating it or flipping it. @franzen2024architect If we flip both all train and test tasks, we preserve the actual structure of the task. Interestingly, we can only perform 8 operations in total to a task:
- Identity  
- Rotate 90  
- Rotate 180  
- Rotate 270  
- Mirroring Horizontal  
- Mirroring Horizontal + Rotate 90  
- Mirroring Horizontal + Rotate 180  
- Mirroring Horizontal + Rotate 270  

As mirroring vertical is the same as mirroring horizontal and rotating 180, we do not have to consider it as a separate operation. If we would, we would create duplicates.

After rotating all tasks 90, 180, 270 degrees, we now have extended the task count from 1000 to 4000.  
After mirroring all tasks horizontally, we now have 8000 tasks.

As the goal is to create tasks that still have the same logic as the originals, we apply further transformations to create an even larger dataset.

One transformation that will result in "confusion" to the LLM, but not in changing the actual task's representation, is to add padding to tasks in random colours.  
So we will use chance to add padding uniformly to all input or output tasks for a problem. With a 50% probability, a task gets a padding around all its inputs and with a 50% probability the task gets a padding around all its outputs. This adds another layer of complexity. This will add ~6k tasks, as with a total probability of 75% we will add padding to any given task.

#figure(
 image("../assets/screenshots/train_example_variants.png", width: 100%),
 caption: [Visualization of augmentations applied to the first training example (input/output pair) from ARC task 8dab14c2. Each column represents a different transformation (Original, Horizontal Mirror (mh), Padding (pXcZ), Rotation (rX), or a combination), applied to both the input grid (top row) and the output grid (bottom row). @lukhausen2025dataaugmentation],
)

Now we have a total of ~14k tasks. Recent developments in LLM suggest that we do not need an enormous amount of tasks to adapt the LLM to new behaviours. @wu2024far100samplesgo OpenAI e.g. only requires a minimum of 10 tasks to finetune their models. @openai2025fine_tuning Obviously we are not finetuning the model with the same efficiency and pipeline as OpenAI, but we will refrain from bloating the amount of training samples to an exorbitant amount. We will still perform a few more augmentations to the dataset.

To actually prepare the data for training, we need to split the test pairs, so that we do not have multiple test pairs in a single task, as the LLM will only be able to solve a single task at a time and multiple tasks will confuse it. If a task has 3 test pairs, then splitting it will create 3 separate tasks, which all have the same train pairs, yet only have a single test pair each.

First of all, we are going to duplicate each task, to increase the volume of tasks even more, as more task volume is not bad for training as long as there are no statistical biases. And then shuffle the colours of all tasks randomly, to create more diversity. To achieve that, we create a colour-to-colour mapping for each task and apply it uniformly across the task.

We deliberately ignore the background colour and include it in our colour mapping, even though previous approaches have not done this. The reason why we are doing this is in the hopes that the resulting model will rather learn the concept of a background colour than associating 0 with the background colour all the time.

#figure(
 image("../assets/screenshots/train_example_variants_colour_shuffled.png", width: 100%),
 caption: [Visualization of augmentations and colour shuffle applied to the first training example (input/output pair) from ARC task 8dab14c2. @lukhausen2025dataaugmentation],
)

The last shuffling we are going to do is shuffling the train data. As we now have each task extended to ~14 unique tasks through the transformations and extended it further to ~28 tasks through duplications and colour shuffling, we now have pairs of 2 tasks that are completely similar except for the colour. To discourage any memorization, we will now shuffle the train data randomly, as this does not change the actual task in any way, as the model always gets to see all train data of a task in the inference.

#figure(
 grid(
     columns: 2,
     gutter: 2mm,
     image("../assets/screenshots/8dab14c2_processed_original.png", width: 100%),
     image("../assets/screenshots/8dab14c2_processed_copy.png", width: 100%),
 ),
 caption: "Task 8dab14c2: Two Copies of the same task with shuffled colours"
)

#figure(
 grid(
     columns: 2,
     gutter: 2mm,
     image("../assets/screenshots/8dab14c2_processed_original_shuffled.png", width: 100%),
     image("../assets/screenshots/8dab14c2_processed_copy_shuffled.png", width: 100%),
 ),
 caption: "Task 8dab14c2: Two Copies of the same task with shuffled train order and colours"
)

After shuffling the train examples in the tasks, we now have ~28k tasks, which we can parse into a JSONL file and start the training with.  
In summary, we have used transformations like rotations, reflections, paddings, colour shuffles, and train example shuffles to augment the data from 1000 to ~28k tasks.
]