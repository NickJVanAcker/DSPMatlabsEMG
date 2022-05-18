clear;
maxMVC = zeros(5,1); %preallocation for more efficiency

%global variables (for ui)
desiredoutlineval = 2; %decideds the Standard diviation used in outline removal/fill
%will need to be changable via gui, for readability kept in current place
    %filenamematrixfs = ["S1_score_fast.txt"; "S1_score_slow.txt"]; %fs --> fastslow
    %filenamematrix = ["S1_MVC_delt_links.txt"; "S1_MVC_delt_rechts.txt";"S1_MVC_ECR_rechts.txt";"S1_MVC_trapezius_rechts.txt";"S1_MVC_trapezius_links.txt"];

%% MVC inladen en maximum bepalen
% bv delt links is is te zien op kanaal 3 (kolom 3) delt rechts op kanaal 4
filenamematrix = ["S1_MVC_delt_links.txt"; "S1_MVC_delt_rechts.txt";"S1_MVC_ECR_rechts.txt";"S1_MVC_trapezius_rechts.txt";"S1_MVC_trapezius_links.txt"]; 
kanaal = [3 4 5 2 1]; % op welk kanaal worden deze spieren ingelezen (kolom)


for c = 1:5
    filename = filenamematrix(c,:);
    matrix = readmatrix(filename);
    matrix(:,1:2) = [];
    kanaalnummer = kanaal(c);
    %inlezen parameters
    linesOfFile = readlines(filename);
    headerline = linesOfFile(2); % header is on the second line
    headerline = convertStringsToChars(headerline); % needed for further use
    headerline(1:24) = []; %remove chars to be able to read in as jsonobject
    headerline = headerline(1:end-1); %remove chars to be able to read in as jsonobject
    headerobject = jsondecode(headerline);
    datemvc = headerobject.date;
    timemvc = headerobject.time;
    Fsmvc = headerobject.samplingRate;   %sampfreq
    resolutionmvc = headerobject.resolution;

% verwijderen van outlines: verwijderen en vervangen door gemiddelde
% waarden onder en boven.
matrixzonderoutliers = filloutliers(matrix,'center','mean','ThresholdFactor', desiredoutlineval); 
%matrix omzetten naar mv
matrix = toMV(matrix,resolutionmvc,Fsmvc);
% Maximum bepalen
maximumValue = max(matrix,[],1); %selects max value of all columns, used for later selection
maxMVC(kanaalnummer,1) = maximumValue(kanaalnummer); %matrix which stores max values of each column in correct 
% order for future use assuming future use is:
%kanaal 1 = M. Trapezius Descendens (links)
%kanaal 2 = M. Trapezius Descendens (rechts)
%kanaal 3 = M. Deltoïdeus Anterior (links)
%kanaal 4 = M. Deltoïdeus Anterior (rechts)
%kanaal 5 = M. Extensor Carpi Radialis (dominante kant)
end

%% Inlezen Score fast and slow
%issue might be c == 1 is hardcoded to score fast
filenamematrixfs = ["S1_score_fast.txt"; "S1_score_slow.txt"];
for c = 1:2
    filenamefs = filenamematrixfs(c,:);
    matrixfs = readmatrix(filenamefs);
    matrixfs(:,1:2) = [];
  
    linesOfFile = readlines(filenamefs);
    headerline = linesOfFile(2); % header is on the second line
    headerline = convertStringsToChars(headerline); % needed for further use
    headerline(1:24) = []; %remove chars to be able to read in as jsonobject
    headerline = headerline(1:end-1); %remove chars to be able to read in as jsonobject
    headerobject = jsondecode(headerline);
    date = headerobject.date;
    time = headerobject.time;
    Fs = headerobject.samplingRate;   %sampfreq
    resolution = headerobject.resolution;
    
    %question to ask, filter outliners?
    matrixfswithoutoutliers = filloutliers(matrixfs,'center','mean','ThresholdFactor', 3);

    if c == 1
        matrixfastmv = toMV(matrixfs,resolution,Fs);
        normscorefast = zeros(numel(matrixfs)/5,5);    %preallocation for more efficiency    
    else
        matrixslow = toMV(matrixfs,resolution,Fs);
        normscoreslow = zeros(numel(matrixfs)/5,5);    %preallocation for more efficiency
    end

     matrixfs = toMV(matrixfs,resolution,Fs); %change matrixfs to withoutliers if selected
    
    % Normalisatie data
    for x = 1:5
        if c == 1
            normscorefast(:,x) = matrixfs(:,x)/maxMVC(x,1); %normalized scores for score_fast
        else
            normscoreslow(:,x) = matrixfs(:,x)/maxMVC(x,1); %normalized scores for score_fast
        end
    end
end

%{ 
    function used in toMV.m here displayed for readability
    function returnval = toMV(matrix,resolution,Fs)
        n = resolution(1); % not always 16 for each channel. improved version that checks channel per column necessairy?
        VCC = 3;
        gemg = Fs;
        emg = (((matrix/2^n) - (1/2)) * VCC) / gemg; %in V
        emg= emg*1000; %to mV
        returnval = emg;
    end
%}

%% fast fourier transform 
tiledlayout(5,2)
for channel = 1:5
    nexttile
    emg = matrixfastmv;  %matrixfs hardcoded because of uncertainty need for both fast/slow
    Fn = Fs/2;                                          % Nyquist Frequency
    L = numel(emg(:,channel));                                % Signal Length
    FTs = fft(emg(:,channel))/L;                              % Fourier Transform first column
    Fv = linspace(0, 1, fix(L/2)+1)*Fn;                 % Frequency Vector
    Iv = 1:numel(Fv);  
    title(['channel: ' num2str(channel)]) %doesn't work for some reason
  %  plot(Fv, abs(FTs(Iv))*2) %gebruiken om zonder bandpass te showen
     FTsvector(:,channel) = FTs; %holds all fourrier values

    %% bandpass filter (heeft soms iets decent gedaan, kan close zijn)
    order = 2;  %AANPASSEN VIA UI
    lowerbandpass = 50;     %AANPASSEN VIA UI
    upperbandpass = 150;    %AANPASSEN VIA UI
    FTs = abs(FTs);
    [b,a] = butter(order,[lowerbandpass,upperbandpass]/Fn,'bandpass'); % fs/2 --> nyquist freq (samplerate/2)
    %[b,a] = cheby1(order,1,[0.4 0.7]); %potentieel andere filter optie?

    filtsig=filter(b,a,FTs);
    bandpassfilter(:,channel) = filtsig; %holds all bandpass filtered data
    %figure()
    plot(Fv, abs(filtsig(Iv))*2, Fv, abs(FTs(Iv))*2)
    legend('Filterd','non-filtered')
    xlim([0 350])
end

