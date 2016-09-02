

tdir = dir('*.mat');

tdir2 = {tdir.name};

numDigs = str2double(cellfun(@(x) x(6:10), tdir2, 'UniformOutput', false));

[a,b] = sort(numDigs);

tdir3 = tdir2(b);



for ti = 21:length(tdir3)
    
    tNum = values2use(ti);
    
    if length(num2str(tNum)) == 1 || length(num2str(tNum)) == 2
        tNum2str = ['lt2d', num2str(tNum),'.000','f0001.mat'];
    elseif length(num2str(tNum)) > 5
        tmpparts = strsplit(num2str(tNum),'.');
        pre = tmpparts{1};
        post = tmpparts{2};
        if length(pre) == 1
            if length(post) >= 3
                tNum2str = ['lt2d', pre,'.', post(1:3),'f0001.mat'];
            else
                
            end
            
        else
            if length(post) >= 3
               tNum2str = ['lt2d-', pre(2), '.', post(1:3), 'f0001.mat']; 
            end
            
        end
        
    elseif length(num2str(tNum)) <= 5
        tmpparts = strsplit(num2str(tNum),'.');
        pre = tmpparts{1};
        post = tmpparts{2};
        if length(pre) == 1
            if length(post) >= 3
                tNum2str = ['lt2d', num2str(tNum),'f0001.mat'];
            else
                
            end
            
        else
            
        end
        
    end
    tname = tdir3{ti};
    
    movefile(tname,tNum2str);
    
    
    
end
    
    
    
    