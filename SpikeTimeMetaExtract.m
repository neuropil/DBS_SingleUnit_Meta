function [clustStruct, waveStruct, fileInfo, debug] = SpikeTimeMetaExtract()


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
        sampFreq = eval(strcat('CElectrode',num2str(ei),'_KHz'))*1000; % THIS NEEDS to CHANGE
        
        handles.datatype = 'unClustered';
        
        handles.params = set_parameters_CSC_TEST(sampFreq, fileName, handles);
        
        try
            
            [thrOut] = SpikeThresholdCreate(tempSpkData, handles, 'Min9sig');
            filtSpkData = thrOut.Filtered;
            threshold = thrOut.AveThresh;
            [jat_Struct] = SpikeTimeExtract(filtSpkData, threshold, handles);
            
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


