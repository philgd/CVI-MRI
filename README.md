# CVI-MRI
Composite vein imaging for susceptibility-based magnetic resonance imaging.

A set of tools for generating composite vein images from SWI and QSM images.

Training data for priors and atlas are available at: 

*Ward, Phil; Ferris, Nicholas J.; Raniga, Parnesh; Ng, Amanda C. L.; Dowe, David L.; Barnes, David; F. Egan, Gary (2016): Combined magnetic susceptibility contrast for vein segmentation from a single MRI acquisition using a vein frequency atlas (vein priors and frequency atlas).. figshare. https://doi.org/10.4225/03/57B6AB25DDBDC*

A publication detailing the methods used is currently in draft, and a preliminary report has been accepted for presentation at the 2017 Annual Meeting of the International Society for Magnetic Resonance in Medicine (ISMRM), abstract # 1450.

## Requirements

Software:
  1. FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)
  2. MatLab (https://www.mathworks.com/products/matlab.html)

Code included from other projects:
  1. Nifti library for MATLAB (https://au.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
  2. fspecial3 (https://au.mathworks.com/matlabcentral/fileexchange/21130-dti-and-fiber-tracking/content/fspecial3.m)

## Instructions for use

1. Get code and data
  1. Clone git repository into working directory
  1. Download TrainingData.tar.gz and Transforms.tar.gz from https://doi.org/10.4225/03/57B6AB25DDBDC
  2. Extract both archives into working directory
  
2. Prepare data:
  1. Execute ./AddTraining.sh subject-id
  2. Repeat for each subject-id (1-10 in provided data)
  
3. Calculate priors:
  1. Execute ./ComputePriors.sh
  
4. Add new datasets (optional)
  1. Prefix data and transforms with subject-id
  2. Place input data in TrainingData folder (SWI, QSM, Vein, Mask)
  3. Place linear (and/or non-linear) transforms into Transform folder
  4. Add subject ID to line 31 in ComputePriors.sh
  5. Specfic transform as linear or non-linear to line 32 in ComputePriors.sh

### Main functions

1. AddTraining.sh
  - To prepare subjects for training
2. ComputePriors.sh
  - To calculate atlas and weights from training data
