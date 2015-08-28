% mask including whole phantom
% load('/Users/jallen/Documents/MATLAB/short_project_2/mask.mat')

%% normalise pixel values
% TEimages(:,:,TE) = TEimages(:,:,TE)/max(max(max(TEimages(:,:,:))));
% TIimages(:,:,TE) = TIimages(:,:,TI)/max(max(max(TIimages(:,:,:))));

%%
figure
for i = TE
    i
%     colormap gray
imagesc(TEimages(:,:,i))
pause
end

figure
for i = TI
    i
%     colormap gray
%  TIimages(:,:,TI(i)) = TIimages(:,:,TI(i));

imagesc(TIimages(:,:,i))
pause
end

figure
for i = 1:size(FPimages,4)
%  colormap gray
imagesc(FPimages(:,:,1,i));
i
pause
end

n = 1
for i = 1:size(FPimages,4)/2
y(i) = squeeze(FPimages(compartmentCenters(n,1),compartmentCenters(n,2),1,i));
end
y(1:end) = y(1:end)./y(1)
figure; plot(y,'*')

