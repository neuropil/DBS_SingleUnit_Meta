function [fileList] = GetDirFileList(dirLoc, fileExt)
%GetDirFileList Summary of this function goes here
%   Detailed explanation goes here

% Troubleshoot for '*' by extension

if nargin == 1
    fileExt = '*.mat';
end

cd(dirLoc)

dirStruct = dir(fileExt);
dirTable = struct2table(dirStruct);

fileList = dirTable.name;



end

