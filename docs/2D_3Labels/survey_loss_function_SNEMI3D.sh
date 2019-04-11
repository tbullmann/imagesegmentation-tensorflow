#!/usr/bin/env bash

### Prepare data
python tools/process.py \
    --operation combine \
    --input_dir  datasets/snemi3d/clahe/ \
    --target_dir  datasets/snemi3d/label3/ \
    --output_dir datasets/snemi3d/combined_1/


for i in `seq 2 3`;
do
	cp -rf datasets/snemi3d/combined_1/ datasets/snemi3d/combined_$i/
done

for i in `seq 1 3`;
do
	python tools/split.py \
  	--dir datasets/snemi3d/combined_$i
done

### Train
counter=0

# type image --> hinge loss
for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet    \
	--output_dir temp/survey_loss/snemi3d/train/$counter \
	--input_dir datasets/snemi3d/combined_$i/train \
	--loss hinge \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/snemi3d/train/$counter \
	--input_dir datasets/snemi3d/combined_$i/train \
	--loss square \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/snemi3d/train/$counter \
	--input_dir datasets/snemi3d/combined_$i/train \
	--loss softmax \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/snemi3d/train/$counter \
	--input_dir datasets/snemi3d/combined_$i/train \
	--loss approx \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/snemi3d/train/$counter \
	--input_dir datasets/snemi3d/combined_$i/train \
	--loss dice \
	--display_freq 500  --max_epochs 2000
done

for i in `seq 1 3`;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet   \
	--output_dir temp/survey_loss/snemi3d/train/$counter \
	--input_dir datasets/snemi3d/combined_$i/train \
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
	python translate.py --mode test \
	--checkpoint temp/survey_loss/snemi3d/train/$counter \
	--output_dir temp/survey_loss/snemi3d/test/$counter \
	--input_dir datasets/snemi3d/combined_$i/val \
    --image_width 1024  --image_height 1024
	bash tools/evaluate.sh temp/survey_loss/snemi3d/test/$counter synapses
	bash tools/evaluate.sh temp/survey_loss/snemi3d/test/$counter mitochondria
	bash tools/evaluate.sh temp/survey_loss/snemi3d/test/$counter membranes
done
done










