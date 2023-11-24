function [ EMP_coef ] = ConvertToEMP( M, N, MP_coef )

coef_MP = MP_coef;

coefs = zeros(1+M*N,1);
idx = 1;
for i = 1:(M*(N+1))
    first_coef = 0;
    if mod(i,N+1) == 1
        first_coef = first_coef + coef_MP(i);
    else
        idx = idx + 1;
        coefs(idx) = coef_MP(i);
    end
end
coefs(1) = first_coef;

EMP_coef = coefs;

end
