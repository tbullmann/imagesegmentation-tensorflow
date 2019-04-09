#!/usr/bin/env bash

#!/usr/bin/env bash

### Prepare data
python tools/process.py \
    --operation combine \
    --input_dir  datasets/snemi3d/clahe/ \
    --target_dir  datasets/snemi3d/label3/ \
    --output_dir datasets/snemi3d/combined2_1/


for i in `seq 2 16`;
do
	cp -rf datasets/snemi3d/combined2_1/ datasets/snemi3d/combined2_$i/
done

for i in `seq 1 16`;
do
	fraction=$(echo "scale=2; $i / 20" | bc)
	python imagetranslation/tools/split.py --train_frac $fraction \
	--dir temp/publication/amount_ground_truth/datasets/combined$i
done


### Train
for i in `seq 1 16`;
do
	max_epochs=$(echo "4800/$i" | bc)
	python imagetranslation/translate.py  --model pix2pix  --mode train  --generator resnet \
	--output_dir temp/publication/amount_ground_truth/train/$i \
	--input_dir temp/publication/amount_ground_truth/datasets/combined$i/train \
    --flipud  --fliplr  --transpose \
	--which_direction AtoB  --Y_loss square \
	--display_freq 100  --max_epochs $max_epochs
done

### Test and evaluate
for i in `seq 1 16`;
do
	python imagetranslation/translate.py   --mode test \
	--checkpoint temp/publication/amount_ground_truth/train/$i \
	--input_dir temp/publication/amount_ground_truth/datasets/combined$i/val \
	--output_dir temp/publication/amount_ground_truth/test/$i \
	  --model pix2pix   --generator resnet \
	  --image_height 1024  --image_width 1024
	bash tools/evaluate.sh temp/publication/amount_ground_truth/test/$i synapses
	bash tools/evaluate.sh temp/publication/amount_ground_truth/test/$i mitochondria
	bash tools/evaluate.sh temp/publication/amount_ground_truth/test/$i membranes
done













