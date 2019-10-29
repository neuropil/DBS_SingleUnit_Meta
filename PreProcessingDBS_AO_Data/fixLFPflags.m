function [] = fixLFPflags(year)


s3Dir = ['X:\S3_AO_MatlabData_S3\', num2str(year)];

s2Dir = ['X:\S2_AOUnFMatlabData_S2\', num2str(year)];

s3d2 = getDirFolders(s3Dir);

for si = 1:length(s3d2)
    
    tmpS3 = [s3Dir,filesep,s3d2{si}];
    
    cd(tmpS3)
    
    tdirM = dir('*.mat');
    tdirMn = {tdirM.name};
    
    if ~isempty(tdirMn)
        
        setSwitch = 1;
        
    else
        
%         setName1 = dir();
%         setName2 = {setName1.name};
%         setName3 = setName2(~ismember(setName2,{'.','..'}));
        
        setName3 = getDirFolders(tmpS3);
        
        setSwitch = 2;
        
    end
    
    switch setSwitch
        case 1
            
            tmpS2 = [s2Dir,filesep,s3d2{si}];
            
            txtD = dir('*.txt');
            txtD1 = {txtD.name};
            
            % Get LFP text
            lfpID = txtD1{contains(txtD1,'lfp')};
            
            % Yes or No
            if contains(lfpID,'no')
                cd(tmpS2)
                save('lfp_no.txt')
                save('NOAO.txt')
            else
                cd(tmpS2)
                save('lfp_yes.txt')
                save('NOAO.txt')
            end
            
        case 2
            
            for ssi = 1:length(setName3)
                
                tmpS3 = [s3Dir,filesep,s3d2{si},filesep,setName3{ssi}];
                cd(tmpS3)
                tmpS2 = [s2Dir,filesep,s3d2{si},filesep,setName3{ssi}];
                
                txtD = dir('*.txt');
                txtD1 = {txtD.name};
                
                % Get LFP text
                lfpID = txtD1{contains(txtD1,'lfp')};
                
                % Yes or No
                if contains(lfpID,'no')
                    cd(tmpS2)
                    save('lfp_no.txt')
                    save('NOAO.txt')
                else
                    cd(tmpS2)
                    save('lfp_yes.txt')
                    save('NOAO.txt')
                end
            end
    end
    
    
end



end