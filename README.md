# Evaluating Synthetic Chain-of-Thought via RL Fine-Tuning for ARC-AGI Problem Solving

## Overview
This project investigates the application of reinforcement learning (RL) fine-tuning techniques to develop synthetic chain-of-thought (CoT) reasoning capabilities in Large Language Models (LLMs). The primary focus is on enhancing performance on the Abstraction and Reasoning Corpus (ARC-AGI) benchmark, a challenging testbed for abstract spatial reasoning. The research explores emergent reasoning behaviors in LLMs when subjected to targeted training methodologies.

This project represents a collaborative effort documented in the accompanying research paper.

## Key Areas of Research & Development
*   **ARC-AGI Benchmark Focus:** Applying and evaluating LLMs (primarily Qwen 3B and 7B parameter models) on tasks from the ARC-AGI dataset.
*   **Reinforcement Learning Fine-Tuning:** Utilizing an RL framework (adapted from the TinyZero project) to fine-tune LLMs and incentivize reasoning.
*   **Synthetic Chain-of-Thought:** Developing and evaluating methods to encourage models to generate and utilize intermediate reasoning steps.
*   **Data Augmentation:** Systematically expanding the original ARC dataset (from ~1,000 to ~28,000 tasks) through geometric transformations, color permutations, and structural modifications to improve model generalization.
*   **Prompt Engineering & Optimization:** Designing and refining prompt structures to optimize token efficiency and model comprehension for ARC tasks.
*   **Reward Function Design:** Implementing a novel bifurcated reward system that separately evaluates structural (syntax) and semantic (content) correctness of model outputs, inspired by MORLAIF principles.
*   **Experimental Analysis & Benchmarking:** Conducting extensive training runs, hyperparameter tuning, and benchmarking of base and fine-tuned models to assess the impact of the developed techniques.

## Directory Structure

*   `typst/`: Contains the source files for the research paper, written in Typst.
    *   `supercharged-dhbw/main.typ`: The main Typst file for compiling the paper.
    *   `supercharged-dhbw/bibliography/`: Bibliography files (`.bib`).
    *   `supercharged-dhbw/chapter_new/`: Individual chapters of the research paper.
    *   `supercharged-dhbw/assets/`: Images and other assets for the paper.
*   `experimental/`: Houses all scripts, notebooks, and data related to the practical implementation and experimentation.
    *   `lukas/`: Contains Jupyter notebooks and Python scripts for:
        *   `preprocessing/`: Data loading, augmentation, validation, and prompt formatting for the ARC dataset. Includes augmented task files.
        *   `benchmarking/`: Initial benchmarking scripts for off-the-shelf LLMs on ARC tasks.
        *   `post_train_benchmarking/`: Scripts for evaluating the fine-tuned models.
    *   `marc/TinyZero/`: Contains the core reinforcement learning training framework (adapted from the TinyZero project by Jiayi Pan et al.) used for fine-tuning the models. Includes configurations, worker scripts, and model-specific code.
*   **Root Directory:**
    *   `start*.sh`: Shell scripts for initiating various training configurations (e.g., `start.sh`, `start7b.sh`).
    *   `commands_to_paste*.md`: Helper files with command snippets for training.

## Core Technologies & Frameworks
*   Python
*   PyTorch
*   Hugging Face Transformers (for models and tokenizers) & Datasets
*   TinyZero (Reinforcement Learning framework)
*   Weights & Biases (for experiment tracking)
*   Typst (for research paper preparation)

## Getting Started
1.  **Read the Research Paper:** The most comprehensive understanding of the project's motivations, methodology, experiments, and findings can be found in the paper. Compile it using Typst from the `typst/supercharged-dhbw/` directory or look for a pre-compiled PDF (e.g., `Paper.pdf` if available in the root).
2.  **Explore Experimental Code:**
    *   **Data Handling:** See `experimental/lukas/preprocessing/` for how the ARC data was augmented and prepared. The augmented dataset (`formatted_arc_tasks_custom.jsonl` and `formatted_arc_tasks_easy.jsonl`) is a key output.
    *   **Training Framework:** The `experimental/marc/TinyZero/` directory contains the RL training setup. Configuration files (YAML) within this directory and the `scripts/train_tiny_zero*.sh` files define training parameters.
    *   **Training Execution:** The `start*.sh` scripts in the root directory provide entry points for initiating training runs.
    *   **Evaluation:** Scripts in `experimental/lukas/post_train_benchmarking/` are used to benchmark the trained models.

This project aims to contribute to the understanding of how reasoning capabilities can be cultivated in LLMs for complex, abstract problem-solving domains.
