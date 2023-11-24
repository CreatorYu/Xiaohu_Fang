function PushButton_Save_Result
% 
% % RF_ON_Continue = 0;
% while RF_ON_Continue == 0
choice_RF_ON = questdlg('Save the result?', ...
    'Yes','No');
    % Handle response
switch choice_RF_ON
        case 'Yes'
            disp('Prepare to save the results');                    
        case 'No'
            dd          
end
end