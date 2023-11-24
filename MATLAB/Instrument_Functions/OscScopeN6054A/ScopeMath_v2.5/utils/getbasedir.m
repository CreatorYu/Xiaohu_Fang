function base = getbasedir
%% Get Base Dir helper function for finding help html files
% This is my home grown getbase address for finding relative files for
% help
% Home made function to return the base directory.

%   Copyright 1996-2012 The MathWorks, Inc.

p = which('ScopeMath');
[pathstr,basefile,ext]=fileparts(p);
base = strrep(lower(pathstr),'\','/');
end