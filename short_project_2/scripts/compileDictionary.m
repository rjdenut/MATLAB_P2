% function [signalDictionary] = compileDictionary(

%% DICTIONARY

clear dictionaryParams
dictionaryParams(1,:) = 200:20:300 ; %T1
dictionaryParams(2,:) = 200:20:300 ; %T2

nTimeCoursePts = 24;

freqOffset = 0;

nSlices = 2;

signalDictionary = zeros(size(dictionaryParams(1,:),2), size(dictionaryParams(2,:),2), nTimeCoursePts);

tic 
for i = 1:numel(dictionaryParams(1,:))
    
    T1 = dictionaryParams(1,i)
      
    for j = 1:numel(dictionaryParams(2,:))
        
        T2 = dictionaryParams(2,j)
        
        [Mtransverse, simImageMtransverse, M ,  signalDictionary(i,j,:),flipAngles, t0s] = SimBloch(T1, T2, fingerprintLists(:,:,offsetListNum), 'dontPlot', freqOffset, nSlices);
         
    end
    
    disp(['compiling dictionary: ',num2str( (i/numel(dictionaryParams(1,:)))*100) , ' percent complete'])
end
toc
%%
figure;
hold
plot(Mxy,'-.*')
for i = 1:numel(dictionaryParams(1,:))
    for j = 1:numel(dictionaryParams(2,:))
plot(squeeze(signalDictionary(i,j,:)),'-^')
    end
end


