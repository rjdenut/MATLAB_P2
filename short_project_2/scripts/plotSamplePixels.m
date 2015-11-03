function plotSamplePixels(FPimages,sliceNumber,frame,offsetListNum,plotNumCompartments,compartmentCenters,compartmentCentersList)
figure;
imagesc(FPimages(:,:,sliceNumber,frame,offsetListNum))
hold on
compartmentLabels = ['1', '2','3','4','5','6'];
for i = 1:plotNumCompartments
    plot(compartmentCenters(i,2,compartmentCentersList),compartmentCenters(i,1,compartmentCentersList),'*')
    text(compartmentCenters(i,2,compartmentCentersList),compartmentCenters(i,1,compartmentCentersList), compartmentLabels(i) )
end