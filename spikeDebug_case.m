function [out_Struct] = spikeDebug_case(debugStruct)

file2DB = debugStruct.fName;
ele2DB = debugStruct.ele;
dbcount = 0;
for dbi = 1:length(file2DB)
    
    load(file2DB{dbi});
    
    tempSpk = eval(ele2DB{dbi});
    
    sampFreq = eval(strcat(ele2DB{dbi},'_KHz'))*1000;
    
    handles.datatype = 'unClustered';
    
    handles.params = set_parameters_CSC_TEST(sampFreq,file2DB{dbi},handles);
    
    try
        [out_Struct] = spikeThreshold_filter(tempSpk, handles, 0);
    catch
        dbcount = dbcount + 1;
    end
    
end