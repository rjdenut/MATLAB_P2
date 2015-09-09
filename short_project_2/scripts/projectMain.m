%% ONBI short project 2 - Magnetic Resonance Fingerprinting
% Author: Jack Allen
% Supervisor: Prof. Peter Jezzard
% Start Date: 13th July 2015
%% 1. Initialise
clear all
close all

workingdir = '/home/fs0/jallen/Documents/MATLAB/short_project_2';
addpath(genpath(workingdir));

addpath(genpath('/Applications/fsl/'))
addpath(genpath('/usr/local/fsl/bin'))

addpath(genpath('/opt/fmrib/fsl/etc/matlab'))

%% 2. Read in the images
%which phantom is the data from? ('sphereD170' or 'Jack'?)
phantomName = 'Jack';

% Choose the offset list to use. List 2 is the original 'random' list of
% offsets. Lists 3:8 are variations on List2, as described below.
%
% 3: 1st TR offset = 10000
% 4: flip Angles = 90 and 180
% 5: TE offset = 20
% 6: TR offset = 1500, TE offset = 20, FA1 = 90
% 7: TR offset = 1500, TE offset = 20
% 8: TR offset = 15000

for offsetListNum = 2:8
[TEImageInfo, TIImageInfo, FPImageInfo(:,offsetListNum), TEimages, TIimages, FPimages(:,:,:,:,offsetListNum), TE, TI] = readData(phantomName, offsetListNum, workingdir);
end
%% 3. Select a ROI and a sample of the background, to calculate SNR
[SNR signal background] = calcSNR(TEimages,TE,'showFigure');

%% 4. find signals at sample pixels
run('compartmentSignals.m')

%% 5. plot positions of sample pixels for TE and TR images
plotNumCompartments = 6;
sliceNumber = 1;
run('plotSamplePixels_TE_TR.m')
%%
run('visualiseImages.m')

%% fit curves to calculate T1 and T2

[compartmentT1s, compartmentT2s, T2curves, T1curves, fittedCurve, goodness, output] = fitEvolutionCurves(TEimages, TIimages, TE(2:end)', TI(2:end), 'compartments', compartmentCenters);

%% 6. read in the list of timing offsets used for acquisition
run('readFingerprintOffsetList.m')
save fingerprintLists.mat fingerprintLists

%% 7. simulate magnetisation evolution
%check bloch simulation by using properties of the phantom

% sphereD170 properties
T1 = 282.5;
T2 = 214.1;

freqOffset = 0;
nSlices = 2;
[M, Mxy,flipAngles, t0s] = SimBloch(T1, T2, fingerprintLists(:,:,offsetListNum), 'showPlot', freqOffset, nSlices);

%% 8. check signal simulation by plotting positions of sample pixels for the fingerprinting images
compartmentCentersList = 3;
run('plotSamplePixels.m')

% plot comparison of simulation with sampled pixels
run('plotSim.m')

%% 9. create dictionary
load fingerprintLists.mat



switch phantomName
    case 'sphereD170'
        
        disp('Phantom: sphereD170')
        clear dictionaryParams
        
        dictionaryParams(1,:) = 200:10:300 ; % T1
        dictionaryParams(2,:) = 200:10:300 ; % T2
        dictionaryParams(3,:) = 0.7:0.06:1.3 ; % B1 fraction
        
    case 'Jack'
        
        disp('Phantom: Jack')
        clear dictionaryParams
        T1s = [30:20:260, 3050:20:3150];
        T2s = [10:10:120, 1770:10:1820];
        FAdevs = [0.7:0.05:1.3];
        dictionaryParams(1,1:numel(T1s)) = T1s;
        dictionaryParams(2,1:numel(T2s)) = T2s;
        dictionaryParams(3,1:numel(FAdevs)) = FAdevs;
        
end
nTimeCoursePts = size(data , 4)/2;
for offsetListNum = 4
    offsetListNum
[signalDictionary(:,:,:,:,offsetListNum)] = compileDictionary(fingerprintLists, offsetListNum, dictionaryParams, nTimeCoursePts, freqOffset, nSlices, background);
end

save([workingdir,'dictionary.mat'],'signalDictionary')

%% 10. check similarity and use dictionary to measure T1 and T2
run('matching.m')

%% plot and save the T1, T2 and FA deviation maps
for offsetListNum = 2:8
FA_fig = figure; imagesc(squeeze(matchedFAdevInd(:,:,offsetListNum)))
saveas(FA_fig, [workingdir,'/figures/matchedFAdevInd_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])
matlab2tikz([workingdir,'/Users/jallen/Documents/MATLAB/short_project_2/figures/matchedFAdevInd_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])

matchedT1_fig = figure; imagesc(matchedT1(:,:,offsetListNum))
saveas(matchedT1_fig, [workingdir,'/figures/matchedT1_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])
matlab2tikz([workingdir,'/figures/matchedT1_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])

matchedT2_fig = figure; imagesc(matchedT2(:,:,offsetListNum))
saveas(matchedT2_fig, [workingdir,'/figures/matchedT2_offsetList',num2str(offsetListNum),'_phantomName_',phantomName])
matlab2tikz([workingdir,'/figures/matchedT2_offsetlist',num2str(offsetListNum),'_phantomName_',phantomName])
end