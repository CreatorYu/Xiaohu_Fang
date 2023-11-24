%% This function allows the unification of the lenght of 4 vectors to a specific value or to a maximum value
function [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q, L)
    % Check number of argument (i.e. if L was specified or no
    switch nargin
        case 5
            % If L is too large, retry
            if L > min([length(In_I), length(In_Q), length(Out_I), length(Out_Q)])
                % find the length of the smaller vector
                    L = min([length(In_I), length(In_Q), length(Out_I), length(Out_Q)]) ;
                prompt = ['The desired length is too large, enter a new one less than ' num2str(L)];
                    dlg_title = 'Error';
                    num_lines = 1;
                    DefaultAnswer = {num2str(L)};
                    options.Resize = 'on';
                    options.WindowStyle = 'normal';
                    options.Interpreter = 'tex';
                    L = inputdlg(prompt,dlg_title,num_lines,DefaultAnswer,options) ;
                    L = str2double(L) ;
                [In_I, In_Q, Out_I, Out_Q] = UnifyLength(In_I, In_Q, Out_I, Out_Q, L) ;
                return ;
            end
        case 4
            L = min([length(In_I), length(In_Q), length(Out_I), length(Out_Q)]) ;
    end
    % Crop the vecor to the new length
        In_I  = In_I (1:L) ; 
        Out_I = Out_I(1:L) ;
        In_Q  = In_Q (1:L) ; 
        Out_Q = Out_Q(1:L) ;