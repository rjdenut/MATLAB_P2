%% Reconstruct Raw Data - Spiral Sampled
clear all

%% 1. Prepare sampled data
%

addpath(genpath('~/Documents/MATLAB/mapVBVD_20150918'))
%
date = '20160714'; %date of scan
ADCshifts = [2:2:10];
ADCshift = 4;
ADCshift_index = find(ADCshifts==ADCshift);
scanIndex = ADCshift_index;

% choose data from a specific channel
% simplify by just using the first full sample of k-space
nTRs = 48; %48 is 'fully sampled'
channel = 1;
MIDstart = 576;
FIDstart = 17955;
% Read data from file
filename20160714 = (['~/Documents/DPhil/data/TWIX/',date,'/meas_MID',num2str(MIDstart+scanIndex),'_JA_IR_bSSFP_fp_neg',num2str(ADCshift),'ADC_FID',num2str(FIDstart+scanIndex)]);

twix_obj20160714 = mapVBVD(filename20160714);
twix_obj20160714.image.flagRemoveOS = 1; %remove factor of 2 oversampling along each trajectory
% squeeze the data to remove unnecessary dimensions
image_data20160714 = twix_obj20160714.image{''};
% image_data(400:end,:,:) = 0;
TRrange = (3*nTRs)+1:((3*nTRs)+nTRs);
spiralkspacedata = double(squeeze(image_data20160714(:,channel,TRrange)));

%% 2. Prepare intended k-space location information
%
addpath(genpath('~/Documents/MATLAB/gridding'))
addpath(genpath('~/Documents/MATLAB/DPhil'))
            
% read in POET simulation gradients
addpath(genpath('~/Documents/MATLAB/read_dsv'));
% x-axis gradient
dsvGRX_filename = '~/Documents/DPhil/dsvfiles/DspData_GRX.dsv';
dsvGRX = Read_dsv(dsvGRX_filename);
%y-gradient
dsvGRY_filename = '~/Documents/DPhil/dsvfiles/DspData_GRY.dsv';
dsvGRY = Read_dsv(dsvGRY_filename);
gamma = 4258;
T = 0.00001;

nTotalPts =  567;
nSamplePts = 448;

% convert gradient data to k-space trajectory
GRX = dsv2timecourse(dsvGRX);
GRY = dsv2timecourse(dsvGRY);
spiralkspacelocations_x = cumsum(dsv2timecourse(dsvGRX))*gamma*T;
spiralkspacelocations_y = cumsum(dsv2timecourse(dsvGRY))*gamma*T;
TR = 1000;
%


%
spiralkspacelocations_x(1:1839)=[];
spiralkspacelocations_y(1:1839)=[];

%
for n = 1:nTRs
spiralkspacelocations_x(1+nSamplePts+((n-1)*TR):1000+((n-1)*TR))=0;
spiralkspacelocations_y(1+nSamplePts+((n-1)*TR):1000+((n-1)*TR))=0;

end

%
spiralkspacelocations_x(spiralkspacelocations_x==0)=[];
spiralkspacelocations_y(spiralkspacelocations_y==0)=[];

spiralkspacelocations_x(1+nTRs*nSamplePts:end) = [];
spiralkspacelocations_y(1+nTRs*nSamplePts:end) = [];

spiralkspacelocations_x = (0.00000001)*spiralkspacelocations_x;
spiralkspacelocations_y = (0.00000001)*spiralkspacelocations_y;

%% 3. Grid the kspace data


% determine the density compensation function (DCF)
%   find vertices V and cells C of voronoi diagram
[V,C] = voronoin([spiralkspacelocations_x',spiralkspacelocations_y']);
xVertices = V(:,1);
yVertices = V(:,2);
%   find areas of each cell (DCF)
%for nCell = 1:size(C,1)
%   DCF(nCell) = polyarea(xVertices(C{nCell}),yVertices(C{nCell}));
%end

DCF = [];
for j = 1:length([spiralkspacelocations_x',spiralkspacelocations_y'])
    x = V(C{j},1);
    y = V(C{j},2);
    lxy = length(x);
    A = abs(sum(0.5*(x([2:lxy 1])-x(:)).* ...
        (y([2:lxy 1])+y(:))));
    DCF = [DCF A];
end
%removed DCF
DCF(repmat([ones(440,1);zeros(8,1)],48,1)==0)=0;
DCF = DCF(:)/max(DCF);
% gridding settings
gridsize = 512; %dimension of resulting reconstructed image
kwidth = 1.5; %kernal width
overgridfactor = 2;
[dat]  = gridkb(spiralkspacelocations,spiralkspacedata,DCF',gridsize,kwidth,overgridfactor);
%% 4. Plot Results
figure('Name',['Grid Recon. ADC shift:',num2str(ADCshift)])
subplot(2,2,1)
plot(spiralkspacelocations)
title 'spiral k-space locations'
subplot(2,2,2)
plot(spiralkspacedata,'.')
title 'spiral k-space data'
subplot(2,2,3)
plot(dat,'.')
subplot(2,2,4)
im = fftshift(fft2(fftshift(dat)));
im = abs(im);
imagesc(im);
axis square;
title (['Reconstruction'])

