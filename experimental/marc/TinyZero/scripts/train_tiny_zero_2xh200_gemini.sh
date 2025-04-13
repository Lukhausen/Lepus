#!/bin/bash

# --- Environment Variables ---
export N_GPUS=2
export BASE_MODEL=./models/Qwen2.5-3B
export DATA_DIR=./data/arc_agi_two
export ROLLOUT_TP_SIZE=2
export EXPERIMENT_NAME=arc_agi_two-qwen2.5-3B
export VLLM_ATTENTION_BACKEND=XFORMERS
export WANDB_API_KEY="724a473f54d00ed3c8fab36dc7abf32c23523360"

# --- Command Line Arguments (Original Structure, Optimal Values) ---
# Note: We are overriding values from the original log based on calculations
#       Parameters not explicitly listed here will use the verl framework defaults
#       or the values inferred from the original log if not overridden.

python3 -m verl.trainer.main_ppo \
    data.train_files=$DATA_DIR/train.parquet \
    data.val_files=$DATA_DIR/test.parquet \
    data.train_batch_size=512 \                 # << OPTIMAL VALUE (Original: 128)
    data.val_batch_size=512 \                   # << OPTIMAL VALUE (Original: 640)
    data.max_prompt_length=11300 \              # Task Requirement (Original: 11300)
    data.max_response_length=10000 \            # Task Requirement (Original: 10000)
    data.prompt_key='prompt' \                  # Structure: From Original Log
    data.tokenizer=$BASE_MODEL \                # Structure: Use Base Model Tokenizer
    \
    actor_rollout_ref.model.path=$BASE_MODEL \  # Structure: From Original Log
    actor_rollout_ref.model.enable_gradient_checkpointing=True \ # << OPTIMAL VALUE (Original: True - ESSENTIAL)
    actor_rollout_ref.model.use_remove_padding=True \ # Structure: From Original Log
    \
    actor_rollout_ref.actor.strategy='fsdp' \     # Structure: From Original Log
    actor_rollout_ref.actor.fsdp_config.fsdp_size=-1 \ # Structure: From Original Log
    actor_rollout_ref.actor.optim.lr=1e-6 \       # Optimal Value: Keep default / Structure: From Original Log
    actor_rollout_ref.actor.ppo_epochs=1 \        # Optimal Value: Standard / Structure: From Original Log
    actor_rollout_ref.actor.ppo_mini_batch_size=64 \ # Optimal Value: Reasonable / Structure: From Original Log
    actor_rollout_ref.actor.ppo_micro_batch_size=1 \  # << OPTIMAL VALUE (Original: 4 - CRITICAL for memory)
    actor_rollout_ref.actor.grad_clip=1.0 \       # Optimal Value: Standard / Structure: From Original Log
    actor_rollout_ref.actor.kl_loss_coef=0.001 \  # Optimal Value: Standard / Structure: From Original Log (used for runtime loss)
    actor_rollout_ref.actor.use_kl_loss=True \    # Optimal Value: Standard / Structure: From Original Log
    \
    actor_rollout_ref.rollout.name='vllm' \       # Structure: From Original Log
    actor_rollout_ref.rollout.dtype='bfloat16' \  # Optimal Value: H200 performance / Structure: From Original Log
    actor_rollout_ref.rollout.tensor_model_parallel_size=$ROLLOUT_TP_SIZE \ # << OPTIMAL VALUE (Original: 1) Uses Env Var = 2
    actor_rollout_ref.rollout.gpu_memory_utilization=0.90 \ # << OPTIMAL VALUE (Original: 0.4) Aggressive for KV Cache
    actor_rollout_ref.rollout.max_num_seqs=128 \     # << OPTIMAL VALUE (Original: 1024) Adjusted for S=21300 cost
    actor_rollout_ref.rollout.max_num_batched_tokens=65536 \ # << OPTIMAL VALUE (Original: 8192) Increased for TP=2/H200
    actor_rollout_ref.rollout.n=5 \                  # Optimal Value: Keep default / Structure: From Original Log
    actor_rollout_ref.rollout.do_sample=True \       # Structure: From Original Log
    actor_rollout_ref.rollout.temperature=1.0 \      # Structure: From Original Log
    actor_rollout_ref.rollout.top_p=1.0 \            # Structure: From Original Log
    actor_rollout_ref.rollout.top_k=-1 \             # Structure: From Original Log
    actor_rollout_ref.rollout.log_prob_micro_batch_size=4 \ # << OPTIMAL VALUE (Original: 4) Consistent setting
    \
    actor_rollout_ref.ref.fsdp_config.fsdp_size=-1 \  # Structure: From Original Log
    actor_rollout_ref.ref.fsdp_config.param_offload=True \ # Optimal Value: Save GPU RAM / Structure: From Original Log
    actor_rollout_ref.ref.log_prob_micro_batch_size=4 \  # << OPTIMAL VALUE (Original: 2) OK for fwd pass
    \
    actor_rollout_ref.hybrid_engine=True \        # Structure: From Original Log
    \
    critic.model.path=$BASE_MODEL \               # << OPTIMAL VALUE (Original: deepseek-llm-7b-chat) Use same base model
    critic.model.tokenizer_path=$BASE_MODEL \     # << OPTIMAL VALUE (Original: ./models/Qwen2.5-3B) Use base tokenizer
    critic.model.enable_gradient_checkpointing=True \ # << OPTIMAL VALUE (Original: False - ESSENTIAL for memory)
    critic.model.fsdp_config.fsdp_size=-1 \       # Structure: From Original Log (fsdp_config under .model)
    critic.strategy='fsdp' \                      # Structure: From Original Log (strategy directly under critic)
    critic.optim.lr=1e-5 \                        # Optimal Value: Keep default / Structure: From Original Log (optim directly under critic)
    critic.ppo_epochs=1 \                         # Optimal Value: Standard / Structure: From Original Log
    critic.ppo_mini_batch_size=64 \               # Optimal Value: Reasonable / Structure: From Original Log
    critic.ppo_micro_batch_size=1 \               # << OPTIMAL VALUE (Original: 64 - CRITICAL for memory)
    critic.grad_clip=1.0 \                        # Optimal Value: Standard / Structure: From Original Log
    critic.cliprange_value=0.5 \                  # Optimal Value: Keep default / Structure: From Original Log
    \
    algorithm.gamma=1.0 \                         # Standard / Structure: From Original Log
    algorithm.lam=1.0 \                           # Standard / Structure: From Original Log
    algorithm.kl_penalty='kl' \                   # Standard / Structure: From Original Log
    algorithm.kl_ctrl.type='fixed' \              # Standard / Structure: From Original Log
    algorithm.kl_ctrl.kl_coef=0.001 \             # Optimal Value: Standard / Structure: From Original Log (used for KL control target)
    \
    trainer.n_gpus_per_node=$N_GPUS \             # Structure: From Original Log
    trainer.nnodes=1 \                            # Structure: From Original Log
    trainer.total_epochs=15 \                     # Structure: From Original Log
    trainer.save_freq=50 \                        # << OPTIMAL VALUE (Original: 10) Adjust for faster steps
    trainer.test_freq=50 \                        # << OPTIMAL VALUE (Original: 10) Adjust for faster steps
    trainer.logger=['wandb'] \                    # Standard / Structure: From Original Log
    trainer.project_name=TinyZero \               # Standard / Structure: From Original Log
    trainer.experiment_name=$EXPERIMENT_NAME \    # Standard / Structure: From Original Log
    +trainer.val_before_train=False \             # Standard / Structure: From Original Log
    trainer.default_local_dir="checkpoints/TinyZero/$EXPERIMENT_NAME" \ # Structure: From Original Log (using updated name)
    \
    2>&1 | tee verl_"$EXPERIMENT_NAME".log