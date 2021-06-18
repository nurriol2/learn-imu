clear all
clc
close all
time = 10;     % seconds
fs = 1;        % sampling frequency (Hz)
t = linspace(0,time,time*fs+1);
plot_time = 100;

% -------------------------------------------------------------------------
% Flicker Noise / Bias Instability (FN)
% -------------------------------------------------------------------------
N_FN = 0.005;
PSD_FN = N_FN^2;      % PSD of white noise (unit^2/Hz)
sigma_FN = sqrt(PSD_FN*fs);
alpha = 1;      % for 1/f^(alpha) noise
B = sigma_FN;

% -------------------------------------------------------------------------
% Simulation of Flicker Noise/Bias Instability
% -------------------------------------------------------------------------
% Define IIR filter truncation limits
numTerms = 3;
w_FN = randn(time*fs + 1,1);                % white noise ~ N(0,1)

% -------------------------------------------------------------------------
% Jerath
% -------------------------------------------------------------------------
% Re-initialize to seros in every run
x_FN = zeros(length(numTerms),time*fs+1);  
omega_FN = x_FN;
theta_FN = x_FN;
% Set up the IIR filter coefficients
a(1,1) = 1;
for(i=1:1:numTerms)
    a(1,i+1) = (i-1-alpha/2)*(a(1,i))/i;
end
x_FN(1:numTerms) = 0;

% -------------------------------------------------------------------------
% (Entry 0)
% Custom Implementation
% Claim that x_FN is an array of all 0s entering the for loop.
% So, multiplying by the IIR filter coeffs is pointless and Jerath is
% unecessarily complicating the conversion x_FN <==> wNew.
% 
% In custom implementation, we can just initialize an array of the right
% size. Then, add the same noise that is being added to x_FN. After exiting
% the for loop, we can do the same shuffling and end up with the same series.
%
% (Entry 1)
% Results of Entry 0 show that, in fact, the series are different. 
% Next, I will visualize the addition happening during each run of the
% for loop.
%
% (Entry 2)
% I have significantly reduced the number of terms, the sampling rate, and
% the time. With a smaller data set, it is easier to literally print out
% the array and parts contained in the for loop.
%
% (Entry 3)
% Under the assumption that reducing the number of terms, sampling rate, and
% time still produces flicker noise, I see that the addition `...+wNew(count)`
% places a sample from ~N(0,1) in `x_FN` at the start. Subsequent runs through
% the for loop then use neighboring values w/in x_FN and wNew to calc. the
% next value. 
% The first few runs simply place the exact sample inside x_FN because neighboring
% values are all 0. Eventually those 0s are overwritten with wNew samples. 
% So as the for loop executes, the white noise sample is being slightly adjusted
% by the value of the neighboring array elements. I believe this "nudge" is
% the action of "shaping white noise".
%
% (Note)
% My justifcation for why this makes sense is if we allow the code to plot
% the two series [Jerath vs. Custom implementation] we can see that the 
% custom implementation (which is essentially just plotting white noise)
% results in 2 **similar** looking series. Compared with each other, I think
% one can say *the white noise is being shaped*
% -------------------------------------------------------------------------

% Initialize an array of the right size
custom_FN = zeros(length(numTerms),time*fs+1);  

wNew = B.*w_FN;

% Generate the flicker noise
for(count = (numTerms+1):1:time*fs)
    disp("x_FN before the operation");
    disp(x_FN);

    x_FN(count+1) = -a(1,2:end)*(fliplr(x_FN(count-numTerms:count-1)))' ...
                                                            + wNew(count);
    
    disp('White noise sample wNew: ');
    disp(wNew(count));
    
    disp('x_FN after the operation');
    disp(x_FN);
    
    if mod(count, 100)==0
        % Visualize the addition
        disp('The `a`-like Coefficient');
        disp(-a(1,2:end));

        disp('Flipped x_FN');
        disp((fliplr(x_FN(count-numTerms:count-1)))');

        disp('White Noise');
        disp(wNew(count));
    end

    % Add the noise that's being added to x_FN
    custom_FN(count+1) = +wNew(count);                                                        
end

omega_FN = circshift(x_FN,[0 -numTerms]);
custom_omega = circshift(custom_FN,[0 -numTerms]);

theta_FN = (1/fs).*cumsum(circshift(x_FN,[0 -numTerms]));
custom_theta = (1/fs).*cumsum(circshift(custom_FN,[0 -numTerms]));

FN = omega_FN';
FN_BLUE = custom_omega';

% -------------------------------------------------------------------------
% Plotting
% -------------------------------------------------------------------------
h_fig = figure(5);
w_len = 12;
h_len = 16;
set(h_fig, 'Units', 'inches','Position',[1 0.5 w_len h_len]);
figure(1);

% Red is Jerath
subplot(121), plot(t, FN,'Linewidth',2,'Color',[1, 0.3, 0.3]);
% Blue is mine
subplot(122), plot(t, FN_BLUE,'Linewidth',2,'Color',[0, 0, 1]);

grid on;
