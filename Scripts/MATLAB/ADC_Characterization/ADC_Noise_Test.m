% Analyze ADC noise with shorted input.
collect_n_samples = 41000*30;
collect_from_port = 'COM8';

% If there is no data, collect it
if(~exist('noise_data','var'))
    disp('No noise_data found, collecting samples....');
    noise_data = adc_read(collect_from_port, collect_n_samples);
end

noise_mean = mean(noise_data);
noise_max = max(noise_data);
noise_min = min(noise_data);
noise_span = noise_max - noise_min;
noise_std = std(double(noise_data));

disp('Mean Reading: ');
disp(noise_mean);

disp('Max Reading: ');
disp(noise_max);

disp('Min Reading: ');
disp(noise_min);

disp('Span of Readings: ');
disp(noise_span);

disp('Std. Deviation of Readings: ');
disp(noise_std);


% Plot distribution of sample probablilty
[count, val] = groupcounts(noise_data);
count = count/sum(count);

f1 = figure('Name','ADC Noise Sample Probablity');
bar(val, count, 1);
title('ADC Noise Sample Probablity');
xlabel('Raw ADC reading'); 
ylabel('Sample Probability'); 

f2 = figure('Name','ADC Noise Sample Probablity (Log)');
bar(val, count, 1);
title('ADC Noise Sample Probablity (Log)');
xlabel('Raw ADC reading');
ylabel('Sample Probability (Log)');
set(gca, 'YScale', 'log');
