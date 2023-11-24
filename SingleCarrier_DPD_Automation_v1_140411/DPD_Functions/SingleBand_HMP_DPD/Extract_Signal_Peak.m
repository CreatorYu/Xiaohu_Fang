% Extra the peak power region
function [x, y] = Extract_Signal_Peak(all_x, all_y, training_length, DEBUG)

if length(all_x) < length(all_y)
    if DEBUG == 1
        display('PA input file smaller than output file');
    end
    all_y = all_y(1:length(all_x));
elseif length(all_x) > length(all_y)
    if DEBUG == 1
        display('PA input file larger than output file');
    end
    all_x = all_x(1:length(all_y));
else
    if DEBUG == 1
        display('PA input and output files are same length');
    end
end

[start_ind, end_ind, ind_max_x, x] = ReturnPeakRegion(all_x, training_length, DEBUG);
y = all_y(start_ind:end_ind);

end
