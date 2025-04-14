source ~/.bashrc
conda activate zero
cd experimental/marc/TinyZero/
python ./examples/data_preprocess/arc_agi_two.py --local_dir ./data/arc_agi_two
bash scripts/train_tiny_zero_7b_medium_optimized.sh
