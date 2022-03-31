%% read in file
clear;
filename = 'file1.txt';
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
