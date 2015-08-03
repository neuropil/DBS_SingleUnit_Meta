xyloObj = VideoReader('20150722111453.avi.avi');

vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;
nFrames = int16(xyloObj.Duration*xyloObj.FrameRate);

%%


mov(1:nFrames) = struct('rawdata',zeros(vidHeight,vidWidth, 3,'uint8'),...
                        'grayScale',zeros(vidHeight,vidWidth, 1,'uint8'),...
                        'smileAnalyze',zeros(vidHeight,vidWidth, 1,'uint8'));
       

%%

k = 1;
while hasFrame(xyloObj)
    mov(k).rawdata = readFrame(xyloObj);
    k = k+1;
end


%%

for ii = 1:nFrames
    mov(ii).rawdata = readFrame(xyloObj);
end


%%
nFrames2 = length(movI);
for iii = 1:nFrames2
    movI(iii).grayScale = rgb2gray(movI(iii).rawdata);
end
    
%%

movI2 = rmfield(movI,'rawdata');


%%

testImage = movI2(200).grayScale;

figure;
smile = imshow(testImage);
smileMask = imrect;
smileBox = createMask(smileMask,smile);
position = wait(smileMask);
close all

%%

for iiii = 1:length(movI2)
    tempImage = movI2(iiii).grayScale;
    tempImage(smileBox == 0) = 0;
    tempImage2 = imcrop(tempImage,position);
    movI2(iiii).smileAnalyze = tempImage2;
end


%%

movI3 = rmfield(movI2,'grayScale');

%%


testSmile = movI3(200).smileAnalyze;

%%

testSmile(testSmile == 0) = 145;

%%

thresh = 55;
testSmile(testSmile < thresh) = 255;
% testSmile(testSmile > thresh) = 0;
imshow(testSmile)

%%
bin = im2bw(testSmile, 0.98);

imshow(bin);

%%

bin2 = bwareaopen(bin, 40);

imshow(bin2)

%% TESTING

BW3 = bwmorph(bin2,'skel',Inf);
figure
imshow(BW3)

%%

% BW2 = bwmorph(BW,'remove');
% figure
% imshow(BW2)


%%
thresh = 55;
for i5 = 1:length(movI3)
    
    tempSimage = movI3(i5).smileAnalyze;
    tempSimage(tempSimage == 0) = 145;
    tempSimage(tempSimage < thresh) = 255;
    tempSBW = im2bw(tempSimage, 0.98);
    tempSBW_BO = bwareaopen(tempSBW, 40);
    movI3(i5).smileBW = tempSBW_BO;
    BW3 = bwmorph(tempSBW_BO,'skel',Inf);
    movI3(i5).smileLine = BW3;
    
end

%%


smilePlay = logical(zeros([size(testP), length(movI3)]));


for i6 = 1:length(movI3)
   
    smilePlay(:,:,i6) = movI3(i6).smileLine;
    
    
    
end

%%

save('TestSmile.mat','movI3','smilePlay')

%%

implay(smilePlay,30)





