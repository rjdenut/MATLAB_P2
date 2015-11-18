%% ONBI short project 2 - Magnetic Resonance Fingerprinting
% Author: Jack Allen
% Supervisor: Prof. Peter Jezzard
% Start Date: 13th July 2015
%% 1. Initialise

%Are you working on jalapeno00 or locally?
% workingdir = '/home/fs0/jallen/Documents/MATLAB/short_project_2';
workingdir = '/Users/jallen/Documents/MATLAB/short_project_2';
addpath(genpath(workingdir)); % sometimes causes MATLAB to freeze

savingdir = '/Users/jallen/Documents/short_project_2';
addpath(genpath(savingdir));

% If working on jalapeno00, uncomment the following lines:
% addpath(genpath('/Applications/fsl/'))
% addpath(genpath('/usr/local/fsl/bin'))
% addpath(genpath('/opt/fmrib/fsl/etc/matlab'))
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
    [TEImageInfo, TIImageInfo, ~, TEimages, TIimages, fullFPimages(:,:,:,:,offsetListNum), TE, TI] = readData(phantomName, offsetListNum, [savingdir,'/Data/'], savingdir );
end
%%
% Load the data
loadData
[SNR,bgStd] = calcSNR(TEimages,TE,[40 2 7 7], [24 18 7 7],1);

%% 4. find signals at sample pixels
compartmentCenters = setCompartmentCenters(phantomName);
plotCompartmentCenterTCs(compartmentCenters,TEimages, TIimages, TE, TI)

%% 5. plot positions of sample pixels for TE and TR images
plotNumCompartments = 6;
sliceNumber = 2;
%%
plotSamplePixels_TE_TR
%%
visualiseImages(FPimages)

%% fit curves to calculate T1 and T2
ROI = 'fullPhantom';
[compartmentT1s, compartmentT2s, T2curves, T1curves, fittedCurve, goodness, output, F] = fitEvolutionCurves(phantomName,TEimages, TIimages, TE(2:end)', TI(2:end), ROI, compartmentCenters);

plotGoldStdT1T2

%% 6. read in the list of timing offsets used for acquisition
readFingerprintOffsetList

save([savingdir,'/MAT-files/fingerprintLists.mat'], 'fingerprintLists')

%% 7. simulate magnetisation evolution
%check bloch simulation by using properties of the phantom
load('fingerprintLists.mat')
% sphereD170 properties
T1 = 282.3;
T2 = 214.8;
%T1 = 600;
%T2 = 100;
%fingerprintLists(:,1,offsetListNum) = 50;
%fingerprintLists(:,2,offsetListNum) = 50;
%fingerprintLists(:,3,offsetListNum) = 90;
%fingerprintLists(:,4,offsetListNum) = 180;
freqOffset = 0;
nSlices = 2;
offsetListNum = 3;
nRepeats = 2;
nTimeCoursePts = nRepeats*size(fingerprintLists,1);

[M, Mxy,flipAngles, imageTimes, t0s] = SimSE_Bernstein(T1, T2, fingerprintLists(:,:,offsetListNum), 'showPlot', freqOffset, nSlices, nTimeCoursePts);
%[M, Mxy,imageTimes,flipAngles, t0s] = SimSE(T1, T2, fingerprintLists(:,:,offsetListNum),nRepeats, freqOffset, nSlices,0);
plotSimulatedSignal(M,Mxy,imageTimes,offsetListNum)

%%
compartmentCentersList = 3; % use the compartment coordinates from the FP images

%plotting positions of sample pixels for the fingerprinting images
plotSamplePixels(FPimages,sliceNumber,2,offsetListNum,plotNumCompartments,compartmentCenters,compartmentCentersList)

%% plot and save comparison of simulation with sampled pixels
data = zeros(6,size(FPimages,3));
for n = 1:6
    data(n,:) = FPimages(compartmentCenters(n,1,3),compartmentCenters(n,2,3),:);
end
plotSimComparison(Mxy,data,nTimeCoursePts,phantomName,savingdir,compartmentCentersList,offsetListNum, sliceNumber)

%% 9. create dictionary
load /Users/jallen/Documents/short_project_2/MAT-files/fingerprintLists.mat
%
[dictionaryParams, paramRangeList] = setDictionaryParams(phantomName,3);
%%
for offsetListNum = 2:8;
    [signalDictionary, sdelT] = compileDictionary(fingerprintLists, offsetListNum, dictionaryParams,paramRangeList, nTimeCoursePts, freqOffset, nSlices, phantomName, savingdir);
end
%% 10. check similarity and use dictionary to assign values of T1, T2 etc.
% SIMILARITY
for offsetListNum = 2:8;
    [similarity, matchedT1, matchedT2, matchedFAdev, M0fit_grad, bestMatch, match_time] = calcSimilarity(FPimages,nTimeCoursePts, dictionaryParams, paramRangeList, savingdir, phantomName, offsetListNum);
end
%% Once the similarity function has been run, plot and save the T1, T2 and FA deviation maps
plotAssignedMaps(savingdir,phantomName,paramRangeList,offsetListNum,dictionaryParams,'T2');

%% choose pixels and plot time courses for the fingerprinting images
plotTCs(FPimages)
