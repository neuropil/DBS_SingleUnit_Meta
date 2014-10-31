function [clusInd] = BrayCurtisClustMER(tempWaves, indCriteria)

% Bray-Curtis similarity index (Lian et al., 2010: Signal Process 90:684-8)

if nargin == 1
    indCriteria = 0.7;
end

wvs = tempWaves;

i = 1; % Base spike waveform index to use for comparison
tempIndex = 1:1:length(wvs); 
clusCount = 1;
clusInd = cell(1,size(tempIndex,2));
while i ~= 0 
    % Container for wave indices used as a base comparison
    %     is = [is , i];
    % Create a repmat of single wave to compare to total remaining waves
    waveTemp = repmat(wvs(:,i),[1,length(tempIndex)]);
    % Run BrayCurtis Index
    tempInd = 1 - (sum(abs(waveTemp - wvs(:,tempIndex))) ./ sum(abs(waveTemp) + abs(wvs(:,tempIndex))));
    % Create cluster index for clusters over certain critera
    tempInd2 = tempInd > indCriteria;
    % Create vector of similar cluster indices
    spkIndex = tempIndex(tempInd2);
    % Contain index
    clusInd{clusCount} = spkIndex;
    % Add to cluster counter
    clusCount = clusCount + 1;
    % Remove waves that match from over all index
    newInd = tempIndex(~ismember(tempIndex,spkIndex));
    % Remove indices that have already been used as a base
    %     newInd(newInd == is) = [];
    % Replace available wave index
    tempIndex = newInd;
    % Replace base index with 0 if all have been used or the next available
    % wave index
    if isempty(tempIndex)
        i = 0;
    else
        i = min(tempIndex);
    end
end

clusInd = clusInd(cellfun(@(x) ~isempty(x), clusInd));




