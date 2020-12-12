t = 0:(1/41000):60;
y = sin(2*pi()*1000*t);
audio = dac_scale_audio(y);
dac_play('COM6',audio');