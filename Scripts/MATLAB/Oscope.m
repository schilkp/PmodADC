port = 'COM6';
interval = 1000;
fs = 41000;

t = linspace(0,1/fs*interval,interval);
figure();

while true
   [data, fail_count] = adc_read(port,interval);
   if fail_count == 0
       plot(t,data);
       ylim([0 2^14-1]);
   end
end