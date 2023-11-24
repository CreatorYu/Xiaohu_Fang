function [choiceVal] = NextFreqReminder()

    choice = questdlg('Next Freq?', ...
    'Next Freq?', ...
    'YES', 'NO', 'YES');
    % Handle response
    switch choice
        case 'YES'
            choiceVal = 1;                    
        case 'NO'
            choiceVal = 0;       
    end
end