function [ttlTimes2use] = CalculateTrialStart(ttlInfo)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


ttlTimes = ttlInfo.ttlTimesUp;
% Extract real time stamp index for TTL
dtemp = diff(ttlInfo.ttl_up)/(ttlInfo.ttl_sf*1000);
% TTL time stamps with duration greater than 5.5 seconds
ttRealInd1 = dtemp > 0.4 & dtemp < 1;
% TTL times
ttlTimes2use = ttlTimes(ttRealInd1);

end

