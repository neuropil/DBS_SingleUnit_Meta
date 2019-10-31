function [] = AO_IO_Ephys_processing(step , year , date)


if nargin == 2
    
    date2use = nan;
    
else
    
    date2use = date;
    
end


switch step
    
    case 1
        place2SetsTxts_AOS2(year)
    case 2
        initializeS2_S3(year)
    case 3
        resetS3_S4_crash(year , date2use)
end





end