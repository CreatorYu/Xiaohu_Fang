function [Out_I, Out_Q] = normalizeDACpeak(In_I, In_Q, ExpansionMargin)

if nargin == 2
    ExpansionMargin = 1;
end

norm             = max(max(abs(In_I)), max(abs(In_Q))); % normalize I/Q data
Out_I            = In_I / norm * 10 ^ (- ExpansionMargin / 20);
Out_Q            = In_Q / norm * 10 ^ (- ExpansionMargin / 20);

end
