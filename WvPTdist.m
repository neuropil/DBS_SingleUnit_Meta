function [distInMS] = WvPTdist(tempWaves, sampFreq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[~,maxIndex] = max(tempWaves,[],2);
[~,minIndex] =  min(tempWaves,[],2);

pointDist = abs(minIndex - maxIndex);

microSperPoint = 1000/(sampFreq/1000);

distInMS = (pointDist*microSperPoint)/1000; % distance in milliseconds


end

