function [ gmmSwi, gmmQsm ] = GMM( mask, swi, qsm)

% high pass filter swi
hpSwi = swi-imfilter(swi+(1-mask).*mean(swi(mask(:))),fspecial3('gaussian',9));
%hpSwi = swi-convn(swi,fspecial3('gaussian',8),'same');

% qsm seed
trainingMask = imerode(mask(:),ball(2))==1;
seed = 1+(qsm(trainingMask)>0.05);

% fit swi gmm and calculate posterior
swiGm = fitgmdist(hpSwi(trainingMask),2,'Start',seed);
swiP = posterior(swiGm,hpSwi(mask(:)==1));
swiP = swiP(:,2);

% fit qsm gmm and calculate posterior
qsmGm = fitgmdist(qsm(trainingMask),2,'Start',seed);
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



