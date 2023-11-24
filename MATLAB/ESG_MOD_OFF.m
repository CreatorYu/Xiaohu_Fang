% This function turns OFF the ESG MOD

function ESG_MOD_OFF(ESGAdd)

agt_closeAllSessions;
io1 = agt_newconnection('gpib', 0, ESGAdd);
[status, status_description,query_result] = agt_query(io1,'*idn?');
if (status < 0) return; end;

[status, status_description] = agt_sendcommand(io1,':OUTPut:MODulation:STATe OFF');

agt_closeAllSessions;

end