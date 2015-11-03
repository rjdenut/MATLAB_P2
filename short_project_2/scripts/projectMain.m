%% ONBI short project 2 - Magnetic Resonance Fingerprinting
% Author: Jack Allen
% Supervisor: Prof. Peter Jezzard
% Start Date: 13th July 2015
%% 1. Initialise
clear all
close all

%Are you working on jalapeno00 or locally?
% workingdir = '/home/fs0/jallen/Documents/MATLAB/short_project_2';
workingdir = '/Users/jallen/Documents/MATLAB/short_project_2';
addpath(genpath(workingdir)); % sometimes causes MATLAB to freeze

savingdir = '/Users/jallen/Documents/short_project_2';
addpath(genpath(savingdir)); 

set(0,'DefaultFigureWindowStyle','docked')

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
    [TEImageInfo, TIImageInfo, FPImageInfo(:,offsetListNum), TEimages, TIimages, FPimages(:,:,:,:,offsetListNum), TE, TI] = readData(phantomName, offsetListNum, [savingdir,'/Data/'] );
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TEimages.mat'],'TEimages')
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TIimages.mat'],'TIimages')
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'FPimages.mat'],'FPimages')
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TE.mat'],'TE')
    save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TI.mat'],'TI')
end
%%
% Load the data
offsetListNum = 3;
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TEimages.mat'],'TEimages')
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TIimages.mat'],'TIimages')
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'FPimages.mat'],'FPimages')
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TE.mat'],'TE')
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TI.mat'],'TI')

[SNR,bgStd] = calcSNR(TEimages,TE,[40 2 7 7], [24 18 7 7],1);

%% 4. find signals at sample pixels
compartmentCenters = setCompartmentCenters(phantomName);
plotCompartmentCenterTCs(compartmentCenters,TEimages, TIimages, TE, TI)

%% 5. plot positions of sample pixels for TE and TR images
plotNumCompartments = 6;
sliceNumber = 2;
%%
run('plotSamplePixels_TE_TR.m')
%%
run('visualiseImages.m')

