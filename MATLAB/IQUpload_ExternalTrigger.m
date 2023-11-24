function IQUpload_ExternalTrigger ( InI, InQ, Power, Freq, Fsample, ESGAdd, SignalName, data_length, offset)

 switch nargin
        case 8
            offset = 0 ;
 end
 
norm_factor = 1.2*max(abs([InI+1i*InQ]));
InI         = InI/norm_factor;
InQ         = InQ/norm_factor;
IQData      = InI + 1i*InQ + offset;

agt_closeAllSessions;
io1 = agt_newconnection('gpib', 0, ESGAdd);
[status, status_description,query_result] = agt_query(io1,'*idn?');
if (status < 0) return; end;

SetFreq = ['SOURce:FREQuency','  ',num2str(Freq)];
SetPower = ['POWer', '  ', num2str(Power)];

[status, status_description] = agt_sendcommand(io1,SetFreq);
[status, status_description] = agt_sendcommand(io1,SetPower);

[status, status_description] = agt_waveformload(io1,IQData, SignalName, Fsample, 'play', 'no_normscale', [ones(2,10), zeros(2,length(IQData) - 10)]);

[status, status_description] = agt_sendcommand(io1,[':SOURce:RADio:ARB:SCALing "', SignalName, '",50'])

%[status, status_description] = agt_sendcommand(io1,'OUTPut:STATe OFF');

marker_value=num2str(data_length-96);
data_length_str=num2str(data_length);

[status, status_description] = agt_sendcommand(io1,[':RAD:ARB:CLEar "' ,SignalName, '",1,1,100000']);

%%%% set external trigger
[status, status_description] = agt_sendcommand(io1,':SOURcE:RADio:ARB:TRIGger:TYPE SINGle'); % CONTinuous|SINGle|GATE|SADVance
[status, status_description] = agt_sendcommand(io1,':SOURce:RADio:ARB:RETRigger ON'); % ON|OFF|IMMediate
[status, status_description] = agt_sendcommand(io1,':SOURce:RADio:ARB:RETRigger EXT'); % KEY|EXT|BUS
[status, status_description] = agt_sendcommand(io1,':SOURce:RADio:ARB:TRIGger:SOURce:EXTernal:SLOPe POSitive'); % TRIGGER SLOPE POSITIVE

agt_closeAllSessions;

