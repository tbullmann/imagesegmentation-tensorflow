#!/usr/bin/env bash

#### Prepare data
#python tools/process.py \
#    --operation combine \
#    --input_dir  datasets/vnc/raw/ \
#    --target_dir  datasets/vnc/labels/ \
#    --output_dir datasets/vnc/combined/

#python tools/split.py \
#    --dir datasets/vnc/combined/

### Train


	python translate.py    --mode train \
	--network resnet \
	--output_dir temp/temp/standard_VCN/train \
	--input_dir datasets/vnc/combined/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000


### Test

	python translate.py   --mode test \
	--checkpoint temp/temp/standard_VCN/train \
	--output_dir temp/temp/standard_VCN/test \
	--input_dir datasets/vnc/combined/val \
    --image_width 1024  --image_height 1024

#### Evaluate
# bash tools/evaluate.sh temp/standard_VCN/test synapses
# bash tools/evaluate.sh temp/standard_VCN/test mitochondria
# bash tools/evaluate.sh temp/standard_VCN/test membranes

