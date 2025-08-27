#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let experimental = [
= Experimental Setup

For our project, we initially attempted to set up the development environment on our Windows 10 machines, following the steps outlined in Project TinyZero @pan2025tinyzero. We created a Conda environment using Python 3.9, installed CUDA 11.8, and configured the appropriate environment variables (including CUDA_HOME, CUDA_PATH, and adding CUDA's include and bin directories to the system PATH).

To install PyTorch with CUDA support, we specified the exact version using the command: pip install torch==2.0.0 --index-url https://download.pytorch.org/whl/cu118 and subsequently installed matching torchvision and other dependencies.

We also installed NVIDIA Nsight Visual Studio Edition and set up additional components (including Visual Studio Build Tools, C++ compilers, and various CUDA profiling tools). Despite carefully following these steps, we encountered persistent errors during the installation of the flash-attention package. The issues primarily stemmed from compatibility problems between NVIDIA's nvcc compiler and our installed Visual Studio version. We made several attempts to resolve these issues—including reinstalling CUDA, adjusting environment variables, trying different Visual Studio installations, and even using nvcc flags to allow unsupported compilers—but the build errors continued.

Due to these ongoing challenges with the Windows setup, we ultimately switched to an on-demand cloud instance running Linux, where the setup process proved significantly smoother.\
On the cloud instance we automated the deployment with a script to simplify future setups—this proved especially valuable since the entire environment is deleted when the instance is decommissioned.

After successfully running the project on Linux, we encountered challenges related to insufficient GPU memory (VRAM) and optimization issues during training. Memory errors initially emerged due to high RAM requirements from long model sequences and large batch sizes. These hyperparameter adjustments were necessary to optimize performance for efficient execution on H200 GPUs while preventing VRAM overflow and memory-related crashes that would terminate training runs. To address these issues, we conducted systematic hyperparameter tuning and hardware evaluations. Below is a detailed summary of our optimization strategy:
== Hyperparameter Tuning Overview
=== Sequence Length Adjustments

- *Parameter Changed:* data.max_prompt_length
- *From*: 22000
- *To*: 11300
- *Purpose*: Reducing the maximum token length for model responses significantly decreased the memory required for storing activations and gradients during both forward and backward passes, substantially lowering the total memory footprint.

=== GPU Memory Utilization Reduction

- *Parameter Changed:* actor_rollout_ref.rollout.gpu_memory_utilization
- *From*: 0.4
- *To*: 0.05
- *Purpose*: This parameter controls the fraction of GPU memory reserved for vLLM's key-value (KV) cache. A large reservation can starve other training operations. Reducing it freed up necessary VRAM for the model's activations and parameters.

=== Batch Size Minimization

- *Parameter Changed:* ppo_micro_batch_size (for both Actor and Critic models)
- From: 8
- To: 1
- Purpose: Decreasing the micro-batch size reduced the number of samples processed per forward/backward pass, thereby lowering peak memory consumption for gradients and activations. Although this increased the number of iterations, it was essential for avoiding out-of-memory (OOM) errors.

=== Enabling Gradient Checkpointing

- *Parameters Changed:*
 - actor_rollout_ref.model.enable_gradient_checkpointing (Actor)
 - critic.model.enable_gradient_checkpointing (Critic)

- *From*: Disabled (False)
- *To*: Enabled (True)
- *Purpose*: Gradient checkpointing trades increased computation time for reduced memory usage by discarding intermediate activations during the forward pass and recomputing them during the backward pass. This optimization was key to lowering VRAM requirements during training.

=== FSDP (Fully Sharded Data Parallel) Offloading

- *Parameters Changed:*
 - actor_rollout_ref.actor.fsdp_config.grad_offload
 - critic.model.fsdp_config.grad_offload
 - actor_rollout_ref.actor.fsdp_config.optimizer_offload
 - critic.model.fsdp_config.optimizer_offload
- *From:* Disabled (False)
- *To:* Enabled (True)
- *Purpose:* Enabling these settings offloads gradients and optimizer states (like momentum and variance) from GPU to CPU memory. This redistribution relieved GPU memory pressure, although it introduced additional overhead from CPU–GPU data transfers.

== Hardware Evaluations and Final Deployment
In parallel with our hyperparameter optimizations, we evaluated various GPU models to address hardware constraints. We tested several GPUs including the NVIDIA GeForce RTX 4090, A6000, and H100 models. Ultimately, by leveraging two H200 GPUs alongside our optimized hyperparameters, we achieved a stable training process.

== Conclusion
By transitioning from Windows to a Linux-based on-demand cloud instance, automating our deployment process, and methodically tuning hyperparameters, we successfully resolved multiple memory and optimization challenges. The key adjustments—reducing sequence length and batch size, enabling gradient checkpointing, and implementing FSDP offloading—allowed us to work within our VRAM constraints and successfully run the TinyZero project. The final tuning configurations, combined with more powerful H200 GPUs, provided the necessary stability to complete the training process. This experience helped us realize that our Windows PC lacked the hardware capabilities required to run these training workloads effectively.


= Training the Model

After preparing the training data, establishing the reward function, and tuning the hyperparameters, we proceeded with model training using dual H200SMX5 GPUs with a combined 282GB VRAM capacity. Our initial experiment employed a 3-billion-parameter model. However, we did not observe the desired emergent reasoning behavior. Instead, the model primarily optimized for the critic score by exploiting weaknesses in our reward function. With our initial configuration allocating 30% for structural accuracy and 70% for content quality, the model discovered it could easily satisfy the structural requirements by generating correctly formatted output using the prescribed brackets ($"<output></output>"$) and nested array structure. This optimization strategy resulted in a fixed, ineffective thinking pattern—essentially producing formulaic, non-informative responses as illustrated in Figure 18.

#figure(caption: [Mean Critic Rewards Left and Models Response Length right for the first training run with a 3B model https://wandb.ai/lukhausen-dhbw/TinyZero/runs/vps13688?nw=nwuserlukhausen],
  image("../assets/screenshots/train_1.png", width: 100%)
)

