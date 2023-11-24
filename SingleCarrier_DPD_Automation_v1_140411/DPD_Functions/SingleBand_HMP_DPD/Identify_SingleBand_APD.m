function [coefficients, NMSE] = Identify_SingleBand_APD(modelParam, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints)

% Interchange input and output to model reverse PA
y_ori = complex(PA_in_I, PA_in_Q);
x_ori = complex(PA_out_I,PA_out_Q);

[x, y] = Extract_Signal_Peak(x_ori, y_ori, NofDPDPoints, 0);

% Internal control
params.DEBUG = 0;
% Hotfix for Static Engine Type
if(strcmp(modelParam.engine, 'Static'))
    modelParam.engine = 'MP';
    modelParam.M = 1;
end
[coefficients] = Model_APD(x, y, modelParam, params);

% Verification
model = modelParam;
model.coef = coefficients;
[APD_est_o, APD_est_os] = Apply_APD(x_ori, model, params);
APD_i = x_ori(APD_est_os:end);
APD_o = y_ori(APD_est_os:end);
NMSE = ModelCheck(APD_i, APD_o, APD_est_o);

disp([' *************************  ']);
disp([' NMSE = ', num2str(NMSE), ' dB' ]);
disp([' *************************  ']);

disp([' *************************  ']);
disp([' No. of coefficients ', num2str(size(coefficients,1)) ]);
disp([' *************************  ']);

end
