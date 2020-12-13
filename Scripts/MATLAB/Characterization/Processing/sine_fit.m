function [A, f, p, o] = sine_fit(x,t,fs,f_guess)

    % shorten data to approx. 20 periods or max length:
    T = 1/f_guess;
    T = 20*T;
    len = round(min(T*fs,length(x)));
    x = x(1,1:len);
    t = t(1,1:len);
    
    % Determine Guesses    
    A_guess = max(x)-min(x);
    o_guess = mean(x);
    
    % General sinousoid:
    fit = @(b,x) b(1).*(sin(2*pi()*t*b(2) + b(3))) + b(4); 
    
    % Cost Function:
    fcn = @(b) sum((fit(b,t) - x).^2); 
    
    
    options = optimset('MaxFunEvals',32000,'MaxIter',32000);
    s = fminsearch(fcn, [A_guess, f_guess, 0, o_guess],options);
    
    A = s(1);
    f = s(2);
    p = s(3);
    o = s(4);
end 