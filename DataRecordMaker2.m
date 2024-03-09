function [TT, CamTrigger1T, CamTrigger2T, CamTrigger3T,err] = DataRecordMaker2(ExpParentPath,RUNNUMBER,GL840VarNames)
%UNTITLED7 この関数の概要をここに記述
%   詳細説明をここに記述

    % MeasuredDataのフォルダパスを設定
    DataFolderPath = fullfile(ExpParentPath,"Measured");

    if not(isfile(fullfile(DataFolderPath,RUNNUMBER,append(RUNNUMBER,'_Temp_GL840.csv'))) && ...
        isfile(fullfile(DataFolderPath,RUNNUMBER,append(RUNNUMBER,'_Volt_GL840.csv'))) && ...
        isfile(fullfile(DataFolderPath,RUNNUMBER,append(RUNNUMBER,'_PAP01B.csv'))) && ...
        isfile(fullfile(DataFolderPath,RUNNUMBER,append(RUNNUMBER,'_Others.csv'))) && ...
        isfile(fullfile(DataFolderPath,RUNNUMBER,append(RUNNUMBER,'_CamTrigger1.csv'))) && ...
        isfile(fullfile(DataFolderPath,RUNNUMBER,append(RUNNUMBER,'_CamTrigger2.csv'))) && ...
        isfile(fullfile(DataFolderPath,RUNNUMBER,append(RUNNUMBER,'_CamTrigger3.csv'))))
        
        TT = timetable;
        CamTrigger1T=table;
        CamTrigger2T=table;
        CamTrigger3T=table;
        err=true;
        disp(RUNNUMBER+" : データ変換エラー")
    end
    
    % GL840のデータのcsv fileをtable変数に
    [GL840TempTT,GL840VoltTT] = convert2Table_GL840Data2(DataFolderPath,RUNNUMBER,GL840VarNames);
    
    % 精密空調機の温度データのcsv fileをtable変数に
    [PAPTT,~] = convert2Table_PAP01B(DataFolderPath,RUNNUMBER);
    
    % Velocity fileをtable変数に
    [Others1TT,~] = convert2Table_Others1file(DataFolderPath,RUNNUMBER);
    
    % 計測データをタイムテーブルに変換,結合
    % GL840のデータとPAPのデータを一つのタイムテーブルに同期、サンプリング時間を等間隔に修正
    TT = synchronize(GL840TempTT,GL840VoltTT,PAPTT,'regular','linear','SampleRate',5);
    TT = synchronize(TT,Others1TT(:,{'TunnelState'}),'first','nearest');

    %風洞運転状態を追加
    TT = addstate(TT);
    
    CamTrigger1T = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,1);
    CamTrigger2T = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,2); 
    CamTrigger3T = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,3); 
    
    disp("データ変換完了")
    err=false;
end