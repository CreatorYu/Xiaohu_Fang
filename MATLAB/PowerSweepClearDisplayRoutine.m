function [choiceVal] = PowerSweepClearDisplayRoutine()

    choice = questdlg('Setup Power Sweep Display?', ...
    'Preset and Display', ...
    'Preset', 'NO', 'NO');
    % Handle response
    switch choice
        case 'Preset'
            choiceVal = 1;                    
        case 'NO'
            choiceVal = 0;       
    end
end