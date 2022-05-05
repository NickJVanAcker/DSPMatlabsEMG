%% read in file + sorting header
clear;
lowerbandpass = 30;
upperbandpass = 50;
filename = 'file1.txt';
matrix = readmatrix(filename);
matrix(:,1:2) = [];
linesOfFile = readlines(filename);
headerline = linesOfFile(2); % header is on the second line
headerline = convertStringsToChars(headerline); % needed for further use
headerline(1:24) = []; %remove chars to be able to read in as jsonobject
headerline = headerline(1:end-1); %remove chars to be able to read in as jsonobject
headerobject = jsondecode(headerline);
date = headerobject.date;
time = headerobject.time;
Fs = headerobject.samplingRate;   %sampfreq
resolution = headerobject.resolution;

%% Removing outline
matrix = rmoutliers(matrix,'mean','ThresholdFactor',2); %Change 2 to x for desired outliner removal

%% Function 
n = resolution(1); % not always 16 for each channel. improved version that checks channel per column necessairy?
VCC = 3;
gemg = Fs;
emg = (((matrix/2^n) - (1/2)) * VCC) / gemg; %in V
emg= emg*1000; %to mV


%%fast fourier transform first column 
%%fastfourrier
%TODO other lines
Fn = Fs/2;                                          % Nyquist Frequency
L = numel(emg(:,1));                                % Signal Length
FTs = fft(emg(:,1))/L;                              % Fourier Transform first column
Fv = linspace(0, 1, fix(L/2)+1)*Fn;                 % Frequency Vector

%% parametrized band-pass filter
FTs = bandpass(FTs, [lowerbandpass,upperbandpass], Fs);
%% 
Iv = 1:numel(Fv);                                   % Index Vector
figure
plot(Fv, abs(FTs(Iv))*2)
grid
xlabel('Frequency')
ylabel('Amplitude')

