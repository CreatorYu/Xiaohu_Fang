function [fmNewCorr, frNewP, frNewWeight, fError, fOutput] = QRRLSAlg(frInput, ...
										fDesired, frWeight, fmCorr, frP, fLambda)
%QRRLSALG The QR based Recursive LS Algorithm
%	frInput - Input vector U
%	fDesired - desired output
%	frWeight - weight vector W (n-1)
%	fmCorr - Matrix R (n-1)
%	frP - Matrix y_hat (n-1)
%	fLambda - adjustment factor
%	Returns [fmNewP, frNewWeight, fError, fOutput]
%	fmNewCorr - Updated matrix R (n)
%	frNewWeight - Updated weight vector W (n)
%	frNewP - Updated Matrix y_hat (n)
%	fError - estimation error
%	fOutput - calculated output
%   quan_step - if '1', then weights will be updated in multiples of
%   the smallest DAC output (may cause convergence problems)




M = length(frInput);

Block11 = sqrt(fLambda) * fmCorr;
Block12 = sqrt(fLambda) * frP;
Block21 = frInput.';
Block22 = fDesired;


MatrixPreviousSample = [Block11 Block12; Block21 Block22];

[Q, MatrixCurrentSample] = qr(MatrixPreviousSample);

fmNewCorr = MatrixCurrentSample(1:M, 1:M);
frNewP = MatrixCurrentSample(1:M, M+1);



for n=M:-1:1
	frRowCorr = fmNewCorr(n,n:end);
	if(n ~= M)
		b = frRowCorr(2:end) * frNewWeight(n+1:end,1);
	else
		b = 0;
	end
	frNewWeight(n,1) = (frNewP(n) - b) / frRowCorr(1);
    
end



% Get estimated output, and error
fOutput = frWeight.' * frInput;
fError = fDesired - fOutput;


