%% This function allows the unification of the lenght of 4 vectors to a specific value or to a maximum value
function [In, Out] = UnifyLength(In, Out, L)
% Check number of argument (i.e. if L was specified or no
switch nargin
    case 3
        % If L is too large, retry
        if L > min([length(In), length(Out)])
            % find the length of the smaller vector
            L = min([length(In), length(Out)])
            prompt = ['The desired length is too large, enter a new one less than ' num2str(L)];
            dlg_title = 'Error';
            num_lines = 1;
            DefaultAnswer = {num2str(L)};
            options.Resize = 'on';
            options.WindowStyle = 'normal';
            options.Interpreter = 'tex';
            L = inputdlg(prompt,dlg_title,num_lines,DefaultAnswer,options) ;
            L = str2double(L) ;
            [In, Out] = UnifyLength(In, Out, L) ;
            return ;
        end
    case 2
        L = min([length(In), length(Out)]);
end
% Crop the vecor to the new length
In  = In (1:L) ;
Out = Out(1:L) ;

end
