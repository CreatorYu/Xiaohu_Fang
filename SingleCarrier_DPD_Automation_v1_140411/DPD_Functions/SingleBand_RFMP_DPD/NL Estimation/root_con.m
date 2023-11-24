function [c,ceq] = root_con(coeff)
global max_sig M_DEN N_DEN MOD_DEN D
all_coeff = complex(coeff(1:0.5*length(coeff)),coeff(1+0.5*length(coeff):end));
den_coeff = all_coeff(size(D,2)+1:end);
% distance between the zeros and boundary of input values
epsilon = 0;
% -1 for c >= 0, +1 for c<= 0
mc = 1;
den_coeff = den_coeff.';

den_poly = zeros(M_DEN,N_DEN+1); 

    if MOD_DEN == 0 %even_odd
    den_poly = [1 den_coeff];
    
    elseif MOD_DEN == 1 %odd_only
    den_coeff = upsample(den_coeff,2);
    den_poly = [1 den_coeff];
    
    elseif MOD_DEN == 2 %even_only
    den_coeff = upsample(den_coeff,2,1);
    den_poly = [1 den_coeff]; 
    
    end

den_poly = fliplr(den_poly);
poly_roots = roots(den_poly);

mag_roots = abs(poly_roots);

% max_sig + epsilon <= mag_roots
% c <= 0
% Therefore:
c = max_sig + epsilon - mag_roots;
c = mc*c;
% ceq is another option
ceq = [];
end
