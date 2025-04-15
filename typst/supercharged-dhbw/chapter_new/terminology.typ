#let terminology = [
= Basic Terminology

== Chain of Thought

The chain-of-thought principle describes a strategy in which AI models formulate their 
thought processes in several comprehensible intermediate steps instead of just 
presenting the final result directly @IBM2024Chain. This is often done in larger language models in 
order to deal with complex issues such as mathematical tasks, logical conclusions or 
the comprehension of long texts @LarsenWessels2022. A simple example would be a maths problem in which the 
model not only states the sum of two numbers, but also explains step by step how this 
is arrived at: first the numbers are broken down into their place values and added 
individually until the correct result is finally obtained. Thanks to this step-by-step 
structuring and presentation of the solution, errors are easier to recognise and can be 
corrected if necessary. In practice, the method is mainly used where a clear derivation 
is crucial, for example in tricky puzzles, in the field of automated text analysis or 
when analysing legal documents. This explicit disclosure of the thought process not 
only increases accuracy, but also promotes trust in the answers of AI systems, as users 
can better understand the explanations.

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