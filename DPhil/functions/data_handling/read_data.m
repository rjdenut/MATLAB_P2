function readData(phantomName, offsetListNum, workingdir, savingdir)

switch phantomName
    
    %********************
    case 'sphereD170'
        TEImageInfo = dir([workingdir,'/nifti_data/20150714_100527ep2dseTE*']);
        TIImageInfo = dir([workingdir,'/nifti_data/20150714_100527IRep2dseTI*']);
        
        if offsetListNum == 1
            FPImageInfo = dir([workingdir,'/nifti_data/20150714_100527pjep2dsefpList1burstoffs031a1001.nii.gz']);
        end
        if offsetListNum == 2
            %             FPImageInfo = dir([workingdir,'nifti_data/20150714_100527pjep2dsefpList2burstoffs033a1001.nii.gz');
            FPImageInfo = dir([workingdir,'/nifti_data/20150819/fp/20150819_133056pjep2dsefpList2s003a1001.nii.gz']);
        end
        if offsetListNum == 3
            FPImageInfo = dir([workingdir,'/nifti_data/20150819/fp/20150819_133056pjep2dsefpList3s004a1001.nii.gz']);
        end
        if offsetListNum == 4
            FPImageInfo = dir([workingdir,'/nifti_data/20150819/fp/20150819_133056pjep2dsefpList4s005a1001.nii.gz']);
        end
        if offsetListNum == 5
            FPImageInfo = dir([workingdir,'/nifti_data/20150819/fp/20150819_133056pjep2dsefpList5s006a1001.nii.gz']);
        end
        if offsetListNum == 6
            FPImageInfo = dir([workingdir,'/nifti_data/20150819/fp/20150819_133056pjep2dsefpList6s007a1001.nii.gz']);
        end
        if offsetListNum == 7
            FPImageInfo = dir([workingdir,'/nifti_data/20150819/fp/20150819_133056pjep2dsefpList7s008a1001.nii.gz']);
        end
        if offsetListNum == 8
            FPImageInfo = dir([workingdir,'/nifti_data/20150819/fp/20150819_133056pjep2dsefpList8s009a1001.nii.gz']);
        end
        
        TE = [32:10:72,92:20:152,192:50:292,372,400];
        TI = [35,85,135,185,235,285,335,385,435,485,585,685,785,885,985];
        
        TEimages = zeros(64,64,TE(end));
        TIimages = zeros(64,64,TI(end));
        
        for TE_ind = 1:numel(TE)
            
            for i = 1:size(TEImageInfo,1)
                if strfind(TEImageInfo(i).name(1,:),['TE',num2str(TE(TE_ind))]) > 0
                    TE_filename = [workingdir,'/nifti_data/', TEImageInfo(i).name(1,:)];
                    TEimages(:,:,TE(TE_ind)) = read_avw(TE_filename);
                end
            end
        end
        
        for TI_ind = 1:numel(TI)
            for i = 1:size(TIImageInfo,1)
                
                if strfind(TIImageInfo(i).name(1,:),['TI',num2str(TI(TI_ind))]) > 0
                    TI_filename = [workingdir,'/nifti_data/', TIImageInfo(i).name(1,:)];
                    TIimages(:,:,TI(TI_ind)) = read_avw(TI_filename);
                end
            end
        end
        
        
        
        %FINGERPRINTING IMAGES
        
        fp_filename = [workingdir,'nifti_data/20150819/fp/', FPImageInfo.name(1,:)];
        disp(['fingerprint image data path:',fp_filename])
        fullFPimages(:,:,:,:) = read_avw(fp_filename);
        
        
        %********************
    case 'Jack'
        %       TEImageInfo = dir('/Users/jallen/Documents/MATLAB/short_project_2/nifti_data/20150806_125113ep2dseTE*');
        %      TIImageInfo = dir('/Users/jallen/Documents/MATLAB/short_project_2/nifti_data/20150806_125113IRep2dseTI*');
        
        TEImageInfo = dir([workingdir,'/nifti_data/20150819/20150819_142314pjep2dseTE*']);
        TIImageInfo = dir([workingdir,'/nifti_data/20150819/20150819_142314IRep2dseT1*']);
        
        %         FPImageInfo = dir('/Users/jallen/Documents/MATLAB/short_project_2/nifti_data/20150714_100527pjep2dsefpList2burstoffs033a1001.nii.gz');
        FPImageInfo = dir([workingdir,'/nifti_data/20150806_125113pjep2dsefpList22sltr132stas072a1001.nii.gz']);
        %FPImageInfo = dir([workingdir,'/nifti_data/fp/20150819_125113pjep2dsefpList',num2str(offsetListNum),'s00',num2str(offsetListNum)+1,'a1001nii.gz']);
        
        %Read TE and TI values
        for i = 1:numel(TEImageInfo)
            name = TEImageInfo(i).name;
            if name(1,29)==['s']
                tmpTE(i,1:2) = name(1,26:27);
            else
                tmpTE(i,1:3) = name(1,26:28);
            end
            str2num(tmpTE(i,:));
            i;
            TE(i) = str2num(tmpTE(i,:));
        end
        TE = unique(sort(TE));
        
        for i = 1:numel(TIImageInfo)
            name = TIImageInfo(i).name;
            i;
            if name(1,28)==['m']
                tmpTI(i,1:2) = name(1,26:27);
            end
            if name(1,29)==['m']
                tmpTI(i,1:3) = name(1,26:28);
            end
            if name(1,30)==['m']
                tmpTI(i,1:4) = name(1,26:29);
            end
            
            TI(i) = str2num(tmpTI(i,:));
        end
        TI = unique(sort(TI));
        
        %Read TE and TI images
        TEimages = zeros(64,64,TE(end));
        TIimages = zeros(64,64,TI(end));
        for TE_ind = 1:numel(TE)
            
            for i = 1:size(TEImageInfo,1)
                if strfind(TEImageInfo(i).name,['TE',num2str(TE(TE_ind))]) > 0
                    filename = [workingdir,'/nifti_data/20150819/', TEImageInfo(i).name(1,:)];
                    TEimages(:,:,TE(TE_ind)) = read_avw(filename);
                end
            end
        end
        
        for TI_ind = 1:numel(TI)
            for i = 1:size(TIImageInfo,1)
                
                if strfind(TIImageInfo(i).name,['T1',num2str(TI(TI_ind))]) > 0
                    filename = [workingdir,'/nifti_data/20150819/', TIImageInfo(i).name(1,:)];
                    
                    
                    TIimages(:,:,TI(TI_ind)) = read_avw(filename);
                    
                end
            end
        end
        
        %READ FINGERPRINTING IMAGES
        filename = [workingdir,'/nifti_data/', FPImageInfo.name(1,:)];
        fullFPimages(:,:,:,:) = read_avw(filename);
        
    otherwise
        error('Unrecognised phantom name') %('sphereD170' or 'Jack'?)
end

save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TEimages.mat'],'TEimages')
save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TIimages.mat'],'TIimages')
save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'fullFPimages.mat'],'fullFPimages')
save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TE.mat'],'TE')
save([savingdir,'/MAT-files/images/',phantomName,'_list',num2str(offsetListNum),'TI.mat'],'TI')

disp(['Finished saving image data to .mat format for offset list ',num2str(offsetListNum)])
end

