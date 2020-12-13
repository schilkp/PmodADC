% Measure actual DAC DC Output voltage at different DAC setpoints
% Output Buffer/Filter/AC Coupling *bypassed*.

input_steps = uint16(0:1:2^14-1);   % Step Size?, Min/Max?
% input_steps = uint16(0:1000:2^14-1);

n_steps = size(input_steps,2);

data = zeros(n_steps, 1);
set_point = zeros(n_steps, 1);

prog_up = ProgressUpdate(n_steps,5);

% Open Connection:
com = serialport('COM6', 9600, 'Timeout', 0.1);

% Open SMU

% Instrument Connection
SMU = keysight_B2902A('USB0::0x0957::0x8C18::MY51145396::0::INSTR'); %find usb string with tmtool

% configure
SMU.configure_source(1, 'VOLT', 100e-9); %set to voltage, compliance
SMU.configure_measurement(1,10e-3);
SMU.set_output(5.5,'ON');

pause on;

% Perform Measurement:
for step = 1:n_steps
   setting = input_steps(step); 
   
   % Set the DAC
   dac_play_openport(com,setting);
   
   % Let DAC settle
   pause(0.01);
   
   % Read DAC Output Voltage
   [voltage_m, current_m] = SMU.get_measurement(1);
    
   % Save
   data(step,1) = voltage_m;
   set_point(step,1) = setting;
   
   prog_up.Update(step)
end

% quit
SMU.disconnect();

save DAC_Lin.mat;

clear com;

% Look at: 
%   INL, DNL
%   Monotonicity
%   Noise at different inputs?
