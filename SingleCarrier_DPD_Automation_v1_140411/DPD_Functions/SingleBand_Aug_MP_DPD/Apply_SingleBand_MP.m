function [PD_outI, PD_outQ] = Apply_SingleBand_MP(in_I, in_Q, modelParam, coefficients)

x = complex(in_I, in_Q);
[norm_xI, norm_xQ] = setMeanPower(real(x), imag(x), 0); 
x = complex(norm_xI, norm_xQ);

N = modelParam.N;
M = modelParam.M;
model = modelParam.type; %type = 'odd' or 'odd_even'

x_added = [x', x(1:M-1)']';

% generate A matrix
    A = Generate_MP_Matrix(x_added, M, N, 'TRUEMP', model);

PD_out = A*coefficients;
PD_outI = real(PD_out);
PD_outQ = imag(PD_out);

end
