function returnval = RMSwindow(matrix, window)
%function takes the matrix and returns an RMS matrix
    AmountOfRows = size(matrix,1);
    AmountOfCollumn = size(matrix,2);
    for channelrms  = 1:AmountOfCollumn
        for  rowrms = 1:AmountOfRows-window
            rmsmatrix(rowrms,channelrms) = rms(matrix(rowrms:rowrms+window,channelrms));
        end
    end
    returnval = rmsmatrix;
end