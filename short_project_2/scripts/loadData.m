function [TEimages, TIimages, FPimages, TE, TI] = loadData(phantomName, offsetListNum, sliceNumber, savingdir)
%Function name: loadData
%Description: Loads fingerprinting MR data from a specified directory.


load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TEimages.mat'],'TEimages')
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TIimages.mat'],'TIimages')
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'fullFPimages.mat'],'fullFPimages')
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TE.mat'],'TE')
load([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TI.mat'],'TI')

FPimages(:,:,:) = squeeze(fullFPimages(:,:,sliceNumber,:));

end