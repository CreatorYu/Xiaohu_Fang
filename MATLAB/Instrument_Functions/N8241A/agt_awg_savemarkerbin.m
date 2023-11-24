function [errorcode, errorcode_description] = agt_awg_savemarkerbin(varargin)
% Agilent N6030 Series Matlab Interface, Release 1.25
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
%
% Function description:
%   This function takes in one or two 1D marker vectors (marker1 and marker2) and
%   creates a binary marker file, writing the binary data to the "<filename>.bin" 
%   file in the current working directory.  The marker vectors must be of
%   size = (# of waveform elements/Sync clk divide ratio).  The Sync clk divide 
%   ratio breakdown is as follows:
%
%   Sampling Frequency(MHz)             Sync clk divide ratio
%       625-1250                                    8
%       312.5-625                                   4
%       156.25-312.5                                2
%       100-156.25                                  1
%
%   In using this function, either 2 or 3 input arguments are required,
%   with the leading argument being the filename.  If only marker 1 is specified,
%   it will be duplicated in marker 2.  Marker values must be 0 or 1.
%
%   While waveforms are stored as 16 bit data, markers are stored as 8 bit
%   data.
%
% How to call the function:
%   function [errorcode, errorcode_description] = agt_awg_savebin(filename,marker1,marker2)
%
% Output:        
%   errorcode               integer     less than 0 is an error (IVI error)
%   errorcode_description   string      error/warning message
% Input:
%   filename                string      character string describing the
%                                       name of the *.bin file to be created
%   marker1                 real        data vector to be converted to .bin
%                                       file, data should be 0 or 1.
%   marker2                 real        data vector to be converted to .bin
%                                       file, data should be 0 or 1.
% Local Variables:
%   dimensions              real        holds size of the marker vectors
%   vector                  integer     used to align marker1 and marker2
%                                       as 2 consecutive column vectors,
%                                       respectively.
%   out_vector              integer     8 bit number representation of
%                                       marker1 and marker2.  marker2 is the 
%                                       msb and marker1 is the next bit to the
%                                       left.
%   iter                    integer     iterates from marker1 to marker2        
%
% See Also:  savebin.m  
%

if ( (nargin < 2) || (nargin > 3) )
    error('Incorrect number of input arguments.');
end

for iter = 2:nargin
    dimensions = size(varargin{iter});
    if((min(dimensions) > 1) || (length(dimensions) > 2))
         error('Each marker vector must be 1D.');
    end

    if(max(dimensions) < 8)  %  (min. waveform samples)/(max sync clk prescalar ratio)
        error('Incorrect number of samples, see agt_awg_savemarkerbin.m help file');
    end

    if ( mod((length(varargin{iter})*8),16) ~= 0 )  %  Coarse check of marker vector size.  
         error('Incorrect number of samples, see agt_awg_savemarkerbin.m help file');
    end

    if ( isreal(varargin{iter}) ~= 1 ) 
        error('Complex values exist in data vector.');
    end
end

if ( nargin == 3)
    if ( (length(varargin{2})) ~= (length(varargin{3})) )
        error('Markers must be of same length.');
    end
end

if ( ischar(varargin{1}) ~= 1 )
    error('Incompatible file type.');
end
    

filename = [(varargin{1}),'.bin'];

% Convert to column vector
for iter = 2:nargin
    dimensions = size(varargin{iter});
    if( dimensions(1) > dimensions(2) )
        vector(:,(iter-1)) = varargin{iter};
    else
        vector(:,(iter-1)) = varargin{iter}';
    end
end

%  if only 1 marker specified, assign it to both marker 1 and marker 2.
if (nargin == 2) 
    vector(:,2) = vector(:,1); 
end
%  convert markerst to 8 bit integer (marker 2 = msb 1, marker 1 = msb 2).    
out_vector = (((2^7).*vector(:,2)) + ((2^6).*vector(:,1)));

% save    
fid = fopen( filename, 'wb' );
fwrite( fid, out_vector, 'uint8' );  %  write binary file, with data stored ...
fclose( fid );  %  as 8 bit integers.
   
errorcode = 0;
errorcode_description = ' ';


