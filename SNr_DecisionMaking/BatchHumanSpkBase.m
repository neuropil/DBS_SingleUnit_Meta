function [] = BatchHumanSpkBase()


baseDIR = 'Y:\RawSortedSpikeData';
cd(baseDIR);
load('SpikeLog.mat')

if isempty(spkLog);     %#ok<NODEF>
    curList = {};
else
    curList = spkLog;
end

p50Dir = strcat(baseDIR,'\P50_SpikeFiles');
snrCNSDir = strcat(baseDIR,'\SNr_CNS_SpikeFiles');

for cLocs = 1:2
   
    switch cLocs
        case 1
            cd(p50Dir)
            expType = 'P50';
            
        case 2
            cd(snrCNSDir)
            expType = 'SNr_Eye';
    end
    
    tempDir = dir('*.mat');
    tempNames = {tempDir.name};
    
    file2runInd = ~ismember(tempNames,curList);
    files2run = tempNames(file2runInd);
    
    for fi = 1:length(files2run)

        tempCellnum = files2run{fi};
    
        CreateHumanEphysTaskStruct(expType, tempCellnum);

    end
    
    curList = [curList , files2run]; %#ok<AGROW>
end

spkLog = curList; %#ok<NASGU>
cd(baseDIR)
save('SpikeLog.mat','spkLog');

end % End of function

