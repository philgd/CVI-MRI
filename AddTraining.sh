#! /bin/bash

prompt_user=false
#sleep $1"h"

## Function for user check
function User_Check {
	if [ "$prompt_user" = true ]; then
		fslview "${@:2}"
		echo "Do you wish to continue?"
		select yn in "Yes" "No"; do
		    case $yn in
		        Yes ) break;;
		        No ) echo $1; exit;;
		    esac
		done
	else
		echo "Finished: " $1
	fi
}

# Input files
out_prefix=$1
td_dir=$(pwd)/TrainingData
swi=$td_dir/$out_prefix'_SWI.nii.gz'
qsm=$td_dir/$out_prefix'_QSM.nii.gz'
vein=$td_dir/$out_prefix'_Vein.nii.gz'
mask=$td_dir/$out_prefix'_Mask.nii.gz'
tf_dir=$(pwd)/Transforms
std_l=$tf_dir/$out_prefix'_ToStd.mat'
std_nl=$tf_dir/$out_prefix'_ToStd.nii.gz'

# Prior dir
out_dir=$(pwd)/Priors

# Atlas
std_brain=$FSLDIR/data/standard/MNI152_T1_0.5mm.nii.gz
#std_mask=$FSLDIR/data/standard/MNI152_T1_0.5mm_brain_mask.nii.gz

# Output
out_vein_l=$out_dir/$out_prefix'_Vein_Std_L.nii.gz'
out_vein_nl=$out_dir/$out_prefix'_Vein_Std_NL.nii.gz'
out_sub_nl=$tf_dir/$out_prefix'_ToSub.nii.gz'
out_sub_l=$tf_dir/$out_prefix'_ToSub.mat'

# Temp dir
temp_dir=$(pwd)/Temp_$out_prefix
mkdir $temp_dir
cd $temp_dir

# Temp files
temp_A2S_L=$out_prefix'_MNI_to_SWI.mat'
temp_S2A_L=$out_prefix'_SWI_to_MNI.mat'

temp_A2S_NL=$out_prefix'_MNI_to_SWI.nii.gz'
temp_S2A_NL=$out_prefix'_SWI_to_MNI.nii.gz'

temp_SinA_L=$out_prefix'_SWI_in_MNI_L.nii.gz'
temp_AinS_L=$out_prefix'_MNI_in_SWI_L.nii.gz'

temp_AinS_NL=$out_prefix'_MNI_in_SWI_NL.nii.gz'
temp_SinA_NL=$out_prefix'_SWI_in_MNI_NL.nii.gz'

temp_vein=$out_prefix'_Vein_GEOM.nii.gz'

### Linear transform ##

# Check alignment
flirt -ref $std_brain -in $swi -out $temp_SinA_L -applyxfm -init $std_l
User_Check "Linear SWI to MNI" $temp_SinA_L $std_brain

# Invert linear transform
convert_xfm -omat $out_sub_l -inverse $std_l

# Check alignment
flirt -ref $swi -in $std_brain -out $temp_AinS_L -applyxfm -init $out_sub_l
User_Check "Linear MNI to SWI" $swi $temp_AinS_L

# Output Veins (fslcpgeom incase of stripping whilst tracing)
cp $vein $temp_vein
fslcpgeom $mask $temp_vein
flirt -ref $std_brain -in $temp_vein -out $out_vein_l -applyxfm -init $std_l

### Non-Linear transform ###

# Check alignment (SWI to MNI)
applywarp --ref=$std_brain --in=$swi --out=$temp_SinA_NL --warp=$std_nl
User_Check "Non-Linear SWI to MNI" $std_brain $temp_SinA_NL
 
# Invert non-linear transform 
invwarp -r $swi -o $out_sub_nl -w $std_nl

# Check alignment (MNI to SWI)
applywarp --ref=$swi --in=$std_brain --out=$temp_AinS_NL --warp=$out_sub_nl
User_Check "Non-Linear MNI to SWI" $swi $temp_AinS_NL

# Output Veins (fslcpgeom incase of stripping whilst tracing)
cp $vein $temp_vein
fslcpgeom $mask $temp_vein
applywarp --ref=$std_brain --in=$temp_vein --out=$out_vein_nl --warp=$std_nl

cd ..
