#import "@preview/supercharged-dhbw:3.4.0": acr, acrf
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



]
