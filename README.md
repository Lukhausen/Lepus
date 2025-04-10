# Exploring the Impact of Synthetic Chain-of-Thought Fine-Tuning on LLM Reasoning Abilities

This repository contains the research and code for the project titled **"Exploring the Impact of Synthetic Chain-of-Thought Fine-Tuning on LLM Reasoning Abilities"**, conducted as part of our T3000 project at the Cooperative State University Baden-Württemberg (DHBW) by Marc Schmengler and Lukas Marschhausen.

## Key Objectives

- Create a synthetic dataset of reasoning tasks that are solved step by step, enabling backtracking after failure.
- Fine-tune a Large Language Model (preferably LLaMA 70B to be open source) using the synthetic dataset.
- Evaluate the fine-tuned model on reasoning benchmarks and compare the results to the un-fine-tuned model.

## Workflow

1. [Research Benchmarking Methods](#research-benchmarking-methods)
2. [Create Synthetic Data](#create-synthetic-data)
3. [Fine-Tune the Model](#fine-tune-the-model)
4. [Evaluate](#evaluate)

### Research Benchmarking Methods

- Ensure that the synthetic data does not contain direct benchmarking examples to avoid skewing the results.
- Select appropriate reasoning benchmarks that test multi-step problem-solving abilities.

### Create Synthetic Data

- **Step-by-Step Reasoning Generation:**
  - Start with an initial problem statement.
  - Generate the first reasoning step using an intelligent LLM like GPT-4 or Claude.
  - Proceed to create two or more subsequent reasoning steps, each as a separate LLM call.
- **Multiple Outcome Exploration:**
  - For each step, create multiple possible outcomes.
  - Utilize a validator to rank these outcomes and determine the best next step.
- **Iterative Solution Development:**
  - Continue this process until a solution is found.
  - Include failures and incorrect paths that are backtracked and corrected to mimic realistic reasoning processes.
- **Prompt Crafting:**
  - Concatenate all reasoning steps to form a single, coherent prompt.
  - Ensure the prompts reflect a variety of reasoning paths, including missteps and their corrections.

### Fine-Tune the Model

- **Initial Fine-Tuning:**
  - Fine-tune a smaller model using the synthetic dataset to assess the approach's effectiveness.
  - Evaluate whether the desired reasoning improvements are achieved.
- **Scaling Up:**
  - If results are promising, proceed to a full fine-tuning run on LLaMA 70B.

### Evaluate

- **Performance Assessment:**
  - Evaluate the fine-tuned model on selected reasoning benchmarks.
  - Compare its performance against the un-fine-tuned baseline model.

### Similar Projects:
- [open-strawberry](https://github.com/pseudotensor/open-strawberry)
- [g1](https://github.com/bklieger-groq/g1)
- [Raspberry](https://github.com/daveshap/Raspberry)

dwa

::: warning
*here be dragons*
:::