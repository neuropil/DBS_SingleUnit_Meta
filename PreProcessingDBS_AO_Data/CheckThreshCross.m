function [] = CheckThreshCross()
cd('Y:\PreProcessEphysData\02_13_2014')

% if ~islogical(assessment)
%     assessment = logical(assessment);
% end

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


% fileListToUse = files2analyze(assessment,:);


for fl2 = 1:length(files2analyze)
    
    load(files2analyze{fl2,1})

    rawSpkData = eval(files2analyze{fl2,2});
    handles.datatype = 'unClustered';
    fileName = strcat(files2analyze{fl2,1},'_',files2analyze{fl2,2});
    sampleRate = sampFreqMER*1000;
    handles.params = set_parameters_AO(sampleRate, fileName, handles);
    
    [thrOut] = SpikeThresholdCreate(rawSpkData, handles, 'Min9sig');
    filtSpkData = thrOut.Filtered;
    threshold = thrOut.AveThresh;
    
    [SpDStr] = spikeThreshold_filter_10222104(filtSpkData, threshold, handles);
    
    plot(SpDStr.SpikeData,'k');
    hold on
    xAxis = (1:1:length(SpDStr.SpikeData))';
    plot(xAxis(SpDStr.spkIndex), SpDStr.SpikeData(SpDStr.spkIndex),'ro');
    
    pause
    clf
    

end



















end

