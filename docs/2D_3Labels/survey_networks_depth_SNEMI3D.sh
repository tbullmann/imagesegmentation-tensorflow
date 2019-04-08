#!/usr/bin/env bash

#### Prepare data
#python tools/process.py \
#    --operation combine \
#    --input_dir  datasets/snemi3d/input/ \
#    --target_dir  datasets/snemi3d/label3/ \
#    --output_dir datasets/snemi3d/input2label3/

#python tools/split.py \
#    --dir datasets/snemi3d/input2label3/

### Train

counter=0

for n_depth in 4 5 6 7 8;
do
	((counter++))
	python translate.py    --mode train \
	--network unet  --u_depth $n_depth  \
	--output_dir temp/publication3/how_deep/train/$counter \
	--input_dir datasets/snemi3d/input2label3/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000
done

for n_dense_blocks in 1 2 3 4 5;
do
	((counter++))
	python translate.py    --mode train \
	--network densenet  --n_dense_blocks $n_dense_blocks  \
	--output_dir temp/publication3/how_deep/train/$counter \
	--input_dir datasets/snemi3d/input2label3/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000
done

for n_highway_units in 4 6 9 12 16;
do
	((counter++))
	python translate.py    --mode train \
	--network highwaynet  --n_highway_units $n_highway_units  \
	--output_dir temp/publication3/how_deep/train/$counter \
	--input_dir datasets/snemi3d/input2label3/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000
done

for n_res_blocks in 4 6 9 12 16;
do
	((counter++))
	python translate.py    --mode train \
	--network resnet  --n_res_blocks $n_res_blocks \
	--output_dir temp/publication3/how_deep/train/$counter \
	--input_dir datasets/snemi3d/input2label3/train \
	--loss square  --batch_size 8  \
	--display_freq 2000  --max_epochs 2000
done


### Test

for i in `seq 1 $counter`;
do
	python translate.py   --mode test \
	--checkpoint temp/publication3/how_deep/train/$i \
	--output_dir temp/publication3/how_deep/test/$i \
	--input_dir datasets/snemi3d/input2label3/val \
    --image_width 1024  --image_height 1024
done

#### Evaluate
#
#for i in `seq 1 $counter`;
#do
#	bash tools/evaluate.sh temp/publication3/how_deep/test/$i synapses
#	bash tools/evaluate.sh temp/publication3/how_deep/test/$i mitochondria
#	bash tools/evaluate.sh temp/publication3/how_deep/test/$i membranes
#done
#
#
#### Accumulate results
#
## Using the Python script to link evaluation results in CSV fules with parameters from JSON files
#python publication2/generators_and_depth/aggregate.py
#

# NOTE: Information about generator type / depath can be obtained by order of files only
#sed -n 1p temp/publication3/how_deep/test/1/evaluation/membranes.csv > temp/publication3/how_deep/evaluation-membranes.csv
#sed -n 1p temp/publication3/how_deep/test/1/evaluation/mitochondria.csv > temp/publication3/how_deep/evaluation-mitochondria.csv
#sed -n 1p temp/publication3/how_deep/test/1/evaluation/synapses.csv > temp/publication3/how_deep/evaluation-synapses.csv
#for i in `seq 1 $counter`;
#do
#	sed 1d temp/publication3/how_deep/test/$i/evaluation/membranes.csv >> temp/publication3/how_deep/evaluation-membranes.csv
#	sed 1d temp/publication3/how_deep/test/$i/evaluation/mitochondria.csv >> temp/publication3/how_deep/evaluation-mitochondria.csv
#	sed 1d temp/publication3/how_deep/test/$i/evaluation/synapses.csv >> temp/publication3/how_deep/evaluation-synapses.csv
#done




