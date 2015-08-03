function [block] = build_block_AO(ttl_downV,...
    ttl_upV,...
    ttl_st,...
    ttl_fs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    block.TTL_DnVec = ttl_downV;
    block.TTL_UpVec = ttl_upV;
    block.TTL_StartTime = ttl_st;
    block.TTL_fs_Hz = ttl_fs*1000;
    
    

end

