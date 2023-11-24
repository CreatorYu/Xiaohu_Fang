function [PD_outI, PD_outQ] = Apply_SingleBand_CascadedTB(in_I, in_Q, modelParam, EMP_coeff, FIR_coeff)

%modelParam has the following structure:
FIR_M = modelParam(:,1);
EMP_M = modelParam(:,2);
EMP_N = modelParam(:,3);
model = modelParam(:,4);

%type = 'odd' or 'odd_even';
if model == 0
    model = 'odd_even';
elseif model == 1
    model = 'odd';
elseif model == 2
    model = 'odd_aug';
end

x = complex(in_I, in_Q);

if FIR_M > 1
    % generate FIR matrix
    B = Generate_MemPoly_Matrix(x, FIR_M, 0, 'MP', 'odd_even');
    u = B*FIR_coeff;
else
    u = x;
end

% generate EMP matrix
A = Generate_MemPoly_Matrix(u, EMP_M, EMP_N, 'H_EMP', model);

PD_out = A*EMP_coeff;
PD_outI = real(PD_out);
PD_outQ = imag(PD_out);

end