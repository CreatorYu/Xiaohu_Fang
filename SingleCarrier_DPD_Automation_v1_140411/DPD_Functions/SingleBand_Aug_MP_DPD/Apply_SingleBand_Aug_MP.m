function [PD_outI, PD_outQ] = Apply_SingleBand_Aug_MP(in_I, in_Q, modelParam, coefficients, gamma)

x = complex(in_I, in_Q);

% normalization
[norm_xI, norm_xQ] = setMeanPower(real(x), imag(x), 0); 
x = complex(norm_xI, norm_xQ);

N = modelParam.N;
M = modelParam.M;
model = modelParam.type; %type = 'odd' or 'odd_even'

x_added = [x', x(1:M-1)']';



% generate A matrix
    A = Generate_MP_Matrix(x_added, M, N, 'TRUEMP', model);

% generate B matrix
    for ind=1:1:size(A,2)
        B(:,ind) = A(:,ind).*abs(x_added(M:end));
    end

% use gamma to sum A and B
A = A+gamma*B;  

PD_out = A*coefficients;
PD_outI = real(PD_out);
PD_outQ = imag(PD_out);

end

