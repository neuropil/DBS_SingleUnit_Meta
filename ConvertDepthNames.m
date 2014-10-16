function [depthName, depthNumeric] = ConvertDepthNames(filesLocation)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


% applyStr = @(x) strsplit(x,{'[0-9]{5,10}'},'DelimiterType','RegularExpression');

depthfileNames = GetDirFileList(filesLocation);

belowCheckVec = cellfun(@(x) x(1), depthfileNames, 'UniformOutput', false);

belowCheck = ismember('B',belowCheckVec);

% Above data
abvIndex = logical(cellfun(@(x) strfind(x,'Abv'), depthfileNames));
abvNums = cellfun(@(x) regexp(x,'[0-9]{5,10}','match'), depthfileNames(abvIndex));

abvTs = depthfileNames(abvIndex);
[abvSort, abvOrder] = sort(abvNums);
first_abvTs = abvTs(abvOrder);

abv_numName = cell(length(abvSort),1); 
abv_newNum = zeros(length(abvSort),1);

for abi = 1:sum(abvIndex)
    
    tempNum = abvSort{abi};
    
    mmPart = tempNum(1:2);
    decPart = tempNum(3:4);
    numNum = [mmPart,'.',decPart];
    
    abv_numName{abi} = numNum;
    abv_newNum(abi) = str2double(numNum);
    
    if abi ~= 1
        if strcmp(abv_numName{abi - 1},abv_numName{abi})
           abv_newNum(abi) = str2double(numNum) + 0.01; 
        end
    else
        continue
    end

end


if belowCheck
    % Below data
    blwIndex = cellfun(@(x) strfind(x,'Blw'), depthfileNames);
    blwNums = cellfun(@(x) regexp(x,'[0-9]{5,10}','match'), depthfileNames(blwIndex));
    
    blwTs = depthfileNames(blwIndex);
    [blwSort, blwOrder] = sort(blwNums);
    first_blwTs = blwTs(blwOrder);
    
    blw_numName = cell(length(blwSort),1);
    blw_newNum = zeros(length(blwSort),1);
    
    for bli = 1:sum(blwIndex)
        
        tempNum = blwSort{bli};
        
        mmPart = tempNum(1:2);
        decPart = tempNum(3:4);
        numNum = [mmPart,'.',decPart];
        
        blw_numName{bli} = numNum;
        blw_newNum(bli) = str2double(numNum);
        
        if bli ~= 1
            if strcmp(blw_numName{bli - 1},blw_numName{bli})
                blw_newNum(bli) = str2double(numNum) + 0.01;
            end
        else
            continue
        end % End of if statement
    end % End of below for loop
    
else
    
    blw_newNum = [];
    first_blwTs = {};
    
end % End of Below Check

[abvFinal, abvFinalOrder] = sort(abv_newNum, 'descend');
final_abvTs = first_abvTs(abvFinalOrder);

depthNumeric = [abvFinal ; blw_newNum];
depthName = [final_abvTs ; first_blwTs];

end

