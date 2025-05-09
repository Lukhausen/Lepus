#!/bin/bash

# --- Environment Variables ---
export N_GPUS=2
export BASE_MODEL=./models/Qwen2.5-3B
export DATA_DIR=./data/arc_agi_two
export ROLLOUT_TP_SIZE=2
export EXPERIMENT_NAME=arc_agi_two-qwen2.5-3B
export VLLM_ATTENTION_BACKEND=XFORMERS
export WANDB_API_KEY="724a473f54d00ed3c8fab36dc7abf32c23523360"


# --- Command Line Arguments (YOUR PROVIDED structure, adjusted values ONLY, WITH BACKSLASHES) ---
python3 -m verl.trainer.main_ppo \
    data.train_files=$DATA_DIR/train.parquet \
    data.val_files=$DATA_DIR/test.parquet \
    data.train_batch_size=512 \
    data.val_batch_size=512 \
    data.max_prompt_length=11300 \
    data.max_response_length=10000 \
    \
    actor_rollout_ref.model.path=$BASE_MODEL \
    actor_rollout_ref.model.use_remove_padding=True \
    \
    actor_rollout_ref.actor.use_dynamic_bsz=True \
    actor_rollout_ref.actor.optim.lr=1e-6 \
    actor_rollout_ref.actor.ppo_mini_batch_size=64 \
    actor_rollout_ref.actor.ppo_micro_batch_size=1 \
    \
    actor_rollout_ref.rollout.log_prob_micro_batch_size=4 \
    actor_rollout_ref.rollout.tensor_model_parallel_size=$ROLLOUT_TP_SIZE \
    actor_rollout_ref.rollout.gpu_memory_utilization=0.90 \
    \
    actor_rollout_ref.ref.log_prob_micro_batch_size=4 \
    \
    critic.optim.lr=1e-5 \
    critic.model.path=$BASE_MODEL \
    critic.ppo_micro_batch_size=1 \
    \
    algorithm.kl_ctrl.kl_coef=0.001 \
    \
    trainer.logger=['wandb'] \
    +trainer.val_before_train=False \
    trainer.default_hdfs_dir=null \
    trainer.n_gpus_per_node=$N_GPUS \
    trainer.nnodes=1 \
    trainer.save_freq=50 \
    trainer.test_freq=50 \
    trainer.project_name=TinyZero \
    trainer.experiment_name=$EXPERIMENT_NAME \
    trainer.total_epochs=15 \
    \
    2>&1 | tee verl_"$EXPERIMENT_NAME".log