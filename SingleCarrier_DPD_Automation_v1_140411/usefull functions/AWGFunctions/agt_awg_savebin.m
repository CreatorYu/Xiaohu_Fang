function [errorcode, errorcode_description] = agt_awg_savebin(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% Function description:
%   This function takes in a 1D waveform vector, scales the data between
%   (+/-)1 , performs the necessary data shifting and bit alignments,
%   and creates a "<filename>.bin" file in the current working directory.
%   If users do not prefer to scale the data, please use 0 for the optional
%   input.  By default, the optional input is 1.
%
% How to call the function:
%   function [errorcode, errorcode_description] = agt_awg_savebin(filename,vector)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   filename                  string    character string describing the
%                                       name of the *.bin file to be created
%   vector                    real      data vector to be converted to .bin
%                                       file.
%   optional                  integer   0: do not scale.
%                                       1: scale.  By default, 1 is used.
% Local Variables:
%   dimensions                real      holds size of input vector
%   maxAmp                    float     maximum value of abs(vector)
%   scale                     float     data shifting variable = ((2^15)-1)
%
% See Also:  savemarkerbin.m  
%
if (nargin < 2) 
    error('Incorrect number of input arguments.');
end

if(nargin == 3)
    if(isnumeric(varargin{3}) ~= 1)
        error('Invalid input value for argument 3.');
    end
end    

dimensions = size(varargin{2});
if((min(dimensions) > 1) || (length(dimensions) > 2))
    error('Waveform must be a 1 diminesional numeric array.');
end

if(max(dimensions) < 64)
    error('Waveform must have at least 64 samples.');
end

if ( mod(length(varargin{2}),8) ~= 0 ) 
    error('Vector length must be divisible by 8.');
end

if ( isreal(varargin{2}) ~= 1 ) 
    error('Complex values exist in data vector.');
end

if ( ischar(varargin{1}) ~= 1 )
    error('Incompatible file type.');
end
    

filename = [(varargin{1}),'.bin'];

% Convert to column vector
if( dimensions(1) > dimensions(2) )
    vector = varargin{2};
else
    vector = varargin{2}';
end
    
% scaling
if(~(nargin == 3 && varargin{3} == 0))
    maxAmp = max(abs(vector));
    vector = vector/maxAmp;  %  normalize vector to +/- 1.
end


scale = (2^15-1);
vector = round(scale * vector);  %  data shift, DAC accepts integers only.

% bit Move
vector = vector ;    % MSB alignment



% save    
fid = fopen( filename, 'wb' );
fwrite( fid, vector, 'short' );
fclose( fid );
   
errorcode = 0;
errorcode_description = ' ';


