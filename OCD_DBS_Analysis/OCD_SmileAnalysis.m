function [] = OCD_SmileAnalysis(caseNum,Side,thresh)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3;
    thresh = 55;
end

caseLoc = strcat('Y:\Videos\OCD_IO_Testing\',caseNum,'\Stimulation_Clips\',Side);

cd(caseLoc);

aviList1 = dir('*.avi');
aviList = {aviList1.name};

for aI = 1:length(aviList)
    
    cd(caseLoc)
    
    tempAVI = aviList{aI};
    
    aviSmObj = VideoReader(tempAVI); %#ok<TNMLP>
    
    vidHeight = aviSmObj.Height;
    vidWidth = aviSmObj.Width;
    nFrames = int16(aviSmObj.Duration*aviSmObj.FrameRate);
    
    clear movI
    movI(1:nFrames) = struct('rawdata',zeros(vidHeight,vidWidth, 3,'uint8'),...
        'grayScale',zeros(vidHeight,vidWidth, 1,'uint8'),...
        'smileAnalyze',zeros(vidHeight,vidWidth, 1,'uint8'));

    for fi = 1:nFrames
        % Create Raw Data
        movI(fi).rawdata = readFrame(aviSmObj);
    end
    
    if aI == 1;
        
        % Create temporary smileBox
        smNumber = nFrames/2;
        smBimage = movI(smNumber).rawdata;
        smBimageGS = rgb2gray(smBimage);
        
        figure;
        mouthTemp = imshow(smBimageGS);
        smileMask = imrect;
        smileBox = createMask(smileMask,mouthTemp);
        position = wait(smileMask);
        close all
        
    end

    for fi = 1:nFrames
        % Create Gray Scale Image
        movI(fi).grayScale = rgb2gray(movI(fi).rawdata);
        % Remove Raw Data RGB
        movI(fi).rawdata = [];
        % Create Copy of Gray Scale Image
        tempImage = movI(fi).grayScale;
        % Create Region of Interest around mouth using smileBox Mask
        tempImage(smileBox == 0) = 0;
        % Crop image by Position of Mask
        tempImage2 = imcrop(tempImage,position);
        % Insert Cropped Image into Smile Analyze Struct
        movI(fi).smileAnalyze = tempImage2;
        % Remove Gray Scale Image
        movI(fi).grayScale = [];
        % Copy Smile image
        tempSimage = movI(fi).smileAnalyze;
        % Gid rid of artifactual zeros
        tempSimage(tempSimage == 0) = 145;
        % Highlight smile which will have darker pixels
        tempSimage(tempSimage < thresh) = 255;
        % Convert Smile image to Binary image
        smileBin = im2bw(tempSimage, 0.98);
        % Get Rid of blobs
        smileBinArea = bwareaopen(smileBin, 40);
        % Save a copy of mouth polygon
        movI(fi).smileBW = smileBinArea;
        % Create skeleton of mouth
        skelMouth = bwmorph(smileBinArea,'skel',Inf);
        % Save a copy of mouth line
        movI(fi).smileLine = skelMouth;
    end
    
    movI = rmfield(movI,{'rawdata','grayScale'});
    % Get file name
    [~,avIname,~] = fileparts(tempAVI);
    
    saveName = strcat(avIname,'.mat');
    
    saveLoc = strcat('Y:\Videos\OCD_IO_Testing\',caseNum,'\MatData_VideoFiles\',Side);
    
    cd(saveLoc)
    
    save(saveName,'movI');
    
end

sendmail('john.arthur.thompson@gmail.com', 'Hello from MATLAB', 'Analysis Complete!' );

end

