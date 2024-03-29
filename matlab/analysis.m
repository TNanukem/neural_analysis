%% Clean environment
clc;
clear all;
close all;

%% load data
raw_data = readtable('../data/record-[2018.11.16-10.16.29].csv');

t = table2array(raw_data(:, 1));
channels = table2array(raw_data(:, 3:end-3));
L = height(raw_data);
Fs = 512;
T = 1/Fs;


%% Display signals

signalPlot( channels, t, 'time (s)', 'channel signal', 'Time domain');

%% FFT analysis
fft_channels = fft(a);
P2 = abs(fft_channels/L);
P1 = P2(1:L/2+1, :);
P1(2:end-1, :) = 2*P1(2:end-1, :);

f = Fs*(0:(L/2))/L;

signalPlot(P1, f, 'f (Hz)', '|P1(f)|', 'Frequency Domain');

%% Filter Design

n = 2000;
Wn = [0.4 6]*2/Fs;
ffir = fir1(n, Wn, 'bandpass');
figure;
freqz(ffir,1,1024)

fdelay = mean(grpdelay(ffir));

%% Filter Data
filtered_signal = filter(ffir, 1, a);
t_filt = t(1:end-fdelay);
fsignal = filtered_signal(fdelay+1:end, :);

signalPlot( fsignal, t_filt, 'time (s)', 'channel signal', 'Filtered Signal Time domain');

%% FFT analysis for filtered signal
filtered_fft_channels = fft(filtered_signal);
filtered_P2 = abs(filtered_fft_channels/L);
filtered_P1 = filtered_P2(1:L/2+1, :);
filtered_P1(2:end-1, :) = 2*filtered_P1(2:end-1, :);

signalPlot(filtered_P1, f, 'f (Hz)', '|P1(f)|', 'Frequency Domain');

%%

function signalPlot(signal, t, xtitle, ytitle, bigtitle)
    n = size(signal, 2);
    nyfig = floor(sqrt(n));
    nxfig = ceil(n/nyfig);
    figure;
    for i = 1:n
        subplot(nxfig,nyfig,i);
        plot(t, signal(:, i));
        title(strcat('Channel ', num2str(i)))
        xlabel(xtitle)
        ylabel(ytitle)
    end
    sgtitle(bigtitle)
end