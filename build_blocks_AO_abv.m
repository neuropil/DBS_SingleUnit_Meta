function [block] = build_blocks_AO_abv(eph_st,...
    eph_et,...
    eph_fs,...
    ttl_downV,...
    ttl_upV,...
    ttl_st,...
    ttl_et,...
    ttl_fs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 3
    
    block.ephys_StartTime = eph_st;
    block.ephys_EndTime = eph_et;
    block.ephys_fs_Hz = eph_fs*1000;
    % Define TTL_Times
    
else
    
    block.ephys_StartTime = eph_st;
    block.ephys_EndTime = eph_et;
    block.ephys_fs_Hz = eph_fs*1000;
    
    block.TTL_DnVec = ttl_downV;
    block.TTL_UpVec = ttl_upV;
    block.TTL_StartTime = ttl_st;
    block.TTL_EndTime = ttl_et;
    block.TTL_fs_Hz = ttl_fs*1000;
    
    
end
end