%% fit curves to calculate T1 and T2
ROI = 'fullPhantom';
[compartmentT1s, compartmentT2s, T2curves, T1curves, fittedCurve, goodness, output, F] = fitEvolutionCurves(phantomName,TEimages, TIimages, TE(2:end)', TI(2:end), ROI, compartmentCenters);

run('plotGoldStdT1T2.m')

%% 6. read in the list of timing offsets used for acquisition
run('readFingerprintOffsetList.m')
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
 fingerprintLists(:,4,offsetListNum) = 180;
freqOffset = 0;
nSlices = 2;
offsetListNum = 3;
nRepeats = 2;
nTimeCoursePts = nRepeats*size(fingerprintLists,1);

clear M
clear Mxy
[M, Mxy,flipAngles, imageTimes, t0s] = SimSE_Bernstein(T1, T2, fingerprintLists(:,:,offsetListNum), 'showPlot', freqOffset, nSlices, nTimeCoursePts);
plotSimulatedSignal(M,Mxy,imageTimes,offsetListNum)

clear M
clear Mxy
[M, Mxy,imageTimes,flipAngles, t0s] = SimSE(T1, T2, fingerprintLists(:,:,offsetListNum),nRepeats, freqOffset, nSlices,0);
plotSimulatedSignal(M,Mxy,imageTimes,offsetListNum)

%%
compartmentCentersList = 3;

%plotting positions of sample pixels for the fingerprinting images
plotSamplePixels(FPimages,sliceNumber,2,offsetListNum,plotNumCompartments,compartmentCenters,compartmentCentersList)

%%
% plot and save comparison of simulation with sampled pixels
for n = 1:6
data(n,:) = FPimages(compartmentCenters(n,1,3),compartmentCenters(n,2,3),sliceNumber,:,offsetListNum);
end
plotSimComparison(Mxy,data,nTimeCoursePts,phantomName,workingdir)

%% 9. create dictionary
load /Users/jallen/Documents/short_project_2/MAT-files/fingerprintLists.mat
%
[dictionaryParams, paramRangeList] = setDictionaryParams(phantomName,3);

for offsetListNum = 2:8;
    %%
    [signalDictionary, sdelT] = compileDictionary(fingerprintLists, offsetListNum, dictionaryParams, nTimeCoursePts, freqOffset, nSlices, phantomName, background);
    save([savingdir,'/MAT-files/dictionaries/',phantomName,'_list',num2str(offsetListNum),'paramList',num2str(paramList),'dictionary.mat'],'signalDictionary')
    save([savingdir,'/MAT-files/dictionaries/',phantomName,'_list',num2str(offsetListNum),'paramList',num2str(paramList),'signalDictionaryTime.mat'],'sdelT')
    
end

%% 10. check similarity and use dictionary to assign values of T1, T2 etc.
% SIMILARITY
for offsetListNum = 2:8;
    %%
    load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'FPimages.mat'])
    data = zeros(size(FPimages,1),size(FPimages,2), nTimeCoursePts);
    %   data(r,c,sliceNumber,1:24) = squeeze(FPimages(r,c,sliceNumber,1:24,offsetListNum));
    data = squeeze(FPimages(:,:,sliceNumber,:,offsetListNum));
    
    disp(['offsetList',num2str(offsetListNum),', phantom:',phantomName])
    clear signalDictionary
    l = load([savingdir,'/MAT-files/dictionaries/',phantomName,'_list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'dictionary.mat']);
    signalDictionary = l.signalDictionary;
    [similarity, matchedT1, matchedT2, matchedFAdev, M0fit_grad, bestMatch, match_time] = calcSimilarity(data, signalDictionary(:,:,:,:,offsetListNum),nTimeCoursePts, dictionaryParams, savingdir);
            
    save([savingdir,'/MAT-files/matches/similarity/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'similarity.mat'],'similarity')
    save([savingdir,'/MAT-files/matches/T1/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'matchedT1.mat'],'matchedT1')
    save([savingdir,'/MAT-files/matches/T2/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'matchedT2.mat'],'matchedT2')
    save([savingdir,'/MAT-files/matches/B1/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'matchedFAdevInd.mat'],'matchedFAdev')
    save([savingdir,'/MAT-files/matches/BestMatch/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'bestMatch.mat'],'bestMatch')
    save([savingdir,'/MAT-files/matches/MatchingTimes/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'compileDictionaryElapsedTime.mat'],'match_time')
    save([savingdir,'/MAT-files/matches/M0/',phantomName,'list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'M0fit_grad.mat'],'M0fit_grad')
   
end

%% Once the similarity function has been run, plot and save the T1, T2 and FA deviation maps
plotAssignedMaps(savingdir,phantomName,paramRangeList,offsetListNum,dictionaryParams,'M0');

%%
for offsetListNum = 2:8
    plotMap(phantomName,'T1',offsetListNum, savingdir,compartmentCenters)
    plotMap(phantomName,'T2',offsetListNum, savingdir,compartmentCenters)
    plotMap(phantomName,'FAdevInd',offsetListNum, savingdir,compartmentCenters)
end

%%
%choose pixels and plot time courses for the fingerprinting images
plotTCs(FPimages,15:4:30, 37, 1, 2) % breaks if 2D array of points chosen

%%
for offsetListNum = 2:8
    load(['/Users/jallen/Documents/MATLAB/short_project_2/MAT-files/matches/Jacklist',num2str(offsetListNum),'paramList1scales.mat'])
    scalesFig = figure;
    for i = 1:size(compartmentCenters(:,1))
        plot(log10(squeeze(scales(compartmentCenters(i,1,3),compartmentCenters(i,2,3),:))),'.-')
        hold on
    end
    ylabel (['log_{10}(Scaling Factor)'])
    xlabel (['Image Index'])
    legend ({'Compartment 1', 'Compartment 2', 'Compartment 3', 'Compartment 4', 'Compartment 5', 'Compartment 6'},'Position',[0.35,0.6,0.25,0.1],'FontSize',8)  
    matlab2tikz('figurehandle',scalesFig,'filename',[savingdir,'/figures/',phantomName,'compartmentScales',num2str(offsetListNum)],'height', '\figureheight', 'width', '\figurewidth')
    
end