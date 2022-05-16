function returnval = toMV(matrix,resolution,Fs)
%function takes the matrix, the resolution and sampfreq and will return the
%mv values of the given matrix
    n = resolution(1); % not always 16 for each channel. improved version that checks channel per column necessairy?
    VCC = 3;
    gemg = Fs;
    emg = (((matrix/2^n) - (1/2)) * VCC) / gemg; %in V
    emg= emg*1000; %to mV
    returnval = emg;
end