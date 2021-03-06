function CheckDeDBSLength(checkTest)

if exist('Y:\','dir')
    AOLoc = 'Y:\PreProcessEphysData\';
    cd(AOLoc)
    dirfolders = dir;
    foldernamesTemp = {dirfolders.name};
    foldernamesFinal = foldernamesTemp(~cellfun(@(x) strcmp('.',x(1)),foldernamesTemp));
else
    warndlg('Check for Y:\DBS Drive');
end

%%%

for fdir = 1:length(foldernamesFinal)
    
    dateLoc = strcat(AOLoc,'\',foldernamesFinal{fdir});
    cd(dateLoc)
    
    % Check for Sets
    diractualFile = cellstr(ls);
    diractual = diractualFile(cellfun(@(x) ~strcmp('.',x(1)), diractualFile));
    testfile = diractual{1};
    
    dirDateFiles = dir('*.mat');
    
    if strcmp(testfile,'Set1') && isempty(dirDateFiles);

        for dai = 1:length(diractual)
            
            switch checkTest
                case 'Number'
                    checkNumberOrder(dateLoc, dai, diractual);
                case 'Name'
                    checkNames(dateLoc, dai, diractual);
            end
        end % End of Date loop for Sets
        
    else % it does not have sets
        dai = nan;
        switch checkTest
            case 'Number'
                checkNumberOrder(dateLoc, dai, diractual);
            case 'Name'
                checkNames(dateLoc, dai, diractual);
        end
    end
    
end

end

%% CHECK and REPLACE function

function [] = checkNames(dateLoc, dai, diractual)

if isnan(dai)
    tempdateLoc = dateLoc;
else
    tempdateLoc = strcat(dateLoc,'\',diractual{dai});
end

cd(tempdateLoc)

depthFiles = GetDirFileList(tempdateLoc);

for fii = 1:length(depthFiles)
    curFname = depthFiles{fii};
    
    nameParts = strsplit(curFname,{'_','.'});
    numPart = nameParts{3};
    
    if length(numPart) > 6
       
       trunNum = numPart(1:5);
       if strcmp(nameParts{1},'BlwTrgt')
           newVal = str2double(trunNum) + 10;
       elseif strcmp(nameParts{1},'AbvTrgt')
           newVal = str2double(trunNum) - 10;
       end
       zeroEnd = 5 - length(num2str(newVal));
       newNumName = strcat(repmat('0',1,zeroEnd), num2str(newVal));
       newFileName = strcat(nameParts{1},'_',nameParts{2},'_',newNumName,'.mat'); 
       movefile(curFname,newFileName);
        
    else
        continue
    end
    
end

end

%% CHECK Number ORDER

function [] = checkNumberOrder(dateLoc, dai, diractual)

if isnan(dai)
    tempdateLoc = dateLoc;
else
    tempdateLoc = strcat(dateLoc,'\',diractual{dai});
end

cd(tempdateLoc)

depthFiles = GetDirFileList(tempdateLoc);

splitAll = cellfun(@(x) strsplit(x,{'_','.'}), depthFiles,'UniformOutput',false);

targetName = cellfun(@(x) x(1),splitAll);
fileNumbers = cellfun(@(x) x(2),splitAll);
fileDepths = cellfun(@(x) x(3),splitAll);

% Above target test
indexAbove = strcmp(targetName,'AbvTrgt');

numNameMat = [str2double(fileNumbers(indexAbove)),str2double(fileDepths(indexAbove))];

sortNumName = sortrows(numNameMat,1);

testSortDepth = sort(numNameMat(:,2),'descend');

numCheck = isequal(sortNumName(:,2),testSortDepth);

if numCheck
    return
end


end




