function [cellNumber] = NRB_NumInput(cellName)

cellLocation = 'G:\Tetrode_DATA\Days of Recording\PreOdor_Costible_Analysis\PreOdorAnalysis\PreviousTrial';

cd(cellLocation);

fileList = GetDirFileList(cellLocation);

cellNumber = find(ismember(fileList,cellName));


end

