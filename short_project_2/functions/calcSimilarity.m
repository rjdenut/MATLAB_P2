function [maxSimilarity, matchedT1, matchedT2, matchedFAdev, M0fit_grad, bestMatch, matchTime] = calcSimilarity(data, nTimeCoursePts, dictionaryParams, paramRangeList,savingdir, inputPhantomName,outputPhantomName,offsetListNum)
% Author: Jack Allen.
% Institution: University of Oxford.
% Contact: jack.allen@jesus.ox.ac.uk
%
% Description: A function to calculate the similarity of a time course with
% each entry in a dictionary of time courses and find the best match.

%% simularity measure
disp('calculating similarity: started')

load([savingdir,'/MAT-files/dictionaries/',inputPhantomName,'_list',num2str(offsetListNum),'paramList',num2str(paramRangeList),'dictionary.mat']);
signalDictionary = sd(:,:,:,:,offsetListNum);
signalDictionary = squeeze(signalDictionary);
%mask to exclude time course outside of ROI
%loadMask.Mask = load([savingdir,'/MAT-files/mask.mat']);
%mask = reshape(loadMask.mask,[64*64, 1]);

%time course of interest
imagesc(data(:,:,1))
pause
data = reshape(data,[size(data,1)*size(data,2), nTimeCoursePts]);
size(data)
imagesc(data)
pause
%simulated signals
sd = reshape(signalDictionary(:,:,:,1:nTimeCoursePts), [ size(signalDictionary,1)*size(signalDictionary,2)*size(signalDictionary,3), nTimeCoursePts]);

%initialise maps
TCsimilarity = zeros(size(data,1), size(sd,1) );
tempTCsimilarity = zeros(1, size(sd,1) );
maxSimilarity = zeros(size(data,1),1);
bestMatch = zeros(size(data,1),nTimeCoursePts);
matchedT1 = zeros(size(data,1),1);
matchedT2 = zeros(size(data,1),1);
matchedFAdev = zeros(size(data,1),1);
M0fit_grad = zeros(size(data,1),1);

M0model = @(a,x) a*x;

tic

for data_i = 1:size(data,1) %for all pixels
    disp('calculating similarity...')
    
    %if mask(data_i,1) > 0
    for sd_i = 1:size(sd,1) % for all entries in the dictionary
        tempData = data;
        tempTCsimilarity(sd_i) = dot(sd(sd_i,:), tempData(data_i,:))/(norm(sd(sd_i,:))*norm(tempData(data_i,:)));
    end

    %   find highest similarity score for TC of interest
    [maxSimilarity(data_i)]  = max(tempTCsimilarity(:));
    %Find the parameters associated with the best match
    
    [bestT1ind, bestT2ind, bestFAdevInd] = ind2sub(size(tempTCsimilarity),maxSimilarity(data_i));

    %Assign the parameters to the timecourse of interest
    matchedT1(data_i,1) = dictionaryParams(1, bestT1ind);
    matchedT2(data_i,1) = dictionaryParams(2, bestT2ind);
    matchedFAdev(data_i,1) = dictionaryParams(3, bestFAdevInd);
    bestMatch(data_i, :) = squeeze(signalDictionary(bestT1ind, bestT2ind, bestFAdevInd, 1:nTimeCoursePts));
    M0fit = fit(squeeze(bestMatch(data_i, :))', data(data_i,:)',M0model,'Upper',6000,'Lower',0,'StartPoint',500 );
    M0fit_grad(data_i,1) = M0fit.a;
    
    % end
    disp(['calculating similarity: ',num2str( (data_i/size(data,1))*100) , ' percent complete'])
    
end
%reshape the assigned parameter maps into 2D form
maxSimilarity = reshape(maxSimilarity,[sqrt(size(maxSimilarity,1)),sqrt(size(maxSimilarity,1))]);
matchedT1 = reshape(matchedT1, [sqrt(size(matchedT1,1)), sqrt(size(matchedT1,1))]);
matchedT2 = reshape(matchedT2, [sqrt(size(matchedT2,1)), sqrt(size(matchedT2,1))]);
matchedFAdev = reshape(matchedFAdev, [sqrt(size(matchedFAdev,1)), sqrt(size(matchedFAdev,1))]);
M0fit_grad = reshape(M0fit_grad, [sqrt(size(data,1)),sqrt(size(data,1))]);
bestMatch = reshape(bestMatch, [sqrt(size(bestMatch,1)), sqrt(size(bestMatch,1)),nTimeCoursePts]);


matchTime = toc

save([savingdir,'/MAT-files/matches/similarity/',outputPhantomName,'offsetlist',num2str(offsetListNum),'paramList',num2str(paramRangeList),'maxSimilarity.mat'],'maxSimilarity')
save([savingdir,'/MAT-files/matches/T1/',outputPhantomName,'offsetlist',num2str(offsetListNum),'paramList',num2str(paramRangeList),'matchedT1.mat'],'matchedT1')
save([savingdir,'/MAT-files/matches/T2/',outputPhantomName,'offsetlist',num2str(offsetListNum),'paramList',num2str(paramRangeList),'matchedT2.mat'],'matchedT2')
save([savingdir,'/MAT-files/matches/B1/',outputPhantomName,'offsetlist',num2str(offsetListNum),'paramList',num2str(paramRangeList),'matchedFAdev.mat'],'matchedFAdev')
save([savingdir,'/MAT-files/matches/BestMatch/',outputPhantomName,'offsetlist',num2str(offsetListNum),'paramList',num2str(paramRangeList),'bestMatch.mat'],'bestMatch')
save([savingdir,'/MAT-files/matches/MatchingTimes/',outputPhantomName,'offsetlist',num2str(offsetListNum),'paramList',num2str(paramRangeList),'compileDictionaryElapsedTime.mat'],'matchTime')
save([savingdir,'/MAT-files/matches/M0/',outputPhantomName,'offsetlist',num2str(offsetListNum),'paramList',num2str(paramRangeList),'M0fit_grad.mat'],'M0fit_grad')
end