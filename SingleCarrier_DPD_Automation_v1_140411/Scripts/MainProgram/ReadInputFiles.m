%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reading the input files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
In_I_beforeDPD = load(['Signals\' InI_beforeDPD_path]); In_I_beforeDPD = In_I_beforeDPD(:, 1);
In_Q_beforeDPD = load(['Signals\' InQ_beforeDPD_path]); In_Q_beforeDPD = In_Q_beforeDPD(:, 1);

min_size = min([ size(In_I_beforeDPD,1) size(In_I_beforeDPD,1)]);

if min_size > round(FramTime*FsampleTx) + 1
    min_size = round(FramTime*FsampleTx) + 1;
end
In_I_beforeDPD = In_I_beforeDPD(1:min_size-1);
In_Q_beforeDPD = In_Q_beforeDPD(1:min_size-1);

[In_I_beforeDPD, In_Q_beforeDPD] = setMeanPower(In_I_beforeDPD, In_Q_beforeDPD, 0) ;
[meanPower, maxPower, PAPR_original] = checkPower(In_I_beforeDPD, In_Q_beforeDPD, 1) ;

Vdd_beforeDPD = abs(complex(In_I_beforeDPD, In_Q_beforeDPD));

In_I_beforeDPD_EVM = resample(In_I_beforeDPD,UpSampleTx,DownSampleTx);
In_Q_beforeDPD_EVM = resample(In_Q_beforeDPD,UpSampleTx,DownSampleTx);

data_length = length(In_I_beforeDPD);

disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp([' The length of the signals   = ',num2str(data_length)]);
disp(' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

In_I = In_I_beforeDPD;
In_Q = In_Q_beforeDPD;

if strcmp(GainExpansion,'Yes')
    InflectionPoint=0.2;
    PAPR_beforeExpansion=computePAPR(In_I,In_Q)
    [ In_I , In_Q ] = Generate_XdB_Expansion(In_I,In_Q,GainExpansion_value,InflectionPoint);
    PAPR_afterExpansion=computePAPR(In_I,In_Q)
end