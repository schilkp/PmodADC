% Measure ADC Output over a range of DC inputs
% Input Preamp/Filter/AC Coupling *bypassed*.

% Calibrate offset?

% Block 1: 0-1
% Block 2: 0.95-2
% Block 3: 1.95-3
% Block 4: 2.95-4
% Block 5: 3.95-5
% Block 6: 4.95-5.1

input_steps = 4.95:0.0003:5.1;
n_steps = size(input_steps,2);
samples_per_step = 100;

data = uint16(zeros(n_steps,samples_per_step));
set_point = zeros(n_steps,1);
prog_up = ProgressUpdate(n_steps,1);

% Open Connection:
com = serialport('COM6', 9600, 'Timeout', 0.1);

% Open SMU
% Instrument Connection
SMU = keysight_B2902A('USB0::0x0957::0x8C18::MY51145396::0::INSTR'); %find usb string with tmtool

% configure
SMU.configure_source(1, 'VOLT', 10e-3); %sset to voltage, compliance 1mA
SMU.set_output(1,'ON');
SMU.configure_measurement(1,10e-3);

pause(4);

% Perform Measurement:
for step = 1:n_steps
   voltage = input_steps(step); 
   
   % Set Voltage
   SMU.set_output_value(1,voltage);
   
   pause(0.01);
   
   % Read from ADC
   adc_read_openport(com, 2100);
   [reading, fail_count] = adc_read_openport(com,samples_per_step+4);
   
   % Stop if there was a problem with package decoding:
   if fail_count > 2
      disp('Package decode error!');
      disp(['Failcount: ',num2str(fail_count)]);
      clear com;
      break;
   end
   
   % Get rid of extra readings:
   reading = reading(1:samples_per_step,:);
   
   % Save
   data(step,:) = reading.';
   
   prog_up.Update(step)

   [voltage_m, current_m] = SMU.get_measurement(1);
   set_point(step) = voltage_m;
   
end

% quit
SMU.disconnect();

save ADC_Lin_Block6.mat;

clear com;

mean_read = mean(data')';
plot(set_point,mean_read);

% Look at: 
%   INL, DNL
%   Monotonicity
%   Noise at different inputs?
