function iqshowcorr(filename)
% plot the magnitude correction (and phase correction if available)
% If a filename is given, will take information from that file.
% Otherwise will take default file: ampCorr.mat
%
% Agilent Technologies, Thomas Dippon, 2011-2013
%
% Disclaimer of Warranties: THIS SOFTWARE HAS NOT COMPLETED AGILENT'S FULL
% QUALITY ASSURANCE PROGRAM AND MAY HAVE ERRORS OR DEFECTS. AGILENT MAKES 
% NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND WITH RESPECT TO THE SOFTWARE,
% AND SPECIFICALLY DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR A PARTICULAR PURPOSE.
% THIS SOFTWARE MAY ONLY BE USED IN CONJUNCTION WITH AGILENT INSTRUMENTS. 

if (~exist('filename'))
    filename = iqampCorrFilename();
end

if (exist(filename, 'file'))
    load(filename);
    figure(10);
    clf(10);
    hold off;
    if (size(ampCorr,2) > 2)  % complex correction available
        phase = -1 * 180 / pi * unwrap(angle(ampCorr(:,3)));
        subplot(2,1,1);
        plot(ampCorr(:,1), -1*ampCorr(:,2), '.-');
        xlabel('Frequency (Hz)');
        ylabel('dB');
        grid on;
        subplot(2,1,2);
        plot(ampCorr(:,1), phase, 'm.-');
        xlabel('Frequency (Hz)');
        ylabel('degree');
        grid on;
        set(10, 'Name', 'Frequency and Phase Response');
    else
        plot(ampCorr(:,1), -1 * ampCorr(:,2), '.-');
        set(10, 'Name', 'Frequency Response');
        xlabel('Frequency (Hz)');
        ylabel('dB');
        grid on;
    end
else
    errordlg('No correction file available. Please use "Calibrate" to create a correction file');
end
