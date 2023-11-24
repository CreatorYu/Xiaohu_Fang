function setupScopeMath
% This function sets up the ScopeMath folder and subfolders into the MATLAB path

%   Copyright 1996-2012 The MathWorks, Inc.

    addpath(genpath(pwd));
    savepath;
    mex -setup 
end