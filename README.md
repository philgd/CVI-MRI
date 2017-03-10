# CVI-MRI
Composite vein imaging for susceptibility-based magnetic resonance imaging.

Requirements:
  1. FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)
  2. MatLab (https://www.mathworks.com/products/matlab.html)

Included code from other projects:
  1. Nifti library for MATLAB (https://au.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
  2. fspecial3 (https://au.mathworks.com/matlabcentral/fileexchange/21130-dti-and-fiber-tracking/content/fspecial3.m)

AddTraining.sh:
  To prepare subjects for training

ComputerPriors.sh:
  To calculate atlas and weights from training data

Instructions:
  Arrange data
    1. Prefix data and transforms with subject ID
    2. Place input data in TrainingData folder (SWI, QSM, Vein, Mask)
    3. Place linear (and/or non-linear) transforms into Transform folder
  Prepare data
    1. Execute ./AddTraining.sh subject-id
  Calculate priors
    1. Add subject ID to ComputePriors on line 31
    2. Add transform as linear or non-linear on line 32
    3. Execute ./ComputePriors.sh
