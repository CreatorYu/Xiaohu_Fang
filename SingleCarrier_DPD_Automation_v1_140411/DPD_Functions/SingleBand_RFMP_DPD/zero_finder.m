function [real_zeros, imag_zeros] = zero_finder(den_coeff, M_DEN, N_DEN, MOD_DEN)

    all_coeff = den_coeff.';
    den_poly = zeros(M_DEN,N_DEN+1); 
    reps = length(den_coeff)/M_DEN;
    real_zeros = [];
    imag_zeros = [];
    
for mem = 1:1:M_DEN
    
    if MOD_DEN == 0 %even_odd
        den_poly(mem,:) = [1 all_coeff(reps*(mem-1)+1:reps*(mem))];

    elseif MOD_DEN == 1 %odd_only
        temp = all_coeff(reps*(mem-1)+1:reps*(mem));
        temp = upsample(temp,2);
        temp = temp(1:end-1);
        den_poly(mem,:) = [1 temp];

    elseif MOD_DEN == 2 %even_only
        temp = all_coeff(reps*(mem-1)+1:reps*(mem));
        temp = upsample(temp,2,1);
        den_poly(mem,:) = [1 temp]; 
    end

    den_poly(mem,:) = fliplr(den_poly(mem,:));
    real_den_poly = real(den_poly(mem,:));
    imag_den_poly = imag(den_poly(mem,:));
    r_zeros = roots(real_den_poly); 
    i_zeros = roots(imag_den_poly);

    r_zeros(imag(r_zeros) ~= 0) = 0;
    i_zeros(imag(i_zeros) ~= 0) = 0;

    r_zeros(real(r_zeros) < 0) = 0;
    i_zeros(real(i_zeros) < 0) = 0;

    % plot the zeros
    %span |x| from logspace -10 to 0
    absx_span = logspace(-10,0,10000);

    %plot real(poly) and imag(poly) vs. |x|
    den_out = polyval(den_poly(mem,:),absx_span);
    figure();
    subplot(2,1,1)
    H1 = plot(absx_span, real(den_out));
    set(H1,'Color','k');
    AX = gca
    set(AX,'YColor','k','Ylim',[-1 1])
    hl1 = refline(0,0);
    set(hl1,'Color','k','LineStyle','--');
    
    subplot(2,1,2)  
    H2 = plot(absx_span, imag(den_out));
    set(H2,'Color','m');
    AX = gca
    set(AX,'YColor','m','Ylim',[-1 1])
    hl2 = refline(0,0);
    set(hl2,'Color','m','LineStyle','--');
    %find values where function changes sign, and store them

        real_zeros = [real_zeros;r_zeros];
        imag_zeros = [imag_zeros;i_zeros]; 
end
    
end