#import "@preview/supercharged-dhbw:3.4.0": acr, acrf, sourcecode
#import "../utils/llm.typ": llm-input, llm-output, llm-interaction

#let experimental = [
= Experimental Results

For our project, we initially attempted to set up the development environment on our Windows 10 machines, following the steps outlined in Project TinyZero @pan2025tinyzero. We created a Conda environment using Python 3.9, installed CUDA 11.8, and configured the appropriate environment variables (including CUDA_HOME, CUDA_PATH, and adding CUDA's include and bin directories to the system PATH).

To install PyTorch with CUDA support, we specified the exact version using the command: pip install torch==2.0.0 --index-url https://download.pytorch.org/whl/cu118 and subsequently installed matching torchvision and other dependencies.

We also installed NVIDIA Nsight Visual Studio Edition and set up additional components (including Visual Studio Build Tools, C++ compilers, and various CUDA profiling tools). Despite carefully following these steps, we encountered persistent errors during the installation of the flash-attention package. The issues primarily stemmed from compatibility problems between NVIDIA's nvcc compiler and our installed Visual Studio version. We made several attempts to resolve these issues—including reinstalling CUDA, adjusting environment variables, trying different Visual Studio installations, and even using nvcc flags to allow unsupported compilers—but the build errors continued.

Due to these ongoing challenges with the Windows setup, we ultimately switched to an on-demand cloud instance running Linux, where the setup process proved significantly smoother.\
On the cloud instance we automated the deployment with a script to simplify future setups—this proved especially valuable since the entire environment is deleted when the instance is decommissioned.

After successfully running the project on Linux, we encountered challenges related to insufficient GPU memory (VRAM) and optimization issues during training. Memory errors initially emerged due to high RAM requirements from long model sequences and large batch sizes. To address these issues, we conducted systematic hyperparameter tuning and hardware evaluations. Below is a detailed summary of our optimization strategy:
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

After Prparing the Traing data, setting up the Reward fucntion and Tungin the Hyperparmeters, we were ready to start training the model using 2 H200SMX5 with a total of 282GB GPU VRAM we started with the first run, using a 3-billion-parameter model. However, iwe did not observe the desired emergent behaviour of rasoning to com to a concolusion, as it primarily optimized for the critic score, and basically hacked the reward fuction. We had assigned 0.3 for structure reward and 0.7 for content reward. The model realized it could easily achieve the structure reward by producing the correct grid size and the correct format using output brackets ($"<output></output>"$) aand a nested array. It heavily optimized for this, resulting in a completely fixed and ineffective thinking pattern—essentially useless and utter nonsense, as shown in the display below. 

#figure(
  image("../assets/screenshots/example_tokenization_4.png", width: 90%)
)

#figure(
  caption: "Exmaple of Local Minimum thinking pattern",
  sourcecode[```
<think>
Let me solve this step by step. 1. I'll compare the input and output for each example. 2. I'll look for common patterns in the number changes. 3. I'll try to find the transformation pattern. 4. I'll apply that pattern to the test input.
</think>


    ```],
)

After stopping this run, we considered two possibilities: either the reward score wasn't well-balanced, or we were essentially trying to teach a hamster to fly—meaning the model size was too small to grasp the reasoning needed to boost the content reward score. The minimum content reward was 0.1, which led the critic reward to max out at 0.4, as the model fully understood the 0.3 portion and often produced a correct output structure. However, it didn’t understand how to improve the content within that structure to reach higher scores.

To test both hypotheses, we took a checkpoint of the model and modified the reward function to decrease the reward for correct output structure. We assigned 0.1 for structure and 0.9 for content. After running this version for a little over three hours and approximately 80 steps, we canceled it. The critic showed no signs of improvement, and the response length remained consistently flat.

This led us to conclude that a 3-billion-parameter model lacks the inherent capability to learn the type of reasoning required for ARC tasks. After some consideration, we decided to use a 7-billion-parameter model and repeat the process.

This run lasted about 450 minutes (more than seven hours). Based on prior experience by Jian Pan with TinyZero, we knew models sometimes had delayed realizations when learning required thinking patterns. However, after seven and a half hours, we also stopped this run. As seen in the graphic below, there were no signs of improved response length or reward score.

We observed the same pattern as with the previous 3-billion run: the model optimized only for the structural component of the reward and not for the actual content. The outputs showed identical “thinking patterns,” indicating the model wasn’t generating meaningful reasoning. This run also failed.

Afterward, we adjusted the reward distribution—not to 30% for content and 70% for structure, but instead to 30% for structure and 70% for content. We ran this setup for about 220 minutes (roughly three and a half hours), completing 43 steps. Again, the logarithmic curve of the reward score didn’t improve, and the response length kept decreasing.

So, we decided to implement an incentive for the model to think longer. We stopped this run and created a modified reward function that also rewarded the "length" of the thinking output it generated. The goal was to encourage longer reasoning sequences and help the model escape the local minimum it kept falling into—where it would only optimize structure without addressing content.

Using the checkpoint from the last 7-billion-parameter model run, we ran it again with the new reward function: 10% for structural correctness, 40% for thinking output length (within the “thinking” tags), and 50% for the quality of the actual content.

The idea here is to boost the model’s reasoning length first. Once we see it generating meaningful chains of thought, we plan to remove the length incentive to push the model to focus more on logical reasoning and content accuracy, maximizing both content structure and content reward score.

We ran theis think length optimized reward fucntion from teh 30th setp of the previouse model, which allready effectively had learend the output structre, yet strugglred with the chain of though. An interesting observation during teh 10 step long thinking elongation run was, that the model started to inclrease not only its chain of though in the thinking tags, but also from step 7 onwards started reward hacking by "inspecting the inputs in more detail"





]
