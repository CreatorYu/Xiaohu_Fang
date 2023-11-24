function fun_N6705_Voltage_Set(Lan_addr,V_chan,chan)

visa_str = sprintf('TCPIP0::%s::hislip0::INSTR', Lan_addr); 
            obj.socket = visa('agilent', visa_str);
            fopen(obj.socket);
            ident = query(obj.socket, '*IDN?');
            fprintf('Connected to power supply: %s\n', ident);   
  %  
          % V_Chan1=2.12; chan1=1;
fprintf(obj.socket, ['VOLT ' num2str(V_chan) ',(@' num2str(chan) ')']);
                         
     fclose(obj.socket);
    fprintf('Disconnected from power supply\n');   
end