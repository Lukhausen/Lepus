#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let introduction = [

= Introduction

Large language models have historically improved through scaling laws, where increases in parameters and training data correlate with enhanced performance. Emergent abilities, such as solving unseen mathematical problems, validated this approach. However, performance gains began to plateau nonlinearly: doubling model size no longer doubled capability, while computational costs grew exponentially. This stagnation necessitated alternative strategies, leading to the exploration of test-time compute—enhancing reasoning during inference rather than solely relying on larger architectures.

Early LLMs (e.g., GPT-3) demonstrated that scaling parameters unlocked novel capabilities. However, diminishing returns emerged as models grew beyond hundreds of billions of parameters. Performance improvements became sublinear relative to resource investment.

In 2022, Researchers at Google introduced chain-of-thought (CoT) prompting, enabling models to decompose problems into intermediate steps during inference. This method significantly improved performance on arithmetic, commonsense, and symbolic reasoning tasks. @wei2023chainofthoughtpromptingelicitsreasoning Crucially, CoT shifted computational burden to inference time, decoupling performance gains from model size alone.

On May 31, 2023, OpenAI released PRM800K, a dataset of 800,000 human-curated Step by step Reasoning traces on how they solved math problems. @prm800k Their Idea behind those humand generated Chain of Thoughts was to use them to train a model to judge the acuracy of a step by step reasoning chain outputted by an LLM. 

The accompanying paper outlines how this dataset was used to train a Process reward model, a model to evaluate intermediate reasoning steps of a model. This approach was more effective at the time than using an Otcome Reward model, which was only judging the outcome of ta reasoning chain. @lightman2023letsverifystepstep

Yet for us while reading the paper the most interesting sentence of the whole apper was the folloingh sentence:

#quote(attribution: [@lightman2023letsverifystepstep], ["We do
not discuss any supervision the generator #footnote([The LLM that generated a reasoning chain, e.g. GPT-4]) would receive from the reward model
if trained with RL. Although finetuning the generator with RL is a natural next
step, it is intentionally not the focus of this work."])

This means, that using this reward model, it is possible to fine tune a LLM to leverage this chain of though thinking in its inference. A little mroe than a year later, on September 12, 2024, Openai releases o1. The first ever LLM that leverages chain of thought reasoning in its inference by default. It tops all mathematical Benchmarks and logic related benchmarks at the time of release. @openai2024o1systemcard

Yet, in some cases it is still not capable of ansering simple reasoning questions like the folloing:

#llm-interaction(
  model: "o1",
  [Beth places four whole ice cubes in a frying pan at the start of the first minute, then five at the start of the second minute and some more at the start of the third minute, but none in the fourth minute. If the average number of ice cubes per minute placed in the pan while it was frying a crispy egg was five, how many whole ice cubes can be found in the pan at the end of the third minute? @simplebench_try_yourself],
  [[...] Therefore, the number of whole ice cubes in the pan at the end of the third minute is 11 #footnote([The confusion of the model mostly stems from the fact that it "forgets" the fact that an egg si fried while the ice cubes are in the pan, as it focuses on the mathematical aprt of the riidle])]
)

As OpenAI is - against their forunding statement- no longer an opensource but a for profit comapny, we have no possibility of knowng how the o1 model was traind and only can make assumptions. Yet, a few month after the release of o1, in January of 2025, Deepseek - a cinese AI company - released DeepSeek-R1. A LLM matching the perfromance of openais o1 model. They make the weights of the model fully availabe for everyone to donwlaod and use and publish a paper on how they archived this perfromance with minimal traing cost @deepseekai2025deepseekr1incentivizingreasoningcapability

One of the most lacking parts of reasoning in all present models it spacial reasoning using world knowledge like gravity, suction, mirroring etc.

== Research question and motivation

== Significance of the work

== Brief overview of approach and contributions

]


