function CVI( maskFile, swiFile, qsmFile, freFile, llSFile, llQFile, llFFile, cvFile )
%CVI (Composite Vein Image) Combines three inputs with log-loss weightings.
%   Using a mask all three inputs (swi, qsm and atlas) and a three log-loss maps
%   are combined to form a single composite image

addpath(genpath('shared-src/'))

mask = load_untouch_nii(maskFile);
mask = single(mask.img)>0;

[ gmmSwi, gmmQsm, freMap, hdrInfo ] = Inputs_IO( maskFile, swiFile, qsmFile, freFile);

llSVol = load_untouch_nii(llSFile);
llQVol = load_untouch_nii(llQFile); 
llFVol = load_untouch_nii(llFFile); 

llSVol = single(llSVol.img);
llQVol = single(llQVol.img);
llFVol = single(llFVol.img);

cvVol = gmmSwi.*llSVol + gmmQsm.*llQVol + freMap.*llFVol;
cvVol = cvVol./(llSVol+llQVol+llFVol);

cvNii = make_nii(cvVol.*mask);
cvNii.hdr = hdrInfo;
save_nii(cvNii,cvFile);

end
