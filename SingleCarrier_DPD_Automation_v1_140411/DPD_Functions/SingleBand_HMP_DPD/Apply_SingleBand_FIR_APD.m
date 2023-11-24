function [PD_outI, PD_outQ, offset] = Apply_SingleBand_FIR_APD(in_I, in_Q, modelParam, coefficients)

% Hotfix for Static Engine Type
if(strcmp(modelParam.engine, 'Static'))
    modelParam.engine = 'MP';
    modelParam.APD_M = 1;
end

% [norm_xI, norm_xQ] = setMeanPower(in_I, in_Q, 0);
x = complex(in_I, in_Q);
FIR_M = modelParam.FIR_M;
model_APD.N = modelParam.APD_N;
model_APD.M = modelParam.APD_M;
model_APD.architecture = modelParam.architecture;
model_APD.engine = modelParam.engine;
model_APD.polyorder = modelParam.polyorder;
model_APD.two_step = modelParam.two_step;
model_APD.coef = coefficients(FIR_M+1:end);
% FIR is just a N = 0 DPD
model_FIR.M = FIR_M;
model_FIR.N = 0;
model_FIR.architecture = 'multiply';
model_FIR.engine = 'MP';
model_FIR.polyorder = modelParam.polyorder;
model_FIR.two_step = modelParam.two_step;
model_FIR.coef = coefficients(1:FIR_M);
% Internal control
params.DEBUG = 0;
[output_FIR, offset_FIR] = Apply_DPD(x, model_FIR, params);
[output_APD, offset_APD] = Apply_APD(output_FIR, model_APD, params);

offset = offset_FIR + offset_APD - 1;

PD_outI = real(output_APD);
PD_outQ = imag(output_APD);

end
