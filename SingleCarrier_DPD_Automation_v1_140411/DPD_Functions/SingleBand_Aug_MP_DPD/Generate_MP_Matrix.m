function [output] = Generate_MP_Matrix(input, M, N, modification, polyorder)

    if strcmp(polyorder,'odd')
        A = zeros(length(input)-M+1,M*(floor(N/2)+1));
        incr = 2;
    elseif strcmp(polyorder,'odd_even')
        A = zeros(length(input)-M+1,(N+1)*M);
        incr = 1;
    end

    for n=M:length(input)
            A1 = [];
            for t=1:M
                for Expon = 0:incr:N
                    switch modification
                        case 'ENV-MP'
                            A1 = [A1 input(n)*(abs(input(n-t+1)).^ Expon)];
                        case 'TRUEMP'
                            A1 = [A1 input(n-t+1)*(abs(input(n-t+1)).^ Expon)];
                        otherwise
                            display('Error: Modification choice not recognized')
                        break;
                    end

                end

            end
            A(n-M+1,:) = A1(:);
    end

    output = A;
    