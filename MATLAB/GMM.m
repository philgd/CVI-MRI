function [ gmmSwi, gmmQsm ] = GMM( mask, swi, qsm)

% Masks are eroded to fit components without surface artefacts and
% non-brain voxels. Posterior is then calculated for all surface voxels.

% For debug
verbose = false;

% high pass filter swi
hpSwi = swi-imfilter(swi+(1-mask).*mean(swi(mask(:))),fspecial3('gaussian',9));
%hpSwi = swi-convn(swi,fspecial3('gaussian',8),'same');

% swi seed and mask
trainingMask = imerode(mask,ball(2))==1;
seed = 1+(qsm(trainingMask(:))>0.05);

% fit swi gmm and calculate posterior
if verbose
    disp('Fit SWI')
    swiGm = fitgmdist(hpSwi(trainingMask),2,'Start',seed,'Options',statset('Display','iter'));
else
    swiGm = fitgmdist(hpSwi(trainingMask),2,'Start',seed); %#ok<UNRCH>
end
    
swiP = posterior(swiGm,hpSwi(mask(:)==1));
swiP = swiP(:,2);

% qsm seed and mask excluding more surface (could improve using STI mask)
% but still need to calculate posterior on dilated mask
trainingMaskQSM = imerode(trainingMask,ball(4))==1;
seed = 1+(qsm(trainingMaskQSM(:))>0.05);

% fit qsm gmm and calculate posterior
if verbose
    disp('Fit QSM')
    qsmGm = fitgmdist(qsm(trainingMaskQSM(:)),2,'Start',seed,'Options',statset('Display','iter','Maxiter',400));
else
    qsmGm = fitgmdist(qsm(trainingMaskQSM(:)),2,'Start',seed); %#ok<UNRCH>
end
qsmP = posterior(qsmGm,qsm(mask(:)==1));
qsmP = qsmP(:,2);

% Values are clamped below (above for SWI) 50th percentile to avoid
% false assignment when pr(V) decays to zero slower than pr(N)
swiRangeLimit = posterior(swiGm,prctile(hpSwi(mask(:)==1),50));
swiRangeMask = hpSwi(mask(:)==1)>=prctile(hpSwi(mask(:)==1),50);
swiP(swiRangeMask) = swiRangeLimit(2);

qsmRangeLimit = posterior(qsmGm,prctile(qsm(mask(:)==1),50));
qsmRangeMask = qsm(mask(:)==1)<=prctile(qsm(mask(:)==1),50);
qsmP(qsmRangeMask) = qsmRangeLimit(2);

% Reshape posterior to volume
gmmSwi = zeros(size(mask));
gmmQsm = zeros(size(mask));
gmmSwi(mask==1) = swiP;
gmmQsm(mask==1) = qsmP;
   
% Set limits of 0.01 and 0.99
gmmSwi = max(0.01,min(0.99,gmmSwi));
gmmQsm = max(0.01,min(0.99,gmmQsm));
end



