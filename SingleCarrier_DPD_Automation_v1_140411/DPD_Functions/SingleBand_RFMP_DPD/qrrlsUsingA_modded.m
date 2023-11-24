function [y,e,h1,h]=qrrlsUsingA_modded(A,d,L,lambda,delta,w,quantize,itnum)
% Notes
% A - A1 matrix
% d - desired vector
% L - number of coefficients (order + 1) * taps
% lambda - exponential weighting factor
% delta - regularization parameter
% w - current weights

% Adaptive transversal filter using RLS algorithm
%
%   [y,e,h1]=rls(x,d,L,lambda)
%
% input:
%   x   column vector containing the input samples x[n] (size(x)=[xlen,1])
%   d   column vector containing the samples of the desired output
%       signal d[n] (size(d)=[xlen,1])
%   L   number of coefficients
%   lambda "Vergessensfaktor"
%
% output:
%   y   column vector containing the samples of the output y[n] (size(y)=[xlen,1])
%   e   column vector containing the samples of the
%       error signal e[n] (size(e)=[xlen,1])
%   h1   matrix containing the coefficient vectors h[n]
%         size(h1) = [L,xlen+1]
%

if w == 0
    wn = zeros(L,1);
    wn(1,1) = 1;
else
    wn=w;
end

N = length(d);
%initialization
phi_sqrt = delta * eye(L);
p = zeros(L,1);
h1=zeros(L);

y = zeros(L,1);

for n=1:itnum
    an = A(n,:);
    progressbar(6/10+4/10*(n/(N+1)),1,0);
	[phi_sqrt, p, wn, e(n), y(n+L-1)] = QRRLSAlg(an.', d(n), wn, phi_sqrt, p, lambda);
    if strcmp(quantize, 'yes')
        % divide the weight matrix by DAC quantization level, then round,
        % then multiply back to obtain 'rounded' weights
        wn_quan = round(wn./(0.5/2^14)).*(0.5/2^14);
        if wn == wn_quan
            display('DAC is not accurate enough to resolve this change in weight!')
            display('Iteration stopped prematurely at: n =')
            n
            break;
        else
            wn = wn_quan;
        end
    end
	h1 = [h1 wn];
end
%     progressbar(1,1,1);

N = 0;
h = wn;

if itnum == 0
e = 0;
h1 = h
end