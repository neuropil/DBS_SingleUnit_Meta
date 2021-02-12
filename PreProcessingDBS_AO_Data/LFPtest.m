function lfpBool = LFPtest(locName)

cd(locName);

dirTemp = dir('*.txt');

dirTable = struct2table(dirTemp);

fNames = dirTable.name;

if ismember('lfp_no.txt',fNames)
    lfpBool = 0;
    
elseif ismember('lfp_yes.txt',fNames)
    lfpBool = 1;
    
end
