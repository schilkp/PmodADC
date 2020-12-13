wv_select = 110;
fs = 41000;
data_select = double(data(wv_select,:));

t = linspace(0,size(data_select,2)/fs,size(data_select,2));
[A,f,p,o] = sine_fit(data_select,t,fs,set_point(wv_select));


plot_len = 200;
t_dat = linspace(0,plot_len/fs,plot_len);
t_sin = linspace(0,plot_len/fs,plot_len*10);

figure();
hold on;
plot(t_dat,data_select(1:plot_len));

y = sin(2*pi()*f*t_sin+p)*A+o;
plot(t_sin,y);