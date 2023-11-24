function [start_ind, end_ind, ind_max, dataChunk] = ReturnPeakRegion(all_data, training_length, DEBUG)

abs_data = abs(all_data);
[maximum, ind_max] = max(abs_data(:));

if ind_max < training_length/2
    if DEBUG == 1
        display(' ');
        display('Max power located in beginning of data');
    end
    dataChunk = all_data(1:training_length);
    start_ind = 1;
    end_ind = training_length;
elseif ind_max > length(all_data)-training_length/2
    if DEBUG == 1
        display(' ');
        display('Max power located in end of data');
    end
    dataChunk = all_data(length(all_data)-training_length+1:end);
    start_ind = length(all_data)-training_length+1;
    end_ind = length(all_data);
else
    if DEBUG == 1
        display(' ');
        display('Max power located in middle of data');
    end
    dataChunk = all_data(ind_max-training_length/2:ind_max+training_length/2-1);
    start_ind = ind_max-training_length/2;
    end_ind = ind_max+training_length/2-1;
end

end
