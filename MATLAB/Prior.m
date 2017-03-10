function Prior( maskFile, swiFile, qsmFile, freFile, veinFile, llSFile, llQFile, llFFile )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
addpath(genpath('shared-src/'))

mask = load_untouch_nii(maskFile);
vein = load_untouch_nii(veinFile);

mask = single(mask.img)>0;%imdilate(single(mask.img),ball(3))>0;
vein = single(vein.img)>0;

[ gmmSwi, gmmQsm, freMap, hdrInfo ] = Inputs_IO( maskFile, swiFile, qsmFile, freFile);

veinWeights = 0.8*vein + 0.1;
lossSwiVol = (1-gmmSwi).*veinWeights + gmmSwi.*(1-veinWeights);
lossQsmVol = (1-gmmQsm).*veinWeights + gmmQsm.*(1-veinWeights);
lossFreVol = (1-freMap).*veinWeights + freMap.*(1-veinWeights);

llSwiVol = -log(lossSwiVol);
llQsmVol = -log(lossQsmVol);
llFreVol = -log(lossFreVol);

llSwiNii = make_nii(llSwiVol);
llQsmNii = make_nii(llQsmVol);
llFreNii = make_nii(llFreVol);
llSwiNii.hdr = hdrInfo;
llQsmNii.hdr = hdrInfo;
llFreNii.hdr = hdrInfo;

save_nii(llSwiNii,llSFile);
save_nii(llQsmNii,llQFile);
save_nii(llFreNii,llFFile);

end
