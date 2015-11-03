function plotSimComparison(Mxy,data,nPts,phantomName,workingdir)

simCom = figure; hold on
% title (['fingerprint offset list ', num2str(offsetListNum)])
plot(Mxy(:)./Mxy(1),'x','MarkerSize',20)
nTCs = size(data,1);
y = zeros(nTCs,nPts);

%% signal from each compartment
%title (['Phantom: ',phantomName,', Offset list: ',num2str(offsetListNum),', compartment center coords list: ',num2str(compartmentCentersList)]);

for n = 1:nTCs  
        y(n,:) = data(n,:);
    %normStdBG = (std(background(:)))/y(n,1);
    y(n,:) = y(n,:)/y(n,1);
    % residuals = y(n,:) - ySim;
    plot(y(n,1:nPts),'.') 
    % errorbar(y(n,:),repmat(normStdBG,1,24),'.' );  
end

%% Save the figure
ylim([0 1.1])
legend ({'Simulated Signal', 'Sample Pixel 1','Sample Pixel 2','Sample Pixel 3','Sample Pixel 4','Sample Pixel 5','Sample Pixel 6'},'Position',[0.6, 0.7, 0.1,0.1],'location','best')
xlabel 'TE Index'
ylabel 'Normalised Signal'
savefig([workingdir,'/figures/compareSimwithData_Phantom_',phantomName,'__Offset_list_',num2str(offsetListNum),'_compartmentcentercoordslist:',num2str(compartmentCentersList),'.fig'])
matlab2tikz('figurehandle',simCom,'filename',[workingdir,'/DTC_report/',phantomName,'simCom',num2str(offsetListNum),'slice',num2str(sliceNumber)],'height', '\figureheight', 'width', '\figurewidth')
    
%% figure; plot(residuals,'+')

end