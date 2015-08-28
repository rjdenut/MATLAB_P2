

data = squeeze(FPimages(compartmentCenters(n, 1, compartmentCentersList), compartmentCenters(n,2,compartmentCentersList), sliceNumber, (1:24)))


function [similarity] = calcSimilarity(data, signalDictionary)
% Jack Allen.
% University of Oxford.
% jack.allen@jesus.ox.ac.uk
%
% Function to calculate the similarity of a time course with each entry in a dictionary of time courses.
%
% data(nRow, nColumn, imageTimePt)
% similarity(nRow, nColumn)

%% simularity measure
for n = 1:2
    % Cosine similarity (does not depend on magnitude of each vector)
    similarity(n,T1,T2) = dot(ySim,y(n,:))/(norm(ySim)*norm(y(n,:)));
end
%     end
% end

for data_i = 1 : size(data,1)
    for data_j = 1 : size(data,2)
        
        for i = 1 : size(signalDictionary,1)
            for j = 1 : size(signalDictionary,2)
                similarity(i,j) = dot(squeeze(signalDictionary(i,j,:)),squeeze(data(data_i,data_j,:))/(norm(squeeze(signalDictionary(i,j,:)))*norm(data(data_i,data_j,:)))
            end         
        end
       
    end  
end


for n = 1:plotNumCompartments
    for i = 1:(size(FPimages,4)/2)
        y(n,i) = squeeze(FPimages(compartmentCenters(n,1,compartmentCentersList),compartmentCenters(n,2,compartmentCentersList),sliceNumber,i));
    end
    normStdBG = (std(background(:)))/y(n,1);
    y(n,:) = y(n,:)/y(n,1);
    % residuals = y(n,:) - ySim;
    %     plot(y(n,1:(size(FPimages,4)/2)),'*')
    
    errorbar(y(n,:),repmat(normStdBG,1,24),'*' );
end

end