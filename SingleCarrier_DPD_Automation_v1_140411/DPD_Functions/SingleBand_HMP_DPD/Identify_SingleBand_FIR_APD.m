function [coefficients, NMSE] = Identify_SingleBand_FIR_APD(modelParam, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints)

% Hotfix for Static Engine Type
if(strcmp(modelParam.engine, 'Static'))
    modelParam.engine = 'MP';
    modelParam.APD_M = 1;
end

model_APD.N = modelParam.APD_N;
model_APD.M = modelParam.APD_M;
model_APD.architecture = modelParam.architecture;
model_APD.engine = modelParam.engine;
model_APD.polyorder = modelParam.polyorder;
model_APD.two_step = modelParam.two_step;
model_APD.FIR_M = modelParam.FIR_M;
% FIR is just a N = 0 DPD
model_FIR.M = modelParam.FIR_M;
model_FIR.N = 0;
model_FIR.architecture = 'multiply';
model_FIR.engine = 'MP';
model_FIR.polyorder = modelParam.polyorder;
model_FIR.two_step = modelParam.two_step;

% Interchange input and output to model reverse PA
y_ori = complex(PA_in_I, PA_in_Q);
x_ori = complex(PA_out_I,PA_out_Q);

[x, y] = Extract_Signal_Peak(x_ori, y_ori, NofDPDPoints, 0);

% Internal control
params.DEBUG = 1;

% 0: no FIR, 1: parallel_FIR, 2: seperate FIR first
if modelParam.use_parallel_FIR == 2
    GoldenModel = modelParam.GoldenModel;
    [y_tmp_I, y_tmp_Q] = GoldenModel.func(x/GoldenModel.ScaleFactor);
    u_FIR = complex(y_tmp_I, y_tmp_Q) * GoldenModel.ScaleFactor;
    clear y_tmp_I y_tmp_Q;
    [model_FIR.coef] = Model_DPD(x(GoldenModel.offset:end), u_FIR, model_FIR, params);
    [uout_FIR, FIR_offset] = Apply_DPD(x, model_FIR, params);
    [model_APD.coef, model_APD.Basis] = Model_APD(uout_FIR, y(FIR_offset:end), model_APD, params);
else
    % Do sth fancy here
    if modelParam.use_parallel_FIR == 1
        model_APD.engine = strcat('Mod_',modelParam.engine);
        model_invAPD = model_APD;
        [model_APD.coef, model_APD.Basis] = Model_APD(x, y, model_APD, params);
        [model_invAPD.coef, model_invAPD.Basis] = Model_APD(y, x, model_invAPD, params);
        model_APD.engine = modelParam.engine;
        model_APD.coef = model_APD.coef(1:end-modelParam.FIR_M+1);
        model_invAPD.engine = modelParam.engine;
        model_invAPD.coef = model_invAPD.coef(1:end-modelParam.FIR_M+1);
    else
        model_invAPD = model_APD;
        [model_APD.coef, model_APD.Basis] = Model_APD(x, y, model_APD, params);
        [model_invAPD.coef, model_invAPD.Basis] = Model_APD(y, x, model_invAPD, params);
    end
    [u_out, u_offset] = Apply_APD(y, model_invAPD, params);
    x_in=x(u_offset:end);
    [model_FIR.coef] = Model_DPD(x_in, u_out, model_FIR, params);
end
coefficients = [model_FIR.coef; model_APD.coef];

% Verification
[output_FIR, offset_FIR] = Apply_DPD(x_ori, model_FIR, params);
[output_APD, offset_APD] = Apply_APD(output_FIR, model_APD, params);
x_dis = x_ori(offset_FIR+offset_APD-1:end);
y_dis = y_ori(offset_FIR+offset_APD-1:end);
NMSE = ModelCheck(x_dis, y_dis, output_APD);

disp([' *************************  ']);
disp([' NMSE = ', num2str(NMSE), ' dB' ]);
disp([' *************************  ']);

disp([' *************************  ']);
disp([' No. of coefficients ', num2str(size(coefficients,1)) ]);
disp([' *************************  ']);

end
