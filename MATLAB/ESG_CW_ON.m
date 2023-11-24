% This function outputs CW at specified power and freq
% It will turn MOD OFF

function ESG_CW_ON(Power, Freq, ESGAdd)

%agt_closeAllSessions;
io1 = agt_newconnection('gpib', 0, ESGAdd);
[status, status_description,query_result] = agt_query(io1,'*idn?');
if (status < 0) return; end;

% set freq and power
SetFreq  = ['SOURce:FREQuency','  ',num2str(Freq)];
SetPower = ['POWer', '  ', num2str(Power)];

[status, status_description] = agt_sendcommand(io1,SetFreq);
[status, status_description] = agt_sendcommand(io1,SetPower);
[status, status_description] = agt_sendcommand(io1,':OUTPut:MODulation:STATe OFF');
[status, status_description] = agt_sendcommand(io1,'OUTPut:STATe ON');

%agt_closeAllSessions;

end

