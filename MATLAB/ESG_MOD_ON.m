% This function turns ON the ESG MOD

function ESG_MOD_ON(ESGAdd)

agt_closeAllSessions;
io1 = agt_newconnection('gpib', 0, ESGAdd);
[status, status_description,query_result] = agt_query(io1,'*idn?');
if (status < 0) return; end;

[status, status_description] = agt_sendcommand(io1,':OUTPut:MODulation:STATe ON');
agt_closeAllSessions;

end