function [lfpID, lfpBool] = LFPtest(locName)

if nargin == 0
    loc2use = 'Y:\AlphaOmegaMatlabData\07_16_2014';
else
    loc2use = locName;
end

cd(loc2use);

dirTemp = dir('*.mat');

dirTable = struct2table(dirTemp);

fNames = dirTable.name;

fNindex = round(length(fNames)/2);

fName2use = fNames{fNindex};

load(fName2use);

if ~exist('CLFP1','var')
    grandCV = 0;
else
    grandCV = mean([abs(std(CLFP1))/abs(mean(CLFP1)) ,...
        abs(std(CLFP2))/abs(mean(CLFP2)) ,...
        abs(std(CLFP3))/abs(mean(CLFP3))]);
end
           
           
if grandCV <= 0.3 || sum([abs(std(CLFP1))/abs(mean(CLFP1)) <= 0.3,...
                          abs(std(CLFP2))/abs(mean(CLFP2)) <= 0.3,...
                          abs(std(CLFP3))/abs(mean(CLFP3)) <= 0.3]) >= 2;
    lfpID = 'NO';
    lfpBool = 0;
else
    lfpID = 'YES';
    lfpBool = 1;
end
           
           