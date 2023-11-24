% This function turns OFF ESG output

function ESG_RF_OFF(ESGAdd)

agt_closeAllSessions;
io1 = agt_newconnection('gpib', 0, ESGAdd);
[status, status_description,query_result] = agt_query(io1,'*idn?');
if (status < 0) return; end;

[status, status_description] = agt_sendcommand(io1,SetFreq);
[status, status_description] = agt_sendcommand(io1,SetPower);

[status, status_description] = agt_sendcommand(io1,'OUTPut:STATe OFF');

agt_closeAllSessions;

end

