function multiColorLine(x,y,c,cmap)

numPoints = numel(x);

if nargin < 4
    cmap = spring;
end

% Normalize the color data

% 1. Subtract min value from data point and divide by range (make 0 - 1)
cn = (c-min(c))/(max(c) - min(c));
% 2. Multiply 0 - 1 by size of colormap
cn = ceil(cn * size(cmap,1));
% 3. Get rid of 0 : Make the largest element of cn = 1;
cn = max(cn, 1);

for i = 1:numPoints - 1;
    line(x(i:i+1) , y(i:i+1) ,... 
    'Color' , cmap(cn(i),:),...
    'LineWidth', 1.5)
end

