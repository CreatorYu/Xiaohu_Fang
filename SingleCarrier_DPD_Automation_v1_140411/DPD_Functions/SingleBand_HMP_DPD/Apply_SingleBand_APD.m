function [PD_outI, PD_outQ] = Apply_SingleBand_APD(in_I, in_Q, modelParam, coefficients)

% [norm_xI, norm_xQ] = setMeanPower(in_I, in_Q, 0);
x = complex(in_I, in_Q);

% Hotfix for Static Engine Type
if(strcmp(modelParam.engine, 'Static'))
    modelParam.engine = 'MP';
    modelParam.M = 1;
end

model = modelParam;
model.coef = coefficients;
% Internal control
params.DEBUG = 0;
[PD_out, PD_out_offset] = Apply_APD(x, model, params);
% N = modelParam.N;
% M = modelParam.M;
% engine = modelParam.engine;
% polyorder = modelParam.polyorder; %type = 'odd' or 'odd_even'
%
% A = Generate_MemPoly_Matrix(x, M, N, engine, polyorder);
% if strcmp(modelParam.architecture, 'multiply')
% 	output = A*coefficients;
% elseif strcmp(modelParam.architecture, 'add')
% 	output = A*coefficients + x(M:end);
% end

% % Not needed on testbench
% % output = [x(1:PD_out_offset-1); output];

PD_outI = real(PD_out);
PD_outQ = imag(PD_out);

end
