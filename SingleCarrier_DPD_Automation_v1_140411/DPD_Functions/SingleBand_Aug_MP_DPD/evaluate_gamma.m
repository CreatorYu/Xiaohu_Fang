function NMSE = evaluate_gamma(gamma)

    global C_Aug_MP y;

    A1 = C_Aug_MP;
    Y1 = y;

    gamma = complex(gamma(1), gamma(2));

    A1 = A1(:,1:size(A1,2)/2) + gamma*A1(:,size(A1,2)/2+1:size(A1,2));
    size(A1);
    size(Y1);
    Y1_est = A1*(pinv(A1,1e-5)*Y1);
    NMSE = 10*log10(mean(((abs(Y1-Y1_est).^2)/mean(abs(Y1)).^2)));
    
end