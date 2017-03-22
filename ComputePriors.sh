#! /bin/bash

## Function for user check
function User_Check {
	echo "Do you wish to continue?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) break;;
	        No ) echo $1; exit;;
	    esac
	done
}

# Directories
tr_dir=$(pwd)/TrainingData
pr_dir=$(pwd)/Priors
tf_dir=$(pwd)/Transforms
sc_dir=$(pwd)/MATLAB
base_dir=$(pwd)

# Atlas
std_brain=$FSLDIR/data/standard/MNI152_T1_0.5mm.nii.gz
#std_mask=$FSLDIR/data/standard/MNI152_T1_1mm_brain_mask.nii.gz

# Subjects (To only use linear interpolation where non-linear was unsuitable/failed/unavailable)
sub_array=(1  2  3  4  5  6  7  8  9  10)
tf_array=(NL  NL NL NL NL NL NL L  NL NL)

# Atlas
fre_all=$pr_dir/'All_Fre_Std.nii.gz'
fre_ll=$pr_dir/'All_Fre_Prior_Std.nii.gz'
swi_ll=$pr_dir/'All_SWI_Prior_Std.nii.gz'
qsm_ll=$pr_dir/'All_QSM_Prior_Std.nii.gz'

fslmaths $std_brain -mul 0 $fre_all
fslmaths $std_brain -mul 0 $fre_ll
fslmaths $std_brain -mul 0 $swi_ll
fslmaths $std_brain -mul 0 $qsm_ll

