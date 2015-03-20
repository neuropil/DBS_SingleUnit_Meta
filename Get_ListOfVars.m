function [listOfVars] = Get_ListOfVars(matFileName)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here




tempMatObj = matfile(matFileName);
tempMatInfo = whos(tempMatObj);
listOfVars = {tempMatInfo.name};




end

