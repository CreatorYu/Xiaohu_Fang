% Agilent N6030 Series Matlab Interface, Release 1.20.1.0
% Copyright © 2004,2005,2006 Agilent Technologies, Inc.
function sync_arbs
% Example showing how to synchronize two N6030 series arbs.
%

clc

ch1 = csvread('50MHz.csv');
ch2 = ch1;
waveform = [ ch1; ch2 ];

% Try to open a session, you need to put your instruments hostname or IP address into the VISA address below
% Host name defaults to A-[model number]-[last 5 digits of serial #]
% Host name VISA address would like: 'TCPIP0::A-N8241A-90123::inst0::INSTR' for a N8241A with a serial # of US45090123
% IP based VISA address would like: 'TCPIP0::196.196.196.196::inst0::INSTR' for an IP address of 196.196.196.196

disp('Opening a session to the instrument');
    [instrumentHandle2, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::A-N8241A-90xxx::inst0::INSTR');
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            return;
        else
            disp('ok');
        end

    [instrumentHandle1, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::A-N8241A-90xxx::inst0::INSTR');
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
			agt_awg_close( instrumentHandle2 );
            return;
        else
            disp('ok');
        end

disp('Enabling the instrument output');
    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle1, 'outputenabled', 'true');
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return;
        else
            disp('ok');
        end

    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle2, 'outputenabled', 'true');
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return;
        else
            disp('ok');
        end

disp('Setting the instrument to ARB mode');
    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle1, 'outputmode', 'arb');
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return;
        else
            disp('ok');
        end

    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle2, 'outputmode', 'arb');
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end

disp('Setup the Master');
    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle1, 'syncmode', 'master');
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end
    
disp('Setup the Slave');
    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle2, 'syncmode', 'slave');
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('proram stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
           return
        else
            disp('ok');
        end

disp('Transfering the waveform to the instrument');
    [ waveformHandle, errorN, errorMsg ] = agt_awg_storewaveform( instrumentHandle1, waveform);
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end

    [ waveformHandle, errorN, errorMsg ] = agt_awg_storewaveform( instrumentHandle2, waveform);
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end

disp('Initiating playback of the waveform on the instrument');
    [ errorN, errorMsg ] = agt_awg_playwaveform( instrumentHandle2, waveformHandle );
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end
    
    [ errorN, errorMsg ] = agt_awg_playwaveform( instrumentHandle1, waveformHandle );
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end

disp('Init Generation');
    [ errorN, errorMsg ] = agt_awg_initiategeneration(instrumentHandle2);
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end
        
    [ errorN, errorMsg ] = agt_awg_initiategeneration(instrumentHandle1);
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
           return
        else
            disp('ok');
        end
        
disp('Press ENTER to close the instrument session and conclude this example.');
pause;

disp('Abort Generation');
    [ errorN, errorMsg ] = agt_awg_abortgeneration(instrumentHandle2);
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end
        
    [ errorN, errorMsg ] = agt_awg_abortgeneration(instrumentHandle1);
        if errorN ~= 0
            disp(errorN);
            disp(errorMsg);
            disp('program stopped');
            agt_awg_close( instrumentHandle1 );
			agt_awg_close( instrumentHandle2 );
            return
        else
            disp('ok');
        end
            

agt_awg_close( instrumentHandle1 );
agt_awg_close( instrumentHandle2 );

disp('Session to the instrument closed successfully.');