#figure(
  caption: "Example of Local Minimum thinking pattern. This pattern was present in all outputs of the model",
  block(
    fill: rgb("#f8f8f8"), 
    stroke: rgb("#e0e0e0"), 
    inset: 8pt, 
    radius: 4pt,
    width: 100%,
    ```
    <think>
    Let me solve this step by step. 1. I'll compare the input and output for each example. 2. I'll look for common patterns in the number changes. 3. I'll try to find the transformation pattern. 4. I'll apply that pattern to the test input.
    </think>
    ```
  ),
)

After terminating this initial training run, we considered two potential explanations: either our reward function lacked proper balance, or the model's capacity (3B parameters) was insufficient to develop the complex reasoning capabilities required for ARC tasks. This limitation of smaller models to develop sophisticated reasoning capabilities aligns with observations documented by Jian Pan in the TinyZero project @pan2025tinyzero_run @pan2025tinyzero. In our case, the reward structure imposed a minimum score of 0.1 for structural compliance, with a maximum potential structural reward of 0.3. Combined with the minimum content reward of 0.1, this created a performance ceiling of approximately 0.4, which is evident in the critic reward plateau shown in Figure 18. The model failed to discover strategies for improving content quality beyond this threshold.

To test these hypotheses, we extracted a checkpoint from the initial model and modified the reward distribution to 0.1 for structure and 0.9 for content, thereby significantly increasing the incentive for content improvement. After running this modified configuration for approximately three hours (80 steps), we observed no significant performance improvements—the critic reward remained stagnant, and response length stayed consistently flat.

#figure(caption: [Stagnant Critic response and stagnant Response length https://wandb.ai/lukhausen-dhbw/TinyZero/runs/tbo3orw4?nw=nwuserlukhausen],
  image("../assets/screenshots/stagnant_critic_chart.png", width: 100%)
)

Based on these results, we concluded that the 3-billion-parameter model lacked sufficient capacity to develop the reasoning capabilities required for ARC tasks, consistent with scaling laws that predict emergent abilities appear at specific parameter thresholds. We subsequently scaled up to a 7-billion-parameter model and repeated the experimental process to test whether this increased scale would trigger the emergence of reasoning capabilities.

