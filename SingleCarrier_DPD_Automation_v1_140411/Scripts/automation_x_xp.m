%% First Do iteration with Volterra
% Skipped
%% Get the data
[x_I, x_Q, xp_I, xp_Q] = UnifyLength(In_I_beforeDPD_EVM, In_Q_beforeDPD_EVM, In_I_withDPD, In_Q_withDPD);
dir_name_parent = dir_name;
%% Do Parallel FIR Tests
DPD_type = 'APD';
APD_modelParam.N = 8;
APD_modelParam.M = 5;
APD_modelParam.FIR_M = 5;
APD_modelParam.architecture = 'multiply';
APD_modelParam.polyorder = 'odd_aug';
APD_modelParam.two_step = 1;

APD_modelParam.engine = 'Mod_H_EMP';
DoDPDTestRun;
APD_modelParam.engine = 'Mod_NB_EMP';
DoDPDTestRun;
APD_modelParam.engine = 'Mod_ECRV';
DoDPDTestRun;

%% Do Series FIR Tests
DPD_type = 'FIR_APD';
FIR_APD_modelParam.APD_N = 8;
FIR_APD_modelParam.APD_M = 5;
FIR_APD_modelParam.FIR_M = 5;
FIR_APD_modelParam.architecture = 'multiply';
FIR_APD_modelParam.polyorder = 'odd_aug';
FIR_APD_modelParam.two_step = 1;
FIR_APD_modelParam.use_NL = 0;

FIR_APD_modelParam.engine = 'H_EMP';
DoDPDTestRun;
FIR_APD_modelParam.engine = 'NB_EMP';
DoDPDTestRun;
FIR_APD_modelParam.engine = 'ECRV';
DoDPDTestRun;