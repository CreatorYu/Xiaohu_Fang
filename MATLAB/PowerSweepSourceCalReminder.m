function [choiceVal] = PowerSweepSourceCalReminder()

    choice = questdlg('Source Power Calibrated?', ...
    'Source Power Calibrated?', ...
    'YES', 'NO', 'NO');
    % Handle response
    switch choice
        case 'YES'
            choiceVal = 1;                    
        case 'NO'
            choiceVal = 0;       
    end
end