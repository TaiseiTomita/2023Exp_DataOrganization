%%
% エクセルファイルからテーブルをロード

% if not(exist("PostProcessing_CalibrationDataTransferRunning","var"))
    PostProcessingSetting;
    T0 = loadExpDataTable(ExpParentPath);
% end


T = T0(T0.No > 101700 & T0.No < 112800,"RUNNUMBER");


%% キャリブレーションデータの計測
CamLabelNo = 3;

for  i= 1:height(T)
    RUNNUMBER = T.RUNNUMBER(i);
    disp(RUNNUMBER)
    T.(append(string(CamLabelList(CamLabelNo)),"CalibDataSave"))(i) = 0;

    CamNo = T0.(append(string(CamLabelList(CamLabelNo)),"Camera"))(T0.RUNNUMBER == RUNNUMBER);
    sCamNo = string(CamNo);
    if CamNo == "None";continue;end

    fname = append(RUNNUMBER,"_",append(string(CamLabelList(CamLabelNo)),"CalibrationData"));
    if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat"))) && not(CalibDataFourceOverWrite)
        T.(append(string(CamLabelList(CamLabelNo)),"CalibDataSave"))(i) = -1;
        continue;
    elseif isfolder(fullfile(ExpParentPath,"Measured",RUNNUMBER))
        [R,err] = generateCaliblationData(ExpParentPath,RUNNUMBER,CalibCropRect.(string(CamLabelList(CamLabelNo))),sCamNo);
        if err;continue;end

        assignin('base',fname,R)
        save(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat")) ...
            ,fname,'-mat');
        T.(append(string(CamLabelList(CamLabelNo)),"CalibDataSave"))(i) = 1;
    else
        T.(append(string(CamLabelList(CamLabelNo)),"CalibDataSave"))(i) = 0;
    end
end

fname = append(append(string(CamLabelList(CamLabelNo)),"NewCalibrationT",string(datetime('now','Format','_uuuuMMdd'))));
assignin('base',fname,T)
save(fullfile(ExpParentPath,"MATLAB/MAT/",append(fname,".mat")),fname,'-mat');

disp(T)
disp("-1:Skip - 計測せず")
disp("0:error - 失敗：ファイルがない？")
disp("1:ok - 成功")
disp("")