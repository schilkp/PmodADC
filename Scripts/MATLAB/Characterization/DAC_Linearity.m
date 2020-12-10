% Measure actual DAC DC Output voltage at different DAC setpoints
% Output Buffer/Filter/AC Coupling *bypassed*.

% Calibrate offset?

input_steps = uint16(9:1:2^14-1);   % Step Size?, Min/Max?

n_steps = size(input_steps,2);

samples_per_step = 10;  % ?

data = zeros(n_steps, samples_per_step);

prog_up = ProgressUpdate(n_steps,5);

% Open Connection:
com = serialport('COM8', 9600, 'Timeout', 0.1);

pause on;

% Perform Measurement:
for step = 1:n_steps
   setting = input_steps(step); 
   
   % Set the DAC
   dac_play_openport(com,setting);
   
   % Let DAC settle
   pause(0.01); % ??? Ok?
   
   % Read samples_per_step

   % Save
   data(step,:) = % TODO
   
   prog_up.Update(step)
   
end

clear com;

% Look at: 
%   INL, DNL
%   Monotonicity
%   Noise at different inputs?
