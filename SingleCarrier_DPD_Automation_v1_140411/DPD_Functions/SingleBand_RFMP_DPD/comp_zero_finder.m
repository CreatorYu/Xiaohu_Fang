function [all_zeros] = comp_zero_finder(den_coeff, M_DEN, N_DEN, MOD_DEN)

all_coeff = den_coeff.';
den_poly = zeros(M_DEN,N_DEN+1); 
reps = length(den_coeff)/M_DEN;
all_zeros = []
for mem = 1:1:M_DEN

    if MOD_DEN == 0 %even_odd
        den_poly(mem,:) = [1 all_coeff(reps*(mem-1)+1:reps*(mem))];
    elseif MOD_DEN == 1 %odd_only
        temp = all_coeff(reps*(mem-1)+1:reps*(mem));
        temp = upsample(temp,2);
        den_poly(mem,:) = [1 temp];
    elseif MOD_DEN == 2 %even_only
        temp = all_coeff(reps*(mem-1)+1:reps*(mem));
        temp = upsample(temp,2,1);
        den_poly(mem,:) = [1 temp]; 
    end

    den_poly(mem,:) = fliplr(den_poly(mem,:));
    comp_zeros = roots(den_poly(mem,:));
    % test to see if zeros are actually zeros
    
    for ind=1:length(comp_zeros)
       polyval(den_poly(mem,:),comp_zeros(ind))
    end
    all_zeros = [all_zeros; comp_zeros];
end