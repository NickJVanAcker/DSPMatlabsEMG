%% read in file + sorting header
clear;
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
sampfreq = headerobject.samplingRate;
resolution = headerobject.resolution;

%% Function 
n = resolution(1); % not always 16 for each channel. improved version that checks channel per column necessairy?
VCC = 3;
gemg = sampfreq;
emg = (((matrix/2^n) - (1/2)) * VCC) / gemg; %in V
emg= emg*1000; %to mV


