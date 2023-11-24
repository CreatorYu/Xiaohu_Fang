function [choiceVal] = PowerSweepRxCalReminder()

    choice = questdlg('Receiver R1 and B Calibrated?', ...
    'Receiver Calibrated?', ...
    'YES', 'NO', 'NO');
    % Handle response
    switch choice
        case 'YES'
            choiceVal = 1;                    
        case 'NO'
            choiceVal = 0;       
    end
end