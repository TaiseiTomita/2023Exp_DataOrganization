function [TT,TriggerT,err] = loadMeasuredDataEachRun(ExpParentPath,RUNNUMBER)
    err = false;
    matfname = append(RUNNUMBER,"_MeasuredData");
    if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(matfname,".mat"))) == 0
        disp("NO MeasuredData file!!!")
        err = true;
        TT = timetable;
        TriggerT = table;
        return;
    end
    fname = append(RUNNUMBER,"_MeasuredDataTT");
    m = matfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(matfname,".mat")));
    TT = m.(fname);
    TriggerT.CamTrigger1T = m.(append(RUNNUMBER,"_CamTrigger1T"));
    TriggerT.CamTrigger2T = m.(append(RUNNUMBER,"_CamTrigger2T"));
    TriggerT.CamTrigger3T = m.(append(RUNNUMBER,"_CamTrigger3T"));
end