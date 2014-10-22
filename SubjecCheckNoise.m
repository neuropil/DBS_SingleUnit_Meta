function [maxAmp , meanAmp , sdAmp , sdMmeanAmp, seAmp , seMmaxAmp , sdMmRange , cvAmp] = SubjecCheckNoise(assessment)
cd('Y:\PreProcessEphysData\02_13_2014')

if ~islogical(assessment)
    assessment = logical(assessment);
end

[fileList] = GetDirFileList(pwd);


files2analyze = cell(length(fileList)*3,2);
fstart = 1;
fend = 3;
for fai = 1:length(fileList)
    
    eleNames = {'CElectrode1','CElectrode2','CElectrode3'};
    
    files2analyze(fstart:fend,1) = cellstr(repmat(fileList{fai},3,1));
    files2analyze(fstart:fend,2) = eleNames;
    
    fstart = fend + 1;
    fend = fend + 3;
    
end


fileListToUse = files2analyze(assessment,:);

meanAmp = zeros(length(fileListToUse),1);
maxAmp = zeros(length(fileListToUse),1);
sdAmp = zeros(length(fileListToUse),1);
sdMmeanAmp = zeros(length(fileListToUse),1);
seAmp = zeros(length(fileListToUse),1);
seMmaxAmp = zeros(length(fileListToUse),1);
sdMmRange = zeros(length(fileListToUse),1);
cvAmp = zeros(length(fileListToUse),1);
for fi = 1:length(fileListToUse)
    
    load(fileListToUse{fi,1})

    spikedata = eval(fileListToUse{fi,2});
    meanAmp(fi) = mean(spikedata(spikedata > 0));
    maxAmp(fi) = max(spikedata(spikedata > 0));
    sdAmp(fi) = std(spikedata(spikedata > 0));
    sdMmeanAmp(fi) = abs(meanAmp(fi) - sdAmp(fi));
    seAmp(fi) = sqrt(sdAmp(fi))/numel(spikedata);
    seMmaxAmp(fi) = abs(maxAmp(fi) - seAmp(fi));
    sdMmRange(fi) = sdMmeanAmp(fi)/maxAmp(fi);
    cvAmp(fi) = sdAmp(fi)/meanAmp(fi);
    
end
end

