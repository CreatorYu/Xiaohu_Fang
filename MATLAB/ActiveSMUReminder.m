function [choiceVal] = ActiveSMUReminder()

    choice = questdlg('Active SMU in PNA-X?', ...
    'Active SMU in PNA-X?', ...
    'YES', 'NO', 'NO');
    % Handle response
    switch choice
        case 'YES'
            choiceVal = 1;                    
        case 'NO'
            choiceVal = 0;       
    end
end