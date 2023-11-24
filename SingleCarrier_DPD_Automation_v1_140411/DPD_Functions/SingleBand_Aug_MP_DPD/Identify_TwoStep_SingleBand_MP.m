function [coefficients, NMSE, Cond_A] = Identify_TwoStep_SingleBand_MP(modelParam, PA_in_I, PA_in_Q, PA_out_I, PA_out_Q, NofDPDPoints)
%coefficients = 'aij' for base memory polynomial

%modelParam has the following structure:
N = modelParam.N;
M = modelParam.M;
model = modelParam.type; %type = 'odd' or 'odd_even'

% interchange x and y
x = complex(PA_out_I(1:NofDPDPoints),PA_out_Q(1:NofDPDPoints));
PA_in = complex(PA_in_I(1:NofDPDPoints), PA_in_Q(1:NofDPDPoints));
% y = PA_in(M:length(PA_in));
y = PA_in(1:length(PA_in));

% normalization
[norm_yI, norm_yQ] = setMeanPower(real(y), imag(y), 0); 
[norm_xI, norm_xQ] = setMeanPower(real(x), imag(x), 0); 

y = complex(norm_yI, norm_yQ);
x = complex(norm_xI, norm_xQ);

% generate memoryless A matrix
A = [];
for count1 = 1:N
    [A] = [A x.*(abs(x)).^(count1 - 1)];    
end

% use LSE to solve for coefficients
coefficients = (pinv(A,1e-5)*y);

Cond_A = cond(A);

y_est = A*coefficients;
NMSE = 10*log10(mean(((abs(y-y_est).^2)/mean(abs(y)).^2)))

A2 = y_est;
for count2 = 1:M
    [A2] = [A2 y_est.*circshift(abs(x),count2)];    
end

coefficients2 = (pinv(A2,1e-5)*y);

Cond_A = cond(A);

y_est2 = A2*coefficients2;
NMSE = 10*log10(mean(((abs(y-y_est2).^2)/mean(abs(y)).^2)))

PlotGain_WithWithout(real(x),imag(x),real(y),imag(y),real(y_est2),imag(y_est2)) ;
PlotAMPM_WithWithout(real(x),imag(x),real(y),imag(y),real(y_est2),imag(y_est2)) ;

disp([' *************************  ']); 
disp([' NMSE = ', num2str(NMSE), ' dB' ]);
disp([' *************************  ']);

disp([' *************************  ']); 
disp([' No. of coefficients ', num2str(size(coefficients,1)) ]);
disp([' *************************  ']);

end