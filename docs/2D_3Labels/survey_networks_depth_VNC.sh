#!/usr/bin/env bash

### Prepare data
python tools/process.py \
    --operation combine \
    --input_dir  datasets/vnc/raw/ \
    --target_dir  datasets/vnc/labels/ \
    --output_dir datasets/vnc/combined/

python tools/split.py \
    --dir datasets/vnc/combined/

### Train
counter=0

for n_depth in 4 5 6 7 8;
do
	((counter++))
	python translate.py    --mode train \
	--network unet  --u_depth $n_depth  \
	--output_dir temp/survey_depth/VCN/train/$counter \
	--input_dir datasets/vnc/combined/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000
done

for n_dense_blocks in 1 2 3 4 5;
do
	((counter++))
	python translate.py    --mode train \
	--network densenet  --n_dense_blocks $n_dense_blocks  \
	--output_dir temp/survey_depth/VCN/train/$counter \
	--input_dir datasets/vnc/combined/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000
done

for n_highway_units in 4 6 9 12 16;
do
	((counter++))
	python translate.py    --mode train \
	--network highwaynet  --n_highway_units $n_highway_units  \
	--output_dir temp/survey_depth/VCN/train/$counter \
	--input_dir datasets/vnc/combined/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000
done

for n_res_blocks in 4 6 9 12 16;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet  --n_res_blocks $n_res_blocks \
	--output_dir temp/survey_depth/VCN/train/$counter \
	--input_dir datasets/vnc/combined/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000
done


### Test
for i in `seq 1 $counter`;
do
	python translate.py   --mode test \
	--checkpoint temp/survey_depth/VCN/train/$i \
	--output_dir temp/survey_depth/VCN/test/$i \
	--input_dir datasets/vnc/combined/val \
    --image_width 1024  --image_height 1024
done

#### Evaluate
for i in `seq 1 $counter`;
do
	bash tools/evaluate.sh temp/survey_depth/VCN/test/$i synapses
	bash tools/evaluate.sh temp/survey_depth/VCN/test/$i mitochondria
	bash tools/evaluate.sh temp/survey_depth/VCN/test/$i membranes
done






