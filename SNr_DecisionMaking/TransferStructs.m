function [outStruct] = TransferStructs(inputStruct, newFname)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


fieldNames = fieldnames(inputStruct);
structData = struct2cell(inputStruct);


outStruct = struct;
for ci = 1:length(fieldNames)
    outStruct.(newFname).(fieldNames{ci}) = structData{ci}; 
end





end