This larger model was trained for approximately 450 minutes (7.5 hours). Despite prior research by Jian Pan suggesting that models sometimes experience delayed emergence of reasoning capabilities, we observed no improvements in response quality or reward metrics throughout this extended training period, as illustrated in Figure 20.

#figure(caption: [No significant Changes in the behavior of the model https://wandb.ai/lukhausen-dhbw/TinyZero/runs/tbo3orw4?nw=nwuserlukhausen],
  image("../assets/screenshots/7b_wandb.png", width: 100%)
)

The 7B model exhibited the same optimization pattern as the 3B variant—focusing exclusively on structural compliance while failing to develop meaningful reasoning capabilities. The outputs continued to display identical, formulaic thinking patterns, suggesting no substantive improvement in reasoning. We hypothesized this failure could stem from either an inherent limitation in the model's capacity to learn the complex ARC tasks or suboptimal reward function design that encouraged reward hacking rather than genuine reasoning. In previous runs, we had allocated 30% of the reward to structural compliance and 70% to content quality.

We subsequently adjusted the reward distribution to 10% for structure and 90% for content, further emphasizing content quality. This configuration ran for approximately 220 minutes (3.5 hours) and completed 43 training steps. However, the reward curve maintained its logarithmic shape without improvement, and response length continued to decrease.

#figure(caption: [Logarithmic curve even after adjusting the reward score https://wandb.ai/lukhausen-dhbw/TinyZero/runs/acmyhkji?nw=nwuserlukhausen],
  image("../assets/screenshots/7b_wandb_2.png", width: 100%)
)

To address this persistent local minimum, we implemented a novel incentive structure designed to encourage more extensive reasoning. We modified the reward function to explicitly reward the length of content within the thinking tags, with the goal of promoting more elaborate reasoning sequences. Using the checkpoint from the previous 7B model, we implemented a balanced reward distribution: 10% for structural correctness, 40% for thinking output length, and 50% for content quality.

This approach aimed to first establish longer reasoning chains before gradually shifting focus toward reasoning quality and content accuracy. We deployed this length-optimized reward function starting from step 30 of the previous model checkpoint, which had already learned the correct output structure but struggled with coherent reasoning. Within just 10 steps, the model demonstrated notable improvements in reasoning length while maintaining correct output formatting.

#figure(caption: [Ten steps of boosting the thinking length of the model. https://wandb.ai/lukhausen-dhbw/TinyZero/runs/oq6kjqvf?nw=nwuserlukhausen],
  image("../assets/screenshots/7b_thinking_boost.png", width: 100%)
)

After just 10 steps with the modified reward function, we observed significant improvements in the reasoning patterns produced by the model:

#figure(
  caption: "Example of increased reasoning length through modified reward function",
  ```
<think>
Let me solve this step by step. 1. I observe that in each train example, the input is a 2-dimensional list with varying number of rows and two elements in each row. 2. The output pattern is that each row of the input is duplicated one or more times to create the corresponding row of the output. 3. The number of times a row is duplicated in the output seems to be related to the number of digits in the elements of the row - the more digits, the more times it seems to be duplicated. 4. However, the row at the top of the input ("3999" in this example) is never duplicated. Applying these observations to the test input, I see that:
- The top row ("3999") should not be duplicated in the output.
- The second row ("9355") has four digits, so it should be duplicated four times in the output.
- The third row ("9569") has four digits, so it should be duplicated four times in the output.
- The fourth row ("9964") has four digits, so it should be duplicated four times in the output.
- The bottom row ("9994") has four digits, so it should be duplicated four times in the output.
</think>
```,
)

After successfully increasing the reasoning elaboration, we transitioned to a purely content-based reward function to encourage meaningful reasoning rather than merely verbose output.

#figure(caption: [Running the purely content based reward. https://wandb.ai/lukhausen-dhbw/TinyZero/runs/vbfszi8j?nw=nwuserlukhausen],
  image("../assets/screenshots/7b_run_only_content.png", width: 100%)
)

