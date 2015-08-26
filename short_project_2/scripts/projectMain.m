%% ONBI short project 2 - Magnetic Resonance Fingerprinting
% Author: Jack Allen
% Supervisor: Prof. Peter Jezzard
% Start Date: 13th July 2015

clear all
close all
addpath(genpath('/Applications/fsl/'))
addpath(genpath('/usr/local/fsl/bin'))
addpath(genpath('/Users/jallen/Documents/MATLAB/short_project_2'))

%% Read in the images
%which phantom is the data from? ('sphereD170' or 'Jack'?)
phantomName = 'sphereD170';

% Choose the offset list to use. List 2 is the original 'random' list of
% offsets. Lists 3:8 are variations on List2, as described below.
%
% 3: 1st TR offset = 10000
% 4: flip Angles = 90 and 180
% 5: TE offset = 20
% 6: TR offset = 1500, TE offset = 20, FA1 = 90
% 7: TR offset = 1500, TE offset = 20
% 8: TR offset = 15000
offsetListNum = 3;

[TEImageInfo, TIImageInfo, FPImageInfo, TEimages, TIimages, FPimages, TE, TI] = readData(phantomName, offsetListNum);

%% select a ROI and a sample of the background, to calculate SNR
[SNR signal background] = calcSNR(TEimages,TE,'showFigure');
%%
run('compartmentSignals.m')

%%
run('visualiseImages.m')

%% fit curves to calculate T1 and T2

[compartmentT1s, compartmentT2s, fittedCurve, goodness, output] = fitEvolutionCurves(TEimages, TIimages, TE(2:end)', TI(2:end)', 'compartments', compartmentCenters);

% run('calcT1T2withMeans.m')

%% read in the list of timing offsets used for acquisition
run('readFingerprintOffsetList.m')
fingerprintLists(:,:,offsetListNum)

%% simulate magnetisation evolution
%check bloch simulation by using properties of the phantom

% sphereD170 properties
T1 = 282.5;
T2 = 214.1;

freqOffset = 0;
nSlices = 2;
[simMtransverse, simImageMtransverse, M, Mxy,flipAngles] = SimBloch(T1, T2, fingerprintLists(:,:,offsetListNum), 'showPlot', freqOffset, nSlices);

run('plotSim.m')

%%
run('calcSimilarity.m')

%%
run('compileDictionary.m')




