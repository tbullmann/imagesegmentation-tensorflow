#!/usr/bin/env bash

### Evaluate
for i in `seq 1 4`;
do
	bash tools/evaluate.sh temp/survey_less_annotation/snemi3d/test/$i synapses
	bash tools/evaluate.sh temp/survey_less_annotation/snemi3d/test/$i mitochondria
	bash tools/evaluate.sh temp/survey_less_annotation/snemi3d/test/$i membranes
done
