function [] = AnonymizeDicom_JAT(origDIR, newDIR, caseID)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% CD to original data
cd(origDIR);

% Get list of DICOMS and numerical order
dicomDir = dir('*.dcm');
dicomList = {dicomDir.name};



% Create for loop of images
for di = 1:length(dicomList)
    
    cd(origDIR)
    
    tempDCM = dicomList{di};
    
    % loop through and de-identify mri data
    tempDCMdata = dicomread(tempDCM);
    
    if isempty(tempDCMdata)
        continue
    end
    
    tempDCMinfo = dicominfo(tempDCM);
    
    sliceID = strcat('Case_',num2str(caseID),'_Sect_',num2str(tempDCMinfo.InstanceNumber),'.dcm');
    
    tempDCMinfo.PatientName = 'none';
    tempDCMinfo.PatientID = 'none';
    tempDCMinfo.PatientBirthDate = 'none';
    tempDCMinfo.PatientSex = 'NA';
    
    
    metadata = tempDCMinfo;
    
    cd(newDIR);
    dicomwrite(tempDCMdata, sliceID, metadata);

end

end

