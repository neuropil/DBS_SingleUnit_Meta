function [] = AO_IO_Ephys_processing(step , year , driveLetter, study , date)


if nargin == 4
    
    date2use = nan;
    
else
    
    date2use = date;
    
end


switch step
    
    case 1
        place2SetsTxts_AOS2(year , driveLetter)
    case 2
        initializeS2_S3(year , driveLetter)
    case 3 % NEED TO FIX SETS
        postAOCleanUp(study , year , date2use , driveLetter)
    case 4 % NEED TO FIX SETS
        resetS3_S4_crash(year , date2use , driveLetter)
end





end