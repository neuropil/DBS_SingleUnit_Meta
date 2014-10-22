function [clustStruct, waveStruct, fileInfo, debug] = spikeDebugNOwv()


% numOfspikes = vector of spike counts for all traces

% Spike Debug Script

cd('Y:\AlphaOmegaMatlabData\06_19_2014');
fileDir = dir('*.mat');
fileList = {fileDir.name};

fileIndex = randperm(length(fileList),round(length(fileList)/2));

debug = struct;
debug.fName = {};
debug.ele = {};
debug.err = {};
debugNum = 1;
eleCount = 1;
waveStruct = cell(3*round(length(fileList)/2),1);
clustStruct = cell(3*round(length(fileList)/2),1);
fileInfo = cell(3*round(length(fileList)/2),2);
for fli = 1:round(length(fileList)/2)
    
    
    
    fileName = fileList{fileIndex(fli)};
    % AbvTrgt_34_06015.mat problematic for my algorithm
    
    load(fileList{fileIndex(fli)})
    
    for ei = 1:3
        
        tempSpkData = eval(strcat('CElectrode',num2str(ei)));
        sampFreq = eval(strcat('CElectrode',num2str(ei),'_KHz'))*1000;
        
        handles.datatype = 'unClustered';
        
        handles.params = set_parameters_CSC_TEST(sampFreq,fileName,handles);
        
        try
            
            [jat_Struct] = spikeThreshold_filter(tempSpkData, handles, 0);
            
            % Get threshold data and spike number
            if ~isstruct(jat_Struct)
                tempStruct = nan;
                tempClust = nan;
                
            else
                tempStruct = jat_Struct;
                [inspk] = wave_features_jat(tempStruct.spkWaveforms, handles);
                [clustOUT, treeOUT, ipermut] = cluster_spikeData(inspk, handles);
                [~, ~, clusterAll] = GetClusterIndexWVT(clustOUT, treeOUT, tempStruct.spkIndex, tempStruct.spkWaveforms, ipermut, handles);
                tempClust = clusterAll;
                
            end
            
        catch error
            
            debug.fName{debugNum,1} = fileName;
            debug.ele{debugNum,1} = strcat('CElectrode',num2str(ei));
            debug.err{debugNum,1} = error;
            tempStruct = nan;
            tempClust = nan;
            debugNum = debugNum + 1;
            
        end
        
        waveStruct{eleCount,1} = tempStruct;
        clustStruct{eleCount,1} = tempClust;
        
        
        fileInfo{eleCount,1} = fileName;
        fileInfo{eleCount,2} = strcat('CElectrode',num2str(ei));
        
        eleCount = eleCount + 1;
        
    end
    
    fprintf('File # %d out of %d done! \n',fli, round(length(fileList)/2));
    
end

% concatAll = [numOfSpikes , threshAll];
%
% outTable = array2table(concatAll,'VariableNames',{'SpikeNum','Thresh'});



% figure(1)
% plot(thDXaxis(threshDiff < 0),threshDiff(threshDiff < 0),'r.')
% hold on
% plot(thDXaxis(threshDiff > 0),threshDiff(threshDiff > 0),'g.')
%
% figure(2)
% [wvc_n,wvc_cen] = hist(outTable.Thresh_WVC,25);
% [jat_n,jat_cen] = hist(outTable.Thresh_JAT,25);
% stairs(wvc_cen,wvc_n,'Color','r','LineWidth',2)
% hold on
% stairs(jat_cen,jat_n,'Color','b','LineWidth',2)
%
% figure(3)
% [cdfreq_jat,cdfX_jat] = ecdf(outTable.Thresh_JAT);
% plot(cdfX_jat,cdfreq_jat,'b')
% hold on
% [cdfreq_wvc,cdfX_wvc] = ecdf(outTable.Thresh_WVC);
% plot(cdfX_wvc,cdfreq_wvc,'r')

% Find where discrepancy is greatest

% absthreshDiff = round(abs(threshDiff));
%
% disCrepIndex = absthreshDiff > 500; %in millivolts
%
% % PLOT output for spikeNumber
% spikeDiff = outTable.SpikeNum_WVC - outTable.SpikeNum_JAT;
% spkDXaxis = 1:1:length(spikeDiff);
%
% figure(4)
% plot(spkDXaxis(spikeDiff < 0),spikeDiff(spikeDiff < 0),'r.')
% hold on
% plot(spkDXaxis(spikeDiff > 0),spikeDiff(spikeDiff > 0),'g.')
% plot(spkDXaxis(disCrepIndex),spikeDiff(disCrepIndex),'ok')
%
% figure(5)
% plot(spkDXaxis,outTable.SpikeNum_WVC,'r-','LineWidth',3)
% hold on
% plot(spkDXaxis,outTable.SpikeNum_JAT,'b-','LineWidth',3)
% xlabel('Voltage Trace Sample')
% ylabel('Number of spikes detected')




































