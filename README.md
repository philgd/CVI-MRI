# CVI-MRI
Composite vein imaging for susceptibility-based magnetic resonance imaging.

A set of tools for generating composite vein images from SWI and QSM images.

Details of the method are available here:

*Phillip G.D. Ward, Nicholas J. Ferris, Parnesh Raniga, David L. Dowe, Amanda C.L. Ng, David G. Barnes, Gary F. Egan, Combining images and anatomical knowledge to improve automated vein segmentation in MRI, NeuroImage, Volume 165, 15 January 2018, Pages 294-305, ISSN 1053-8119, https://doi.org/10.1016/j.neuroimage.2017.10.049.
(https://www.sciencedirect.com/science/article/pii/S1053811917308765)*

Training data for priors and atlas are available at: 

*Phillip G.D. Ward, Nicholas J. Ferris, Parnesh Raniga, David L. Dowe, Amanda C.L. Ng, David G. Barnes, Gary F. Egan, Combined magnetic susceptibility contrast for vein segmentation from a single MRI acquisition using a vein frequency atlas (vein priors and frequency atlas). figshare. 2017. https://doi.org/10.4225/03/57B6AB25DDBDC*

Please cite both the methods paper and data repository when using this code.

## Requirements

Software:
  1. FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)
  2. MatLab (https://www.mathworks.com/products/matlab.html)

## Instructions for use

1. Create a working directory (e.g. mkdir ~/CVI-MRI/)
2. Clone git repository into working directory (git clone https://github.com/philgd/CVI-MRI.git)
3. Download TrainingData.tar.gz and Transforms.tar.gz from https://doi.org/10.4225/03/57B6AB25DDBDC
4. Extract the two .tar.gz files into the working directory.
5. Run main script (./RunAll.sh)

Output data includes the template priors and the CV images. CV images can be found in the 'Output/' directory. Template priors can be found in 'Priors/' directory.

### Optional: Add new datasets
  
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

### Code included from other projects:

1. Nifti library for MATLAB (https://au.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
2. fspecial3 (https://au.mathworks.com/matlabcentral/fileexchange/21130-dti-and-fiber-tracking/content/fspecial3.m)
