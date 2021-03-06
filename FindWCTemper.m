function [temp] = FindWCTemper(tree,handles)
% Selects the temperature.

num_temp = handles.params.num_temp;
min_clus = handles.params.min_clus;

aux0 = diff(tree(:,5));   % Changes in the first cluster size
aux1 = diff(tree(:,6));   % Changes in the second cluster size
aux2 = diff(tree(:,7));   % Changes in the third cluster size
aux3 = diff(tree(:,8));   % Changes in the fourth cluster size
aux4 = diff(tree(:,9));   % Changes in the fifth cluster size
aux5 = diff(tree(:,10));   % Changes in the sixth cluster size
aux6 = diff(tree(:,11));   % Changes in the seventh cluster size

% diffMat = zeros(size(tree,1)-1,length(5:size(tree,2)));
% for dmi = 1:length(5:size(tree,2))
%     dmI = dmi + 4;
%     diffMat(:,dmi) = diff(tree(:,dmI));
%     
% end
% 
% temp1 = 1; 
% for t = 1:num_temp - 1;
%     if any(abs(diffMat(t,:)) > min_clus)
%         temp1 = t + 1;   
%     end
% end
        


temp = 1;         % Initial value

for t = 1:num_temp - 1;
    % Looks for changes in the cluster size of any cluster larger than min_clus.
    if ( aux0(t) > min_clus ||...
         aux1(t) > min_clus ||...
         aux2(t) > min_clus ||...
         aux3(t) > min_clus ||...
         aux4(t) > min_clus ||...
         aux5(t) > min_clus ||...
         aux6(t) > min_clus)    
        temp = t + 1;         
    end
end

%In case the second cluster is too small, then raise the temperature a little bit 
if (temp == 1 && tree(temp, 6) < min_clus)
    temp = 2;
end    
   
