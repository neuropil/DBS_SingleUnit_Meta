function [outFoldNames] = getDirFolders(mainDir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


cd(mainDir)
getCons = dir;
getNaMes = {getCons.name};
outFoldNames = getNaMes(~ismember(getNaMes,{'.','..'}));



end

