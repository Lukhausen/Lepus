"""
Preprocess dataset for countdown task - given a target number and N numbers, generate equations to reach target
"""

import re
import os
from datasets import Dataset, load_dataset
from random import randint, seed, choice
from typing import List, Tuple
from tqdm import tqdm
from verl.utils.hdfs_io import copy, makedirs
import argparse


def make_prefix(dp, template_type):
    train = dp['train']
    test = dp['test']
    # NOTE: also need to change reward_score/countdown.py
    if template_type == 'base':
        """This works for any base model"""
        prefix = f"""<|im_start|>system\nYou will be provided with example inputs and outputs. 
        Analyze the train examples. Your goal is to find common transformation patterns among those and apply the found patterns to the test input to create the test output.<|im_end|>\n<|im_start|>user\n {train} \n\n\n {test}\n\n Figure out how to create the test output. Use <think> </think> tags to reason about the problem. Return the final answer in <answer> </answer> tags as a nested list.<|im_end|>\n<|im_start|>assistant\nLet me solve this step by step.\n<think>"""
    elif template_type == 'qwen-instruct':
        """This works for Qwen Instruct Models"""
        prefix = f"""<|im_start|>system\nYou will be provided with example inputs and outputs. 
        Analyze the train examples. Your goal is to find common transformation patterns among those and apply the found patterns to the test input to create the test output.<|im_end|>\n<|im_start|>user\n {train} \n\n\n {test}\n\n Figure out how to create the test output. Use <think> </think> tags to reason about the problem. Return the final answer in <answer> </answer> tags as a nested list.<|im_end|>\n<|im_start|>assistant\nLet me solve this step by step.\n<think>"""
    return prefix


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--local_dir', default='./data/arc_agi_two')
    parser.add_argument('--hdfs_dir', default=None)
    parser.add_argument('--num_samples', type=int, default=100000)
    parser.add_argument('--num_operands', type=int, default=6)
    parser.add_argument('--max_target', type=int, default=1000)
    parser.add_argument('--min_number', type=int, default=1)
    parser.add_argument('--max_number', type=int, default=100)
    parser.add_argument('--train_size', type=int, default=825)
    parser.add_argument('--test_size', type=int, default=150)
    parser.add_argument('--template_type', type=str, default='base')

    args = parser.parse_args()

    data_source = 'arc_agi_two'
    TRAIN_SIZE = args.train_size
    TEST_SIZE = args.test_size

    raw_dataset = load_dataset('Lukhausen/arc-agi-lepus-v1', split='train')
    #print(raw_dataset)

    assert len(raw_dataset) > TRAIN_SIZE + TEST_SIZE
    train_dataset = raw_dataset.select(range(TRAIN_SIZE))
    test_dataset = raw_dataset.select(range(TRAIN_SIZE, TRAIN_SIZE + TEST_SIZE))

    def make_map_fn(split):
        def process_fn(example, idx):
            question = make_prefix(example, template_type=args.template_type)
            solution = {
                "train": example['train'],
                "test": example['test'],
                "test_answer":  example['test_answer']
            }
            data = {
                "data_source": data_source,
                "prompt": [{
                    "role": "user",
                    "content": question,
                }],
                "ability": "math",
                "reward_model": {
                    "style": "rule",
                    "ground_truth": solution
                },
                "extra_info": {
                    'split': split,
                    'index': idx,
                }
            }
            return data
        return process_fn
    
    train_dataset = train_dataset.map(function=make_map_fn('train'), with_indices=True)
    test_dataset = test_dataset.map(function=make_map_fn('test'), with_indices=True)

    local_dir = args.local_dir
    hdfs_dir = args.hdfs_dir

    train_dataset.to_parquet(os.path.join(local_dir, 'train.parquet'))
    test_dataset.to_parquet(os.path.join(local_dir, 'test.parquet'))

    if hdfs_dir is not None:
        makedirs(hdfs_dir)
        copy(src=local_dir, dst=hdfs_dir) 
