% Measure AC Output at different frequenciess 
% DAC Standard Config.

% Calibrate offset?
% Dropped Samples!???
% Store/Process?
% Async play?

input_steps = 5:10:30000;   % Step Size?, Min/Max?

n_steps = size(input_steps,2);

fs = 41000;
stimulus_length = 1;  % in seconds 

prog_up = ProgressUpdate(n_steps,5);

% Stimulus timebase:
t = 0:(1/fs):stimulus_length;

% Open Connection:
com = serialport('COM8', 9600, 'Timeout', 0.1);

% Perform Measurement:
for step = 1:n_steps
   f = input_steps(step); 
   
   % Generate stimulus
   y = sin(2*pi()*f*t);
   
   % Async play?
   
   % Data Record? Data Process?
   
   prog_up.Update(step)
end

clear com;

