function [toAddTTL_UP , toAddTTL_DN] = get_revised_TTL_times(block1, block2)
% blocks should have the following meta data
% var: block
%

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Trailing Sampling points
% Calculate difference in time between end of block1 ephys clock and last block1 Down TTL
% End of block1 ephys time - End of block1 TTL time
% Get number of sampling points to offset using the TTL sampling frequency
sampPoints_endPad = round((block1.ephys_EndTime - block1.TTL_EndTime)*block1.TTL_fs_Hz); % time in seconds multiplied by samp freq in Hz

% Leading Sampling points
% Calculate difference in time between start of block2 ephys clock and block2 first Up TTL
% Start TTL block2 time - Start ephys block2 time
% Get number of sampling points to offset using the TTL sampling frequency
sampPoints_startPad = round((block2.TTL_StartTime - block2.ephys_StartTime)*block1.TTL_fs_Hz);

% Get total number of intervening sampling points
% Up vector has additional padding due to the block1 TTL end clock
% indicates the last TTL down whereas the last element of the UP vector
% will indicate some time before the end
totSampPointsUP = sampPoints_endPad + sampPoints_startPad + (block1.TTL_DnVec(end) - block1.TTL_UpVec(end));
totSampPointsDN = sampPoints_endPad + sampPoints_startPad;

% Initialize empty vectors for new block2 TTL vectors
combinNewUP = zeros(length(block2.TTL_UpVec),1);
combinNewDN = zeros(length(block2.TTL_UpVec),1);
% Number of sampling points intervening between last block1 vector
upStart = block1.TTL_UpVec(end) + totSampPointsUP;
dnStart = block1.TTL_DnVec(end) + totSampPointsDN;

for ii = 1:length(combinNewUP);
    
    % Add offset of block2 TTL up and down vector to new offset
    combinNewUP(ii) = upStart + block2.TTL_UpVec(ii);
    combinNewDN(ii) = dnStart + block2.TTL_DnVec(ii);
    
end

% Stitch TTL vectors with block1 and newly aligned block2
toAddTTL_UP = combinNewUP';
toAddTTL_DN = combinNewDN';
    











