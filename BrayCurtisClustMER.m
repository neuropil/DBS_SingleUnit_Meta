function [clusInd] = BrayCurtisClustMER(tempWaves)

% Bray-Curtis similarity index (Lian et al., 2010: Signal Process 90:684-8)

wvs = tempWaves;





i = 1;
tempIndex = 1:1:length(wvs);
is = [];
clusCount = 1;
clusInd = {};
while i ~= 0 
    % Container for wave indices used as a base comparison
    is = [is , i];
    % Create a repmat of single wave to compare to total remaining waves
    % NEED to fix to reflect new index number
    waveTemp = repmat(wvs(:,i),[1,length(tempIndex)]);
    % Run BrayCurtis Index
    tempInd = 1 - (sum(abs(waveTemp - wvs(:,tempIndex))) ./ sum(abs(waveTemp) + abs(wvs(:,tempIndex))));
    % Create cluster index for clusters over certain critera
    tempInd2 = find(tempInd > 0.7);
    
    spkIndex = tempIndex(tempInd2);
    
    % GET INDEX from tempINDEX
    
    
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
%     waitbar(i/length(tempWaves),wb,sprintf('%d / %d',i,length(tempWaves)));

end






