#!/usr/bin/env bash

### Prepare data
python tools/process.py \
    --operation combine \
    --input_dir  datasets/snemi3d/clahe/ \
    --target_dir  datasets/snemi3d/label3/ \
    --output_dir datasets/snemi3d/clahe2label3/

python tools/split.py \
    --dir datasets/snemi3d/clahe2label3/

### Train
python translate.py    --mode train \
	--network resnet \
	--output_dir temp/default/SNEMI3D/train \
	--input_dir datasets/snemi3d/clahe2label3/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000

### Test
python translate.py   --mode test \
	--checkpoint temp/default/SNEMI3D/train \
	--output_dir temp/default/SNEMI3D/test \
	--input_dir datasets/snemi3d/clahe2label3/val \
    --image_width 1024  --image_height 1024

### Evaluate
bash tools/evaluate.sh temp/default/SNEMI3D/test synapses
bash tools/evaluate.sh temp/default/SNEMI3D/test mitochondria
bash tools/evaluate.sh temp/default/SNEMI3D/test membranes

