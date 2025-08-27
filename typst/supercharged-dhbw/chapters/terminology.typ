#let terminology = [
= Basic Terminology

== Chain of Thought

The chain-of-thought principle describes a strategy in which AI models articulate their thought processes through several comprehensible intermediate steps, instead of presenting the final result directly @IBM2024Chain. This is frequently employed in larger language models to handle complex tasks such as mathematical problems, logical reasoning, or comprehending lengthy texts @LarsenWessels2022. A simple example is a math problem, where the model does not only state the sum of two numbers but also explains step by step how it arrived at the solution: first, the numbers are broken down into their place values and added individually until the correct result is obtained. Due to this step-by-step structuring and presentation of the solution, errors are easier to recognize and can be corrected if necessary.

When people first adopted chain-of-thought in 2022, it was nothing more than a clever prompting cue: adding phrases such as "Let's think step by step." dramatically improved accuracy in arithmetic, logical riddles, and legal analyses. @wei2023chainofthoughtpromptingelicitsreasoning
Yet, this test-time method of utilizing chain-of-thought was inconsistent and always required a prompt to function correctly. Moreover, the principle of self-correction was mostly absent from those prompted chains of thought. Once the model had made a misstep, it did not correct itself to revert to the truth but rather continued along the incorrect path.

By 2023, the community began fine-tuning smaller models on step-by-step datasets such as ThoughtSource @OpenBioLink2023ThoughtSource and MathInstruct @Yue2023MathInstruct, which collected hundreds of thousands of human- or LLM-written chains of thought, allowing models to no longer require a special prompt.

OpenAI joined this effort and published a fully human-generated reasoning chain-of-thought dataset consisting of 800k reasoning steps on the MATH benchmark @Hendrycks2021Math @prm800k.

With the release of OpenAI's O1, the first large model with inherent test-time chain-of-thought reasoning capabilities was introduced, demonstrating that applying the chain-of-thought principle not only during prompting but also during training can significantly improve logical reasoning accuracy.

In 2025, this means that nearly all state-of-the-art language models now utilize chain-of-thought during test time. The simple instruction "think step by step" has become obsolete yet remains integral, as it is effectively embedded within the model itself rather than functioning merely as a prompt.


== Scaling Laws

The term "scaling laws" refers to guidelines or observations that 
describe how the performance of AI models develops depending on their size, the amount of data available 
and the computing power used. The larger a 
neural network and the more extensive the training data, the more 
the accuracy can generally increase - however, diminishing marginal returns often occur from a certain 
point onwards. This means that while the accuracy is improved rapidly at the beginning by 
additional growth of the model or more data samples, 
the gain often only increases slowly later on with equally increasing effort. By 
analysing such scaling effects, predictions can be made as to how many 
resources are required to achieve a certain level of performance, which is of considerable importance for the 
planning of large-scale training projects. At the same time, 
scaling laws help to assess where optimisations in the 
model design or in the data are most effective.

== Training process and inference (Train-Time vs. Test-Time)

Two central phases can be distinguished in the context of modern AI applications: One 
is the training process and the other is inference. During training, often referred to 
as 'train time', a model is adapted using large amounts of data and special 
optimisation methods. This requires extensive computing resources, as each input 
example is first run through the algorithm in a forward pass before the so-called 
backpropagation step takes place. This process is used to change the parameters so that 
the model can make increasingly reliable predictions. Depending on the complexity and 
size of the network, training can take a long time and is usually associated with high 
costs for hardware and energy @Isenberg2025.

As soon as the model is sufficiently well trained, it is transferred to the field. This 
practical application is known as inference or 'test time'. The sole aim here is to 
retrieve the learnt parameters and apply them to new inputs. In contrast to training, 
the model is no longer changed during inference, but uses the previously learnt 
relationships to make predictions or decisions @Sun2024. Although inference is generally much 
faster and less computationally intensive than training, it can still require resources 
depending on the size of the model, the environment in which it is used and the number 
of queries. In productive scenarios, efficient inference is therefore just as important 
as a well-organised training process, as the AI system used often has to deal with 
large volumes of queries in a short space of time @Nanonets2023.

== Hyperparameter Tuning
Hyperparameter tuning refers to the systematic adjustment of certain settings in the 
deep learning model in order to achieve the best possible results @AWS2024. The learning rate 
plays a central role here: it regulates how quickly the weights change during training. 
If it is too high, the model can become unstable or not converge at all; if it is too 
low, it takes a very long time to reach an optimum point @EntryPointAI2024.\
Deep learning is a sub-area of machine learning that focuses on the use of artificial 
neural networks with many layers (hence the term 'deep'). These networks are able to 
automatically learn complex features and patterns in large amounts of data without 
having to manually define these features in advance @IBM2024Deep. The hierarchical structure enables 
deep learning models to recognise simple patterns (such as edges in images or simple 
speech sounds) at a low level and combine this information into increasingly abstract 
concepts in higher layers. This makes deep learning particularly powerful in areas such 
as image and speech recognition, natural language processing and many other 
applications where traditional algorithms often reach their limits.

The batch size must also be chosen carefully: Although large batches speed up 
calculations on modern hardware, they can cause the model to get 'caught' in shallow 
valleys of the error space and not converge optimally. Small batches, on the other 
hand, increase the variance in the gradient calculation, but often ensure a more 
robust, albeit slower, fit.\
In machine learning, batches refer to subsets of the training dataset that are 
processed together in one forward and backward pass during the training process. Rather 
than using the entire dataset to compute the gradient (as in full-batch gradient 
descent), the data is divided into smaller groups called batches. This method, known as 
mini-batch gradient descent, allows the model to update its parameters more frequently, 
making training more efficient and manageable, especially with large datasets. 
Moreover, processing batches takes advantage of modern hardware accelerators like GPUs, 
which are optimized for handling multiple data points in parallel.

In addition, the number of layers influences how deeply the model processes its inputs, 
with more layers often meaning a higher computational load, but also a greater capacity 
for abstraction. Finally, dropout plays an important role in regularisation: it 
determines how many neurons are temporarily 'switched off' during training, which 
should reduce overfitting and improve generalisation. All of these components together 
significantly determine how well and how quickly a neural network learns.
] 