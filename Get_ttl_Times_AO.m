function [UP_vecTimes,DN_vecTimes] = Get_ttl_Times_AO(block)



UP_vecTimes = block.TTL_StartTime + (block.TTL_UpVec./block.TTL_fs_Hz);


DN_vecTimes = block.TTL_StartTime + (block.TTL_DnVec./block.TTL_fs_Hz);

               




