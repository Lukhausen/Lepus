#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let our_approach = [
= Methodology Overview

Current open-source approaches predominantly rely on direct inferencing without implementing chain-of-thought or intermediate reasoning steps. Notably, solutions such as ARChitect and Icecuber, as well as other open-source methodologies represented on the leaderboard, lack mechanisms that explicitly extract reasoning processes and logical thinking required to solve ARC tasks. However, as evidenced by the ARC benchmark results (see @arcprize_leaderboard), reasoning-oriented models like OpenAI's o1 and o3 achieve superior performance without additional optimization compared to non-reasoning models.

This performance differential stems from their implementation of test-time compute capabilities. These models are structured to incorporate an intermediate step between input processing and output generation, utilizing chain-of-thought mechanisms to reason through potential solutions before producing answers.

DeepSeek pioneered the commoditization of this approach by releasing their model with open weights and publishing their methodological framework. Subsequently, Jian Pan successfully replicated DeepSeek's methodology in his project TinyZero @pan2025tinyzero, which provides the foundation for our research. We aim to adapt this framework to develop a reasoning-oriented model specifically tailored for ARC tasks.

Our primary research objective is to investigate whether emergent reasoning behaviors can be cultivated when training on complex spatial datasets. Unlike previous approaches that focus primarily on pattern matching or transformation libraries, our methodology emphasizes the development of intermediate reasoning processes that more closely approximate human problem-solving strategies when addressing abstract reasoning challenges.

Our systematic approach follows a multi-stage implementation:

*Stage 1: Data Preparation and Augmentation*
We expand the original ARC dataset from 1,000 to approximately 28,000 tasks through geometric transformations (rotations, reflections), boundary modifications (padding), color permutations, and structural reorganizations to prevent memorization and encourage genuine pattern recognition.

*Stage 2: Bifurcated Reward Function Design*
Drawing from Multi-Objective Reinforcement Learning from AI Feedback (MORLAIF), we implement a dual evaluation system that separately assesses structural correctness (proper formatting and grid dimensions) and content accuracy (correctness of the actual solution), allowing for more precise training signals.

*Stage 3: Progressive Model Training*
Beginning with smaller models (3B parameters) to test emergent reasoning capabilities, then scaling to larger architectures (7B parameters) when threshold limitations are encountered, using reinforcement learning with incentives for extended reasoning chains structured around the `<think>...</think><answer>...</answer>` format.

*Stage 4: Adaptive Reasoning Development*
When natural emergence fails, we implement strategic interventions: first kickstarting reasoning development by explicitly rewarding longer reasoning chains to establish the thinking behavior, then gradually transitioning to content-focused optimization to ensure meaningful rather than merely verbose reasoning.

]
