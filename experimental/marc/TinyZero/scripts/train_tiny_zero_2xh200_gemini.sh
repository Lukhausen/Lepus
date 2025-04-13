
export N_GPUS=2
export BASE_MODEL=./models/Qwen2.5-3B
export DATA_DIR=./data/arc_agi_two
export ROLLOUT_TP_SIZE=1
export EXPERIMENT_NAME=arc_agi_two-qwen2.5-3B
export VLLM_ATTENTION_BACKEND=XFORMERS
export WANDB_API_KEY="724a473f54d00ed3c8fab36dc7abf32c23523360"


python3 -m verl.trainer.main_ppo \
data.train_files=$DATA_DIR/train.parquet \
data.val_files=$DATA_DIR/test.parquet \
data.train_batch_size=512 \ 
data.val_batch_size=512 \   
data.max_prompt_length=11300 \
data.max_response_length=10000 \
data.prompt_key='prompt' \
data.tokenizer=$BASE_MODEL \

actor_rollout_ref.model.path=$BASE_MODEL \
actor_rollout_ref.model.enable_gradient_checkpointing=True \ 
actor_rollout_ref.model.use_remove_padding=True \

actor_rollout_ref.actor.strategy='fsdp' \
actor_rollout_ref.actor.fsdp_config.fsdp_size=-1 \
actor_rollout_ref.actor.optim.lr=1e-6 \
actor_rollout_ref.actor.ppo_epochs=1 \
actor_rollout_ref.actor.ppo_mini_batch_size=64 \
actor_rollout_ref.actor.ppo_micro_batch_size=1 \  
actor_rollout_ref.actor.grad_clip=1.0 \
actor_rollout_ref.actor.kl_loss_coef=0.001 \
actor_rollout_ref.actor.use_kl_loss=True \

actor_rollout_ref.rollout.name='vllm' \
actor_rollout_ref.rollout.dtype='bfloat16' \
actor_rollout_ref.rollout.tensor_model_parallel_size=$ROLLOUT_TP_SIZE \ 
actor_rollout_ref.rollout.gpu_memory_utilization=0.90 \ 
actor_rollout_ref.rollout.max_num_seqs=128 \ 
actor_rollout_ref.rollout.max_num_batched_tokens=65536 \ 
actor_rollout_ref.rollout.n=5 \
actor_rollout_ref.rollout.do_sample=True \
actor_rollout_ref.rollout.temperature=1.0 \
actor_rollout_ref.rollout.top_p=1.0 \
actor_rollout_ref.rollout.top_k=-1 \

actor_rollout_ref.ref.strategy='fsdp' \
actor_rollout_ref.ref.fsdp_config.fsdp_size=-1 \
actor_rollout_ref.ref.fsdp_config.param_offload=True \ 
actor_rollout_ref.ref.log_prob_micro_batch_size=4 \  

actor_rollout_ref.hybrid_engine=True \

critic.model.path=$BASE_MODEL \
critic.model.tokenizer_path=$BASE_MODEL \
critic.model.enable_gradient_checkpointing=True \ 
critic.strategy='fsdp' \
critic.fsdp_config.fsdp_size=-1 \
critic.optim.lr=1e-5 \
critic.ppo_epochs=1 \
critic.ppo_mini_batch_size=64 \
critic.ppo_micro_batch_size=1 \  
critic.grad_clip=1.0 \
critic.cliprange_value=0.5 \

algorithm.gamma=1.0 \
algorithm.lam=1.0 \
algorithm.kl_penalty='kl' \
algorithm.kl_ctrl.type='fixed' \
algorithm.kl_ctrl.kl_coef=0.001 \

trainer.n_gpus_per_node=$N_GPUS \
trainer.nnodes=1 \
trainer.total_epochs=15 \
trainer.save_freq=50 \ 
trainer.test_freq=50 \ 
trainer.logger=['wandb'] \
trainer.project_name=TinyZero \
trainer.experiment_name=$EXPERIMENT_NAME \
+trainer.val_before_train=False \
trainer.default_local_dir='checkpoints/TinyZero/$EXPERIMENT_NAME' \

2>&1 | tee verl_"$EXPERIMENT_NAME".log