# CVI-MRI
Composite vein imaging for susceptibility-based magnetic resonance imaging.

A set of tools for generating composite vein images from SWI and QSM images.

Training data for priors and atlas are available at: Ward, Phil; Ferris, Nicholas J.; Raniga, Parnesh; Ng, Amanda C. L.; Dowe, David L.; Barnes, David; F. Egan, Gary (2016): Combined magnetic susceptibility contrast for vein segmentation from a single MRI acquisition using a vein frequency atlas (vein priors and frequency atlas).. figshare. https://doi.org/10.4225/03/57B6AB25DDBDC

A publication detailing the methods used is currently in draft, and a preliminary report has been accepted for presentation at the 2017 Annual Meeting of the International Society for Magnetic Resonance in Medicine (ISMRM), abstract # 1450.

Requirements:
  1. FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)
  2. MatLab (https://www.mathworks.com/products/matlab.html)

Included code from other projects:
  1. Nifti library for MATLAB (https://au.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
  2. fspecial3 (https://au.mathworks.com/matlabcentral/fileexchange/21130-dti-and-fiber-tracking/content/fspecial3.m)

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

Main functions:
1. AddTraining.sh:
  To prepare subjects for training
2. ComputerPriors.sh:
  To calculate atlas and weights from training data
