function [clu,tree,ipermut] = cluster_spikeData(inspk, handles)


if handles.params.permut == 'y'
    if handles.params.match == 'y';
        naux = min(handles.params.max_spk,size(inspk,1));
        ipermut = randperm(length(inspk));
        ipermut(naux+1:end) = [];
        inspk_aux = inspk(ipermut,:);
    else
        ipermut = randperm(length(inspk));
        inspk_aux = inspk(ipermut,:);
    end
else
    if handles.par.match == 'y';
        naux = min(handles.params.max_spk,size(inspk,1));
        inspk_aux = inspk(1:naux,:);
    else
        inspk_aux = inspk;
    end
end

%Interaction with SPC
% set(handles.file_name,'string','Running SPC ...');
fname_in = handles.params.fname_in;
save([fname_in],'inspk_aux','-ascii');                      %Input file for SPC

%%%% CHANGE TO ELECTRODE
% handles.params.fnamesave = [handles.params.fname '_ch' ...
%     num2str(channel)];                                      %filename if "save clusters" button is pressed


handles.params.fnamespc = handles.params.fname;
handles.params.fname = [handles.params.fname '_wc'];              %Output filename of SPC
[clu, tree] = run_cluster_jat(handles);


% if exist('ipermut')
%     clu_aux = zeros(size(clu,1),length(index)) + 1000;
%     for i=1:length(ipermut)
%         clu_aux(:,ipermut(i)+2) = clu(:,i+2);
%     end
%     clu_aux(:,1:2) = clu(:,1:2);
%     clu = clu_aux; clear clu_aux
% end



end

