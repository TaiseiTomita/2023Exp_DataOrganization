%% 計測データの変換専用



PostProcessingSetting;
T_new = loadExpDataTable(ExpParentPath);

T_new = T_new(T_new.No > 113000,:);
disp("データの変換")
for i = 1:size(T_new,1)    
    
    
    RUNNUMBER = T_new.RUNNUMBER(i);
    
    disp(RUNNUMBER)
    [TT, CamTrigger1T, CamTrigger2T, CamTrigger3T,err] = DataRecordMaker2(ExpParentPath,RUNNUMBER,GL840VarNames);
    T_new.Convert(i) = err;
    if err;continue;end
    fnameMT = append(RUNNUMBER,"_MeasuredDataTT");
    assignin('base',fnameMT,TT)
    fnameCam1TT = append(RUNNUMBER,"_CamTrigger1T");
    assignin('base',fnameCam1TT,CamTrigger1T)
    fnameCam2TT = append(RUNNUMBER,"_CamTrigger2T");
    assignin('base',fnameCam2TT,CamTrigger2T)
    fnameCam3TT = append(RUNNUMBER,"_CamTrigger3T");
    assignin('base',fnameCam3TT,CamTrigger3T)
    fname = append(RUNNUMBER,"_MeasuredData");
    save(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat")),fnameMT,fnameCam1TT,fnameCam2TT,fnameCam3TT,'-mat');
    clear("fname*")

  
end

fname = append("NewDataT",string(datetime('now','Format','_uuuuMMdd')));
assignin('base',fname,T_new)
save(fullfile(ExpParentPath,"MATLAB/MAT/",append(fname,".mat")),fname,'-mat');