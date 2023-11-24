function varargout = smEyeDiagram(x, t, n, varargin)
%EYEDIAGRAM Generate an eye diagram.
%   [T, A] = EYEDIAGRAM(X, T, N) generates data for eye diagram of X with N samples per
%   trace.  TIME is needed for consistency with SCOPEMATH API. N must be an integer greater than 1.  X can be a real or complex
%   vector, or a two-column matrix with real signal in the first column and
%   imaginary signal in the second column.  If X is a real vector, EYEDIAGRAM
%   generates data for one eye diagram.  If X is a two-column matrix or a complex
%   vector, EYEDIAGRAM generates data for two supersimposed eye diagrams, one for the real (in-phase)
%   signal and one for the imaginary (quadrature) signal. 
%   T contains time values for the eyediagram. A contains Amplitude values
%   for the eye diagram.
%
%   [T, A] = EYEDIAGRAM(X, N, PERIOD) generates data for an eye diagram of X with specified trace
%   period.  PERIOD is used to determine the horizontal axis limits.  PERIOD
%   must be a positive number.  The horizontal axis limits are -PERIOD/2 and
%   +PERIOD/2.  The default value of PERIOD is 1.
%
%   [T, A] = EYEDIAGRAM(X, N, PERIOD, OFFSET) generates an eye diagram of X with an
%   offset.  OFFSET determines which points are centered on the horizontal axis
%   starting with the (OFFSET+1)st point and every Nth point thereafter.  OFFSET
%   must be a nonnegative integer in the range 0 <= OFFSET < N.  The default
%   value for OFFSET is 0.
%
%   See also SCATTERPLOT, PLOT, SCATTEREYEDEMO.

%   Copyright 1996-2012 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $ $Date: 2005/06/27 22:16:36 $

% error(nargchk(2,6,nargin));
% error(nargoutchk(2,2,nargout));

if nargout ==3
    varargout{1} = 'Time [sec]';
    varargout{2} = 'Amplitude [V]';
    varargout{3} = 'Eye diagram';
    return;
end;


if nargin < 3
    n = 4;
end
if nargin < 4
    period = 1;
else
    % convert PERIOD to Double data type if needed
    if ~isa(period, 'float')
        period = double(period);
    end
end;

if nargin < 5
    offset = 0;
else
    % convert OFFSET to Double data type if needed
    if ~isa(offset, 'float')
        offset = double(offset);
    end
end;

if nargin < 6
    plotstring = 'b-';
end;

if nargin < 7
    h = [];
end;

% convert N to Double data type if needed
if ~isa(n,'float')
    n = double(n);
end

[r, c] = size(x);
if r * c == 0
    error('comm:eyediagram:EmptyX','Input variable X is empty.')
end;
% don't allow t to be zero or negative
if (period <= 0)
    error('comm:eyediagram:NonPositivePeriod','PERIOD must be a positive number.')
end

% don't allow n to be noninteger or less than or equal zero
if ((floor(n) ~= n) || (n <= 1))
    error('comm:eyediagram:InvalidN', 'N must be an integer greater than 1.')
end

% don't allow offset to be outside of the range 0 <= offset < n
if ((floor(offset) ~= offset) || (offset < 0) || (offset >= n))
    error('comm:eyediagram:InvalidOffset', 'OFFSET must be a integer in the range 0 <= OFFSET < N.')
end

% flatten input
if r == 1
    x = x(:);
end;

% Complex number processing
if ~isreal(x) > 0
    x = [real(x), imag(x)];
end;
maxAll = max(max(abs(x)));

% generate normalized time values
[len_x, wid_x]=size(x);
t = rem([0 : (len_x-1)]/n, 1)';

% wrap right half of time values around to the left
tmp = find(t > rem((offset/n+0.5),1) + eps^(2/3));
t(tmp) = t(tmp) - 1;

% if t = zero is at an edge, make it the left edge
if(max(t)<=0)
    t = t + 1;
end;


% determine the right-hand edge points
% for zero offset, the index value of the first edge is floor(n/2)+1
index = fliplr(1+rem(offset+floor(n/2),n) : n : len_x);

% for plotting, insert NaN values into both x and t after each edge point
% to define the left edge,after the NaNs repeat the ith value of x
% and insert a value that is (period/n) less than the (i+1)th value of t
NN = ones(1, wid_x) * NaN;
for ii = 1 : length(index)
    i = index(ii);
    if i < len_x
        x = [x(1:i,:);   NN;     x(i,:); x(i+1:size(x, 1),:)];
        t = [t(1:i);    NaN; t(i+1)-1/n; t(i+1:size(t, 1))  ];
    end;
end;

% adjust the time values to ensure that the x axis remains fixed
half_n = n/2-1;
modoffset = rem(offset+half_n,n)-half_n;
t = rem(t-modoffset/n,1);

% scale time values by period
t = t*period;

varargout{1} = t;
varargout{2} = x;




