function SignalGenerator_E8257D(E8257D_addr,freq,power,status)
%         freq=1e9;
%         power=-20;
%         status=1;
%         E8257D_addr='192.168.1.103';
       % TCPIP0::%s::hislip0::INSTR
        % connect to signal generator
            %old_obj = instrfind('PrimaryAddress', obj.GPIB_addr);  %use GPIB
            old_obj = instrfind('PrimaryAddress', E8257D_addr);   %use LAN
            %delete(old_obj);
            %visa_str = sprintf('GPIB0::%d::INSTR', obj.GPIB_addr);  %use GPIB
            visa_str = sprintf('TCPIP0::%s::5025::SOCKET', E8257D_addr);  %conbine LAN address
            freq_str = sprintf(':FREQ %dGHz',freq/1e9); %conbine freq struct
            power_str = sprintf(':POW %ddBm',power); %conbine power struct
            RF_switch = sprintf(':OUTPut %d',status); %conbine RF switch struct:1 RF ON;0,RF OFF
            obj.socket = visa('agilent', visa_str);
            fopen(obj.socket);
            ident = query(obj.socket, '*IDN?');
            fprintf('Connected to signal generator: %s\n', ident);   
            %fprintf(obj.socket, '*RST');                     % reset the PSG 
            fprintf(obj.socket, freq_str);    % set/get frequency 
            fprintf(obj.socket, power_str);      % set/get power
            fprintf(obj.socket, RF_switch);        % RF on:1 /off:0  
            fclose(obj.socket);
            fprintf('Disconnected from signal generator\n');                       
end
