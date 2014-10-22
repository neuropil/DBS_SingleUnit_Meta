function [assessment, highlow] = Run_CreateThresh()
cd('Y:\PreProcessEphysData\02_13_2014')

handles.datatype = 'unClustered';


[fileList] = GetDirFileList(pwd);

assessment = zeros(length(fileList)*3,1);
highlow = zeros(length(fileList)*3,1);
count = 1;
for fi = 1:length(fileList)
    
    load(fileList{fi})
    
    for ei = 1:3
        
        spikedata = eval(strcat('CElectrode',num2str(ei)));
        
        sampleRate = sampFreqMER*1000;
        
        fileName = strcat('CElectrode',num2str(ei));
        
        handles.params = set_parameters_CSC_TEST(sampleRate, fileName, handles);
        
        [SpkCrStruct] = SpikeThresholdCreate(spikedata, handles, 'Min9sig');
        plot(SpkCrStruct.Filtered,'k');

        for li = 1:length(SpkCrStruct.MoveAverage)
            
            hold on
            
            line([SpkCrStruct.BlBounds(li,1) SpkCrStruct.BlBounds(li,2)],[SpkCrStruct.MoveAverage(li) SpkCrStruct.MoveAverage(li)], 'Color', 'g')
            
        end
        assess = input('Did it do a good job? 1 equals BAD : ','s');
        
        
        if str2double(assess)
            assessment(count) = 1;
            upordown = input('Threshold too high (2) or too low (1): ','s');
            highlow(count) = str2double(upordown);
            count = count + 1;
        else
            count = count + 1;
        end
        
        clc
        clf
    end
    
end
end

