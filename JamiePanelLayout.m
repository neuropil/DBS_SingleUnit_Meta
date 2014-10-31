p = panel();
p.pack('h', 2);
p(1).pack({3/4 []})
p(2).pack({1/3 1/3 1/3})

 
p.select('all');

% set margins
p.de.margin = 3;
p(1).margintop = 30;
p(2).marginright = 20;
p.margin = [6 6 2 2];


% Panel useage
p = panel();
p.pack({[]}, {1/3 2/3});

p.select('all');


p(1,1).pack(1,1);
p(1,2).pack(2,2);

% set margins
p.margin = [15 10 10 10];
p.de.margin = 8;

if k == 0
    p(1,1,1,1).select();
elseif k == 1 | k == 2
    p(1,2,1,k).select();
elseif k == 3 | k == 4
    p(1,2,2,k-2).select();
end



% f=matlab.desktop.editor.getAll;
% 
% 
% filenames=cellfun(@(s)s(find(s==filesep,1,'last')+1:end-2),{f.Filename},'uniformoutput',false);