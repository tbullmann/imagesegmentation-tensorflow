#!/usr/bin/env bash

counter=20

#### Evaluate
for i in `seq 1 $counter`;
do
	bash tools/evaluate.sh temp/survey_depth/snemi3d/test/$i synapses
	bash tools/evaluate.sh temp/survey_depth/snemi3d/test/$i mitochondria
	bash tools/evaluate.sh temp/survey_depth/snemi3d/test/$i membranes
done
