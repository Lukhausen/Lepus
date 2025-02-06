#import "@preview/supercharged-dhbw:3.4.0": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#show: supercharged-dhbw.with(
  title: "Exploring the Impact of Synthetic Chain-of-Thought Fine-Tuning on LLM Reasoning Abilities",
  authors: (
    (name: "Lukas Marschhausen", student-id: "1840227", course: "TINF22AI1", course-of-studies: "Applied Computer Science", company: (
      (name: "Cisco Systems GmbH", post-code: "65760", city: "Eschborn")
    )),
    (name: "Marc Schmengler", student-id: "1234567", course: "TINF22AI1", course-of-studies: "Applied Computer Science", company: (
      (name: "XYZ GmbH", post-code: "12345", city: "Berlin")
    )),

  ),
  acronyms: acronyms, // displays the acronyms defined in the acronyms dictionary
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary, // displays the glossary terms defined in the glossary dictionary
  language: "en", // en, de
  supervisor: (company: "-"),
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Mannheim",
  university-short: "DHBW",
  // for more options check the package documentation (https://typst.app/universe/package/supercharged-dhbw)
)

= Chain of Thought

The chain-of-thought principle describes a strategy in which AI models formulate their thought processes in several comprehensible intermediate steps instead of just presenting the final result directly. This is often done in larger language models in order to deal with complex issues such as mathematical tasks, logical conclusions or the comprehension of long texts. A simple example would be a maths problem in which the model not only states the sum of two numbers, but also explains step by step how this is arrived at: first the numbers are broken down into their place values and added individually until the correct result is finally obtained. Thanks to this step-by-step structuring and presentation of the solution, errors are easier to recognise and can be corrected if necessary. In practice, the method is mainly used where a clear derivation is crucial, for example in tricky puzzles, in the field of automated text analysis or when analysing legal documents. This explicit disclosure of the thought process not only increases accuracy, but also promotes trust in the answers of AI systems, as users can better understand the explanations.

= Scaling Laws

Unter dem Begriff „Scaling Laws“ versteht man Richtlinien oder Beobachtungen, die beschreiben, wie sich die Leistung von KI-Modellen in Abhängigkeit von ihrer Größe, der verfügbaren Datenmenge und der aufgewendeten Rechenleistung entwickelt. Je größer ein neuronales Netzwerk und je umfangreicher die Trainingsdaten ausfallen, desto stärker kann im Regelfall die Genauigkeit steigen – allerdings treten oft ab einem gewissen Punkt abnehmende Grenzerträge auf. Das heißt, während die Genauigkeit zu Beginn durch zusätzliches Wachstum des Modells oder mehr Datensamples rasch verbessert wird, nimmt der Zugewinn bei gleichermaßen wachsendem Aufwand später oft nur noch langsam zu. Durch die Analyse solcher Skalierungseffekte lassen sich Vorhersagen treffen, wie viele Ressourcen nötig sind, um ein bestimmtes Leistungsniveau zu erreichen, was für die Planung groß angelegter Trainingsprojekte von erheblicher Bedeutung ist. Gleichzeitig helfen Scaling Laws dabei einzuschätzen, an welcher Stelle Optimierungen im Modelldesign oder bei den Daten am effektivsten sind.

= Trainingsprozess und Inferenz (Train-Time vs. Test-Time)

Two central phases can be distinguished in the context of modern AI applications: One is the training process and the other is inference. During training, often referred to as ‘train time’, a model is adapted using large amounts of data and special optimisation methods. This requires extensive computing resources, as each input example is first run through the algorithm in a forward pass before the so-called backpropagation step takes place. This process is used to change the parameters so that the model can make increasingly reliable predictions. Depending on the complexity and size of the network, training can take a long time and is usually associated with high costs for hardware and energy.

As soon as the model is sufficiently well trained, it is transferred to the field. This practical application is known as inference or ‘test time’. The sole aim here is to retrieve the learnt parameters and apply them to new inputs. In contrast to training, the model is no longer changed during inference, but uses the previously learnt relationships to make predictions or decisions. Although inference is generally much faster and less computationally intensive than training, it can still require resources depending on the size of the model, the environment in which it is used and the number of queries. In productive scenarios, efficient inference is therefore just as important as a well-organised training process, as the AI system used often has to deal with large volumes of queries in a short space of time.

= Hyperparameter Tuning
Hyperparameter tuning refers to the systematic adjustment of certain settings in the deep learning model in order to achieve the best possible results. The learning rate plays a central role here: it regulates how quickly the weights change during training. If it is too high, the model can become unstable or not converge at all; if it is too low, it takes a very long time to reach an optimum point.\
Deep learning is a sub-area of machine learning that focuses on the use of artificial neural networks with many layers (hence the term ‘deep’). These networks are able to automatically learn complex features and patterns in large amounts of data without having to manually define these features in advance. The hierarchical structure enables deep learning models to recognise simple patterns (such as edges in images or simple speech sounds) at a low level and combine this information into increasingly abstract concepts in higher layers. This makes deep learning particularly powerful in areas such as image and speech recognition, natural language processing and many other applications where traditional algorithms often reach their limits.

The batch size must also be chosen carefully: Although large batches speed up calculations on modern hardware, they can cause the model to get ‘caught’ in shallow valleys of the error space and not converge optimally. Small batches, on the other hand, increase the variance in the gradient calculation, but often ensure a more robust, albeit slower, fit.\
In machine learning, batches refer to subsets of the training dataset that are processed together in one forward and backward pass during the training process. Rather than using the entire dataset to compute the gradient (as in full-batch gradient descent), the data is divided into smaller groups called batches. This method, known as mini-batch gradient descent, allows the model to update its parameters more frequently, making training more efficient and manageable, especially with large datasets. Moreover, processing batches takes advantage of modern hardware accelerators like GPUs, which are optimized for handling multiple data points in parallel.

In addition, the number of layers influences how deeply the model processes its inputs, with more layers often meaning a higher computational load, but also a greater capacity for abstraction. Finally, dropout plays an important role in regularisation: it determines how many neurons are temporarily ‘switched off’ during training, which should reduce overfitting and improve generalisation. All of these components together significantly determine how well and how quickly a neural network learns.

= Quellen

https://www.forwardfuture.ai/p/the-magic-of-prolonged-thinking-test-time-compute-part-2

https://medium.com/thedeephub/test-time-training-ttt-a-new-approach-to-sequence-modeling-8baf1ea79ed7

https://nanonets.com/blog/what-is-test-time-training/

https://www.ibm.com/de-de/topics/chain-of-thoughts

https://the-decoder.de/deeper-insights-fuer-ki-sprachmodelle-mit-chain-of-thought-prompting-als-erfolgsfaktor/

https://aws.amazon.com/de/what-is/hyperparameter-tuning/

https://www.entrypointai.com/blog/fine-tuning-hyperparameters/

https://www.ibm.com/de-de/topics/deep-learning

https://epoch.ai/blog/scaling-laws-literature-review

https://medium.com/sage-ai/demystify-transformers-a-comprehensive-guide-to-scaling-laws-attention-mechanism-fine-tuning-fffb62fc2552