Despite this intervention, we observed that output length decreased again, and even after more than 30 additional training steps, the model failed to overcome its fundamental limitations in reasoning capabilities.

== Training on an Easier Dataset

We hypothesized that the 7B parameter scale might be insufficient for developing the sophisticated reasoning capabilities required for complex ARC tasks, as scaling laws suggest that emergent abilities may require even higher parameter thresholds for complex reasoning tasks. Due to budget constraints, we opted not to scale to a 14B model, as the required resources (minimum 4× H200 GPUs) were prohibitively expensive for on-demand cloud GPU instances. Instead, we reduced task difficulty to determine if the model could demonstrate emergent reasoning on simpler problems.

Having focused exclusively on the ARC-AGI-2 dataset, we created a new dataset incorporating easier variants of similar tasks. This dataset combined the ARC-AGI-1 training set with the Concept Arc Dataset, which includes various simplified tasks @moskvichev2023the. Our strategy was to first determine if the model could develop emergent reasoning capabilities on simpler problems before gradually increasing task complexity. This approach is supported by research demonstrating that training on simpler examples can significantly enhance reasoning and generalization capabilities @hase2024unreasonableeffectivenesseasytraining.

After creating this dataset #footnote("https://huggingface.co/datasets/Lukhausen/arc-agi-lepus-v1-easy") we initiated training with the 7B model.

#figure(caption: [Reward and response length for the easy dataset. https://wandb.ai/lukhausen-dhbw/TinyZero/runs/vps13688?nw=nwuserlukhausen],
  image("../assets/screenshots/easy_dataset_chart.png", width: 100%)
)

Rather than limiting training to 40 steps as in previous runs, we allowed the model to converge fully, selecting the checkpoint at step 70 which achieved the highest reward score. The reward distribution for this run maintained our 10% structure and 90% content allocation.

Despite the simplified dataset, the model still failed to develop emergent reasoning capabilities. We attempted to kickstart reasoning development using the same approach that previously succeeded with the 7B model on the more complex dataset. The reasoning boost run implemented a reward distribution of 30% for output length, 60% for content correctness, and 10% for structural compliance.

The model quickly adapted to this reward function and began producing longer outputs. However, unlike our previous experience where extended outputs demonstrated meaningful task-specific reasoning, this time the model exploited the reward mechanism by generating verbose but uninformative content that bore little relevance to the tasks at hand:

#figure(
  caption: "Long, yet non-informational reasoning chain.",
  ```
<think>
Let me solve this step by step.
1. I will carefully analyze the given train examples, focusing on the pattern of transformation from the train input to the train output. I will look for similarities in the transformation patterns among the examples, such as the repetitive sequences and the specific elements that remain unchanged during the transformation process.
2. I will pay attention to the recurring 

[...]

40. I will reflect on the problem-solving process and identify potential areas for improvement in understanding the significance and relevance of the transformation patterns in relation to the overall problem. By considering the broader context and implications of the transformation process, I can gain a more holistic understanding of its impact and contribute to a more effective and meaningful solution.
</think>
```,
)

The model developed a meta-cognitive pattern of thinking about how to think, rather than applying reasoning to the specific task. Instead of engaging with the problem content, it generated increasingly lengthy pseudo-reasoning chains devoid of task-relevant information or insights.

Upon reverting to our standard reward configuration (10% for structure and 90% for content), the model persistently maintained its non-substantive reasoning patterns without demonstrating performance improvements. We attribute this phenomenon to premature convergence during initial training phases, which appears to have constrained the model's optimization trajectory to a suboptimal local minimum in the parameter space. This early fixation potentially impeded the model's capacity to explore more promising regions of the solution landscape, effectively crystallizing ineffective reasoning strategies that proved resistant to subsequent refinement efforts. This observation underscores a fundamental challenge in reinforcement learning for complex reasoning tasks: maintaining sufficient exploration capabilities throughout the optimization process to avoid entrapment in suboptimal solution manifolds.


]