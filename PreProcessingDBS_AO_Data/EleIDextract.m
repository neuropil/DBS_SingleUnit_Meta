function eleOut = EleIDextract(eleIn)
    
    sessAll = eleIn(:,1);
    sessNums = unique(eleIn(:,1));
    eleAll = eleIn(:,2);
    
    eleOut = cell(length(sessNums),1);
    for snI = 1:length(sessNums)
        
        sessIndex = ismember(sessAll,sessNums{snI});
        tempNumVec = eleAll(sessIndex);
        eleOut{snI,1} = cellfun(@(x) str2double(x(length(x))), tempNumVec);
        
    end

end
