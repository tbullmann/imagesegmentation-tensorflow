#!/usr/bin/env bash

######################## NOT working YET

### Prepare different train/test combinations

#python tools/process.py \
#    --operation combine \
#    --input_dir  datasets/snemi3d/input/ \
#    --target_dir  datasets/snemi3d/label3/ \
#    --output_dir datasets/snemi3d/input2label3/

for i in `seq 2 3`;
do
	cp -rf datasets/vnc/combined1/ datasets/vnc/combined$i/
done
for i in `seq 1 3`;
do
	python tools/split.py \
  	--dir datasets/vnc/combined$i
done



### Train

counter=0

# type image --> hinge loss
for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet    \
	--output_dir temp/publication3/loss_functions/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss hinge \
	--display_freq 500  --max_epochs 1000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/publication3/loss_functions/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss square \
	--display_freq 500  --max_epochs 1000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/publication3/loss_functions/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss softmax \
	--display_freq 500  --max_epochs 1000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/publication3/loss_functions/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss approx \
	--display_freq 500  --max_epochs 1000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/publication3/loss_functions/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss dice \
	--display_freq 500  --max_epochs 1000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/publication3/loss_functions/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss logistic \
	--display_freq 500  --max_epochs 1000
done


### Test and evaluate

counter=0
for j in `seq 1 6`;
do
for i in `seq 1 3`;
do
	((counter++))
	python translate.py  --model pix2pix  --mode test \
	--checkpoint temp/publication3/loss_functions/train/$counter \
	--output_dir temp/publication3/loss_functions/test/$counter \
	--input_dir datasets/vnc/combined$i/val \
    --image_width 1024  --image_height 1024
	bash tools/evaluate.sh temp/publication3/loss_functions/test/$counter synapses
	bash tools/evaluate.sh temp/publication3/loss_functions/test/$counter mitochondria
	bash tools/evaluate.sh temp/publication3/loss_functions/test/$counter membranes
done
done


### Accumulate results
# Using the Python script to link evaluation results in CSV fules with parameters from JSON files
pyhton publication/loss_functions/aggregate.py








