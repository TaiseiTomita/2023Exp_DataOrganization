function [PixelPerMm,err] = loadCalibDataEachRun(ExpParentPath,RUNNUMBER)
    err = false;
    matfname = append(RUNNUMBER,"_CalibrationData");
    if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(matfname,".mat"))) == 0
        disp("NO MeasuredData file!!!")
        err = true;
        return;
    end
    m = matfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(matfname,".mat")));
    PixelPerMm = m.PixelPerMm;
end