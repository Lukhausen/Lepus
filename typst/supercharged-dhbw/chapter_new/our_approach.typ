#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let our_approach = [
= Our Approach

Current open-source approaches predominantly rely on direct inferencing without implementing chain-of-thought or intermediate reasoning steps. Notably, solutions such as ARChitect and Icecuber, as well as other open-source methodologies represented on the leaderboard, lack mechanisms that explicitly extract reasoning processes and logical thinking required to solve ARC tasks. However, as evidenced by the ARC benchmark results (see @arcprize_leaderboard), reasoning-oriented models like OpenAI's o1 and o3 achieve superior performance without additional optimization compared to non-reasoning models.

This performance differential stems from their implementation of test-time compute capabilities. These models are structured to incorporate an intermediate step between input processing and output generation, utilizing chain-of-thought mechanisms to reason through potential solutions before producing answers.

DeepSeek pioneered the commoditization of this approach by releasing their model with open weights and publishing their methodological framework. Subsequently, Jian Pan successfully replicated DeepSeek's methodology in his project TinyZero @pan2025tinyzero, which provides the foundation for our research. We aim to adapt this framework to develop a reasoning-oriented model specifically tailored for ARC tasks.

Our primary research objective is to investigate whether emergent reasoning behaviors can be cultivated when training on complex spatial datasets. Unlike previous approaches that focus primarily on pattern matching or transformation libraries, our methodology emphasizes the development of intermediate reasoning processes that more closely approximate human problem-solving strategies when addressing abstract reasoning challenges.

]
