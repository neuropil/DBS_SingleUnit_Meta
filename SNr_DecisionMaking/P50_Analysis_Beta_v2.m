

cd('E:\Dropbox\JohnAThompson_Matlab\p50_neuronFiles\p50VimStructs')
dirList = dir('*.mat');
dirNames = {dirList.name};

sumData = cell(length(dirNames),1);
for ii = 1:length(dirNames)
    
    cellnum = dirNames{ii};
    sumData{ii} = P50_SpikeAnalysis_v01(cellnum);

end


%%
% b 1:5 c = 6:10, t = 11:15
baseLine = nan(200,1);
condition = nan(200,1);
testing = nan(200,1);
cCount = 1;
cName = {};
for ii = 1:length(dirNames)

    tempDay = sumData{ii,1};
    cNames = fieldnames(tempDay);
    numCs = length(cNames);
    
    for iii = 1:numCs
        b1 = mean(tempDay.(cNames{iii}).peth(1:5,:));
        baseLine(cCount) = mean(b1);
        
        c1 = mean(tempDay.(cNames{iii}).peth(5:29,:));
        condition(cCount) = mean(c1);
        
        t1 = mean(tempDay.(cNames{iii}).peth(30:55,:));
        testing(cCount) = mean(t1);
        
        cName{cCount} = dirNames{ii};
        cCount = cCount + 1;
        
    end
end

baseLine = baseLine(~isnan(baseLine));
condition = condition(~isnan(condition));
testing = testing(~isnan(testing));

%%
testingBase = abs(testing - baseLine);conditionBase = abs(condition - baseLine);
testZeros = testingBase == 0;

testingBase = testingBase(~testZeros);
conditionBase = conditionBase(~testZeros);

condZeros = conditionBase == 0;
testingBase = testingBase(~condZeros);
conditionBase = conditionBase(~condZeros);

audGatRatio = testingBase ./ conditionBase;

numP50 = sum(audGatRatio < 1);
p50ratInd = audGatRatio < 1;
cNameUse = cName(p50ratInd);

histogram(audGatRatio,100);
xlabel('Auditory Gating Ratio');
ylabel('Neuron Count');
title([num2str(numP50) , ' \ ', num2str(length(audGatRatio))]);
xlim([0 4])
line([1 1] , [0 10], 'Color','k','LineStyle','--')

