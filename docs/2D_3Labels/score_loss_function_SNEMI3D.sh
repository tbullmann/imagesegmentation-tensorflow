#!/usr/bin/env bash

### Evaluate
counter=0
for j in `seq 1 6`;
do
for i in `seq 1 3`;
do
	((counter++))
	bash tools/evaluate.sh temp/survey_loss/snemi3d/test/$counter synapses
	bash tools/evaluate.sh temp/survey_loss/snemi3d/test/$counter mitochondria
	bash tools/evaluate.sh temp/survey_loss/snemi3d/test/$counter membranes
done
done
