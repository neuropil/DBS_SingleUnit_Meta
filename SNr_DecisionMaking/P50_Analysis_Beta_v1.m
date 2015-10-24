

cd('Y:\HumanNeuronDB')
dirList = dir('*.mat');
dirNames = {dirList.name};

p50listInd = cellfun(@(x) ~ismember(x(1:14),{'07302015_04493','07082015_00077'}), dirNames);
p50list = dirNames(p50listInd);

sumData = cell(length(p50list),1);
for ii = 1:length(p50list)
    
    cellnum = p50list{ii};
    sumData{ii} = P50_SpikeAnalysis_v01(cellnum);

end


%%
% b 1:5 c = 6:10, t = 11:15
baseLine = nan(200,1);
condition = nan(200,1);
testing = nan(200,1);
cCount = 1;
cName = {};
for ii = 1:length(p50list)

    tempDay = sumData{ii,1};
    cNames = fieldnames(tempDay);
    numCs = length(cNames);
    
    for iii = 1:numCs
        b1 = mean(tempDay.(cNames{iii}).peth(1:5,:));
        baseLine(cCount) = mean(b1);
        
        c1 = mean(tempDay.(cNames{iii}).peth(6:10,:));
        condition(cCount) = mean(c1);
        
        t1 = mean(tempDay.(cNames{iii}).peth(11:15,:));
        testing(cCount) = mean(t1);
        
        cName{cCount} = p50list{ii};
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

numP50 = sum(audGatRatio < 0.5);
p50ratInd = audGatRatio < 0.5;
cNameUse = cName(p50ratInd);

histogram(audGatRatio,100);
xlabel('Auditory Gating Ratio');
ylabel('Neuron Count');
title([num2str(numP50) , ' \ ', num2str(length(audGatRatio))]);
xlim([0 4])
line([0.5 0.5] , [0 10], 'Color','k','LineStyle','--')

