from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from collections import Counter

import os
import argparse
import glob
from sklearn.metrics.cluster import adjusted_rand_score
import pandas as pd
import numpy as np

from skimage.io import imread
from skimage.measure import label as regions
from scipy.sparse import csr_matrix


def label_segmentation_metrics(true_label, pred_label):
    """
    Implements semantic segmentation scores,  e.g. on true or false label.
    :param true_label, pred_label: corresponding boolean values, true for label, false for background
    :return: Jaccard, Dice, Conformity, adjusted_RAND
    """

    Jaccard = 0
    Dice = 0
    Conformity = 0
    adjusted_RAND = adjusted_rand_score(true_label.ravel(), pred_label.ravel())


    return Jaccard, Dice, Conformity, adjusted_RAND


def SNEMI3D_metrics(true_segm, pred_segm):
    """
    Implements instance segmentation scores from the SNEMI3D challenge, e.g. on separate, indexed objects.
    :param true_segm, pred_segm: corresponding integer values, one for each object, 0 for background
    :return: Jaccard, Dice, Conformity, adapted_RAND_error
    """

    n = true_segm.size
    overlap = Counter(zip(true_segm.ravel(), pred_segm.ravel()))
    data = list(overlap.values())     # csr_matrix needs a list not a dict_values object
    row_ind, col_ind = zip(*overlap.keys())

    p_ij = csr_matrix((data, (row_ind, col_ind)))

    a_i = np.array(p_ij[1:, :].sum(axis=1))
    b_j = np.array(p_ij[1:, 1:].sum(axis=0))
    p_i0 = p_ij[1:, 0]
    p_ij = p_ij[1:, 1:]

    sumA = (a_i * a_i).sum()
    sumB = (b_j * b_j).sum() + p_i0.sum()/n
    sumAB = p_ij.multiply(p_ij).sum() + p_i0.sum()/n

    RAND_index = 1 - (sumA + sumB - 2*sumAB) / (n ** 2)
    precision = sumAB / sumB
    recall = sumAB / sumA
    F_score = 2.0 * precision * recall / (precision + recall)
    adapted_RAND_error = 1.0 - F_score

    Jaccard = sumAB / (sumA + sumB - sumAB)  # [ = TP / (TP + FP + FN)  ]
    Dice = 2 * sumAB / (sumA + sumB)
    Conformity = (2 * Jaccard - 1) / Jaccard

    return Jaccard, Dice, Conformity, RAND_index, adapted_RAND_error


def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("--input", default=None, help="path/files for raw images (for plot)")
    parser.add_argument("--predicted", required=True, help="path/files for predicted labels")
    parser.add_argument("--true", required=True, help="path/files for true labels")
    parser.add_argument("--output", required=True, help="output path/files")
    parser.add_argument("--threshold", type=int, default=127, help="threshold for the predicted label")
    parser.add_argument("--channel", type=int, default=0, help="channel to be evaluated")
    parser.add_argument("--segment_by", type=int, default=0, help="border value for segmentation into regions")

    a = parser.parse_args()

    dst = []
    output_path = a.output

    def relpath(image_path):
        return os.path.relpath(image_path, os.path.split(output_path)[0])

    inp_paths = sorted(glob.glob(a.input)) if a.input else []
    pred_paths = sorted(glob.glob(a.predicted))
    true_paths = sorted(glob.glob(a.true))

    for index, (inp_path, pred_path, true_path) in enumerate(zip(inp_paths, pred_paths, true_paths)):

        print ('Evaluate prediction %s vs truth %s' % (pred_path, true_path))

        # load iamges, e.g. 0 = black = membrane, 1 = white = non-membrane
        # threshold with default 0.5, so that 1 = membrane/border and 0 is non-membrane/region
        true_label = imread(true_path)[:, :, a.channel] > a.threshold
        pred_label = imread(pred_path)[:, :, a.channel] > a.threshold

        # scores on semantic segmentation
        semantic_Jaccard, semantic_Dice, semantic_Conformity, semantic_RAND = label_segmentation_metrics(true_label, pred_label)
        print("semantic: Jaccard = %1.3f, Dice =%1.3f, conformity = %1.3f, RAND =%1.3f\n" % (semantic_Jaccard, semantic_Dice, semantic_Conformity, semantic_RAND))

        # scores on instance segmentation
        true_segm = regions(true_label, background=a.segment_by)
        pred_segm = regions(pred_label, background=a.segment_by)
        instance_Jaccard, instance_Dice, instance_Conformity, instance_RAND, _ = SNEMI3D_metrics(true_segm, pred_segm)
        print("instance: Jaccard = %1.3f, Dice = %1.3f, Conformity = %1.3f, RAND = %1.3f\n" % (instance_Jaccard, instance_Dice, instance_Conformity, instance_RAND))

        dst.append([relpath(pred_path), relpath(true_path), semantic_Jaccard, semantic_Dice, semantic_Conformity, semantic_RAND, instance_Jaccard, instance_Dice, instance_Conformity, instance_RAND])

    dst = pd.DataFrame(dst,
                       columns=['pred_path', 'true_path', 'semantic_Jaccard', 'semantic_Dice', 'semantic_conformity', 'semantic_adapted_RAND', 'instance_Jaccard', 'instance_Dice', 'instance_conformity', 'instance_RAND',  ])
    dst['sample'] = dst.index
    dst.to_csv(output_path, index=False)

    print ("Saved to %s" % output_path)


main()
