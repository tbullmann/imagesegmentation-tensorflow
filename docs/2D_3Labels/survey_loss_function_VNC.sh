#!/usr/bin/env bash

### Prepare data
python tools/process.py \
    --operation combine \
    --input_dir  datasets/vnc/stack1/raw/ \
    --target_dir  datasets/vnc/stack1/labels/ \
    --output_dir datasets/vnc/combined1/


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
	--output_dir temp/survey_loss/VCN/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss hinge \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/VCN/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss square \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/VCN/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss softmax \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/VCN/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss approx \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/VCN/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss dice \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/VCN/train/$counter \
	--input_dir datasets/vnc/combined$i/train \
	--loss logistic \
	--display_freq 500  --max_epochs 2000
done


### Test and evaluate
counter=0
for j in `seq 1 6`;
do
for i in `seq 1 3`;
do
	((counter++))
	python translate.py  --model pix2pix  --mode test \
	--checkpoint temp/survey_loss/VCN/train/$counter \
	--output_dir temp/survey_loss/VCN/test/$counter \
	--input_dir datasets/vnc/combined$i/val \
    --image_width 1024  --image_height 1024
	bash tools/evaluate.sh temp/survey_loss/VCN/test/$counter synapses
	bash tools/evaluate.sh temp/survey_loss/VCN/test/$counter mitochondria
	bash tools/evaluate.sh temp/survey_loss/VCN/test/$counter membranes
done
done










