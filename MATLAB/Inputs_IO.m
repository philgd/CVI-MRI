function [ gmmSwi, gmmQsm, freMap, hdrInfo ] = Inputs_IO( maskFile, swiFile, qsmFile, freFile )
%SHMRF_GMM_IO Summary of this function goes here
%   Detailed explanation goes here

addpath(genpath('shared-src/'))

mask = load_untouch_nii(maskFile);
swi = load_untouch_nii(swiFile);
qsm = load_untouch_nii(qsmFile);
fre = load_untouch_nii(freFile);

hdrInfo = swi.hdr;
hdrInfo.dime.datatype = 64;
hdrInfo.dime.bitpix = 64;

mask = single(mask.img)>0;%imdilate(single(mask.img),ball(3))>0;
swi = single(swi.img);
qsm = single(qsm.img);
fre = single(fre.img);

[ gmmSwi, gmmQsm ] = GMM( mask, swi, qsm);
freMap = min(0.99,max(0.01,fre));


end

