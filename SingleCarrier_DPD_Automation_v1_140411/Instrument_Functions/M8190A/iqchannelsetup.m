function str = iqchannelsetup(cmd, pb, arbConfig)
% helper function for channel mapping dialog
switch (cmd)
    % set up the UserData and String fields of the pushbutton
    % according to the selected AWG model and operation mode
    case 'setup'
        ud = get(pb, 'UserData');
        if (isempty(ud))
            % channel mapping is not defined at all -> set default values
            if (~isempty(strfind(arbConfig.model, 'M8195A')) || ...
                isfield(arbConfig, 'visaAddr2'))
                ud = [1 0; 0 1; 1 0; 0 1];
            else
                ud = [1 0; 0 1];
            end
        else
            % channel mapping is already defined
            if (~isempty(strfind(arbConfig.model, 'M8195A')) || ...
                 isfield(arbConfig, 'visaAddr2'))
                if (length(ud) < 4)
                    ud(3:4,:) = [1 0; 0 1];
                end
            else
                ud(3:end,:) = [];
            end
        end
        duc = (~isempty(strfind(arbConfig.model, 'DUC')));
        if (duc)
            ud(:,1) = (ud(:,1) + ud(:,2)) ~= 0;
            ud(:,2) = ud(:,1);
        else
            idx = find(ud(:,1) .* ud(:,2));
            idx1 = idx;
            idx1(mod(idx,2)~=0) = [];
            ud(idx1,1) = 0;
            idx2 = idx;
            idx2(mod(idx,2)==0) = [];
            ud(idx2,2) = 0;
        end
        set(pb, 'UserData', ud);
        set(pb, 'String', iqchannelsetup('mkstring', ud));
    % convert into a string for the download pushbutton
    case 'mkstring'
        if (~isempty(pb))
            chs1 = find(pb(:,1));
            if (isempty(chs1))
                str = '';
            else
                str = sprintf('I to Ch%s', sprintf('%d+', chs1));
                str(end) = [];
            end
            chs2 = find(pb(:,2));
            if (~isempty(chs2))
                if (~isempty(chs1))
                    str = sprintf('%s, ', str);
                end
                str = sprintf('%sQ to Ch%s', str, sprintf('%d+', chs2));
                str(end) = [];
            end
            str = sprintf('%s...', str);
        else
            str = '...';
        end
    % convert into a string for the "Generate MATLAB code" function
    case 'arraystring'
        str = '[';
        for i=1:size(pb,1)
            str = sprintf('%s%s', str, sprintf('%d ', pb(i,:)));
            str(end) = [];
            if (i ~= size(pb,1))
                str = sprintf('%s; ', str);
            end
        end
        str = sprintf('%s]', str);
end