# Create frequency map as sum of all vein maps
for (( i=0; i<${#sub_array[@]}; i++ )); do
	sub=${sub_array[$i]}
	tf=${tf_array[$i]}
	fslmaths $fre_all -add $pr_dir/$sub'_Vein_Std_'$tf.nii.gz $fre_all
done
echo "Finished sum of all vein maps."

# Create subject-excluded frequency maps and calculate log-loss
for (( i=0; i<${#sub_array[@]}; i++ )); do
	
	out_prefix=${sub_array[$i]}
	tf=${tf_array[$i]}
	
	# Inputs
	swi=$tr_dir/$out_prefix'_SWI.nii.gz'
	qsm=$tr_dir/$out_prefix'_QSM.nii.gz'
	mask=$tr_dir/$out_prefix'_Mask.nii.gz'
	vein=$tr_dir/$out_prefix'_Vein.nii.gz'
	
	# Outputs
	fre_sub=$pr_dir/$out_prefix'_Fre_Sub.nii.gz'
	
	# Temp
	temp_dir=$base_dir/Temp_$out_prefix
	temp_fre_std=$temp_dir/$out_prefix'_Fre_Std.nii.gz'
	temp_fll=$temp_dir/$out_prefix'_Fre_Temp.nii.gz'
	temp_sll=$temp_dir/$out_prefix'_SWI_Temp.nii.gz'
	temp_qll=$temp_dir/$out_prefix'_QSM_Temp.nii.gz'	
	
	# Create frequency map without subject information
	cd $temp_dir
	fslmaths $fre_all -sub $pr_dir/$sub'_Vein_Std_'$tf.nii.gz -div $((${#sub_array[@]}-1)) $temp_fre_std

	# Interpolate to subject coordinates
	if [ $tf == "L" ]; then
		sub_l=$tf_dir/$out_prefix'_ToSub.mat'
		flirt -ref $swi -in $temp_fre_std -out $fre_sub -applyxfm -init $sub_l
	else
		sub_nl=$tf_dir/$out_prefix'_ToSub.nii.gz'
		applywarp --ref=$swi --in=$temp_fre_std --out=$fre_sub --warp=$sub_nl
	fi
	
	# Get Log-Loss for frequency map, swi and qsm
	cd $sc_dir
	matlab -nodesktop -nosplash -nodisplay -r "Prior('$mask','$swi','$qsm','$fre_sub','$vein','$temp_sll','$temp_qll','$temp_fll'); quit;"
	
	# Interpolate Log-Loss to atlas coordinates
	cd $temp_dir
	if [ $tf == "L" ]; then
		std_l=$tf_dir/$out_prefix'_ToStd.mat'
		flirt -ref $std_brain -in $temp_fll -out $temp_fll -applyxfm -init $std_l
		flirt -ref $std_brain -in $temp_sll -out $temp_sll -applyxfm -init $std_l
		flirt -ref $std_brain -in $temp_qll -out $temp_qll -applyxfm -init $std_l
	else
		std_nl=$tf_dir/$out_prefix'_ToStd.nii.gz'
		applywarp --ref=$std_brain --in=$temp_fll --out=$temp_fll --warp=$std_nl
		applywarp --ref=$std_brain --in=$temp_sll --out=$temp_sll --warp=$std_nl
		applywarp --ref=$std_brain --in=$temp_qll --out=$temp_qll --warp=$std_nl
	fi
	fslmaths $fre_ll -add $temp_fll $fre_ll
	fslmaths $swi_ll -add $temp_sll $swi_ll
	fslmaths $qsm_ll -add $temp_qll $qsm_ll
	
	echo "Subject specific frequency maps " $(($i+1)) "/" ${#sub_array[@]}
done

# Subject specific priors for frequency, swi and qsm
for (( i=0; i<${#sub_array[@]}; i++ )); do
	
	out_prefix=${sub_array[$i]}
	tf=${tf_array[$i]}
	
	# Inputs
	swi=$tr_dir/$out_prefix'_SWI.nii.gz'
	
	temp_dir=$base_dir/Temp_$out_prefix
	temp_fll=$temp_dir/$out_prefix'_Fre_Temp.nii.gz'
	temp_sll=$temp_dir/$out_prefix'_SWI_Temp.nii.gz'
	temp_qll=$temp_dir/$out_prefix'_QSM_Temp.nii.gz'

	# Outputs	
	fll_sub=$pr_dir/$out_prefix'_Fre_Prior.nii.gz'
	sll_sub=$pr_dir/$out_prefix'_SWI_Prior.nii.gz'
	qll_sub=$pr_dir/$out_prefix'_QSM_Prior.nii.gz'	
	
	# Create log-loss maps without subject information
	cd $temp_dir
	fslmaths $fre_ll -sub $temp_fll -div $((${#sub_array}-1)) $temp_fll
	fslmaths $swi_ll -sub $temp_sll -div $((${#sub_array}-1)) $temp_sll
	fslmaths $qsm_ll -sub $temp_qll -div $((${#sub_array}-1)) $temp_qll

	# Interpolate subject specific Log-Loss maps to subject space
	if [ $tf == "L" ]; then
		sub_l=$tf_dir/$out_prefix'_ToSub.mat'
		
		flirt -ref $swi -in $temp_fll -out $fll_sub -applyxfm -init $sub_l
		flirt -ref $swi -in $temp_sll -out $sll_sub -applyxfm -init $sub_l
		flirt -ref $swi -in $temp_qll -out $qll_sub -applyxfm -init $sub_l
	else
		sub_nl=$tf_dir/$out_prefix'_ToSub.nii.gz'
		applywarp --ref=$swi --in=$temp_fll --out=$fll_sub --warp=$sub_nl
		applywarp --ref=$swi --in=$temp_sll --out=$sll_sub --warp=$sub_nl
		applywarp --ref=$swi --in=$temp_qll --out=$qll_sub --warp=$sub_nl
	fi
	echo "Subject specific priors " $(($i+1)) "/" ${#sub_array[@]}
done

# Normalise atlases
cd $pr_dir
fslmaths $fre_all -div ${#sub_array[@]} $fre_all
fslmaths $fre_ll -div ${#sub_array[@]} $fre_ll
fslmaths $swi_ll -div ${#sub_array[@]} $swi_ll
fslmaths $qsm_ll -div ${#sub_array[@]} $qsm_ll
