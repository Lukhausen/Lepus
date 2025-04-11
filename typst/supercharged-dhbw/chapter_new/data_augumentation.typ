= Data Augumentation
Before we can actually train the LLM to hopefully develop reasoning skills about how the ARC tasks work, we first have to augment the data. The current data we have access to is provided directly by the ARC AGI benchmark, yet it consists of just 1000 tasks. If we were to use those tasks as a training set, the model would probably quite quickly memorize them and not abstract any patterns it sees there. It would be enough for the model to simply learn to fetch the needed output for a task from its weights when seeing the first 50 numbers of the array. This is not what we want the model to achieve.

First, lets inspect the actuall stastical data of the traing set of 100 taasks. Lets first look at how many train and how many test exmaples they have.

#figure(
 image("../assets/screenshots/tokenizer-comparison.png", width: 100%),
 caption: [Tokenization Comparison between GPT-4o and GPT-3],
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
After mirroring all tasks horzontally, we now have 8000 tasks.

As the goal is to create tasks that still have the same logic as the originals, we apply further transformations to create an even larger dataset.

One transformation that will result in "confusion" to the LLM, but not in changing the actual task's representation, is to add padding to tasks in random colours.  
So we will use chance to add padding uniformly to all input or output tasks for a problem. With a 50% probability, a task gets a padding around all its inputs and with a 50% probability the task gets a padding around all its outputs. This adds another layer of complexity. This will add ~6k tasks, as with a total probability of 75% we will add padding to any given task.

As a task can have multiple test inputs and output, as seen in out stastisical anaylsis of the dataset

Now with ~14k tasks, we can start to shuffel the colours around. Currently all tasks of the same type have the same colours. so we will go ahead and shuffle the colours randomly in a task. TO archive that we create a colour to colour mapping for each task, and apply it uniformyl across the task. 