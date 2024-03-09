PostProcessingSetting;
%% 

answer = questdlg(Excelfilename, ...
	'Is the name of excel file ​​set correctly?', ...
	'Yes','No','Yes');
if strcmp(answer,'No')
    disp('Please reset parameters in MATLAB\PostProcessingSetting.m')
    return
end

answer = questdlg(DocsHDDDrivePrefix, ...
	'Is the path of external HDD Drive ​​set correctly?', ...
	'Yes','No','Yes');
if strcmp(answer,'No')
    disp('Please reset parameters in MATLAB\PostProcessingSetting.m')
    return
end

%%
[excelReadResults,T_new] = filetransfer(DataHDDDrivePrefix,DocsHDDDrivePrefix,ExpParentPath,Excelfilename);
% 
if isfile(fullfile(ExpParentPath,"MATLAB/MAT/ExpDataTable.mat"))
    movefile(fullfile(ExpParentPath,"MATLAB/MAT/ExpDataTable.mat"),...
        fullfile(ExpParentPath,"MATLAB/MAT/backup/",append("ExpDataTable_",string(datetime('now','Format','uuuuMMddHHmmss')),".mat")))
end

text = "Update ExpDataTable";
fileID = fopen(fullfile(matlabFolderPath,"MAT/ExpDataTable.log"),"a");
str = append("updated:",string(datetime('now','Format','uuuu/MM/dd HH:mm:ss')),", comments:",text);
fprintf(fileID,'%s \n',str);fclose(fileID);

fname = "ExpDataTable";
assignin('base',fname,excelReadResults)
save(fullfile(ExpParentPath,"MATLAB/MAT/",append(fname,".mat")),fname,'-mat');

%% データ整理（新規にコピーしたフォルダのみ）
disp("データの変換")
T_new2 = T_new;
for i = 1:size(T_new,1)    
    disp(T_new.RUNNUMBER(i))
    
    if T_new.Transfer(i) == 1
        [TT, CamTrigger1T, CamTrigger2T, CamTrigger3T,err] = DataRecordMaker2(ExpParentPath,T_new.RUNNUMBER(i),GL840VarNames);
        if err;continue;end
        fnameMT = append(T_new.RUNNUMBER(i),"_MeasuredDataTT");
        assignin('base',fnameMT,TT)
        fnameCam1TT = append(T_new.RUNNUMBER(i),"_CamTrigger1T");
        assignin('base',fnameCam1TT,CamTrigger1T)
        fnameCam2TT = append(T_new.RUNNUMBER(i),"_CamTrigger2T");
        assignin('base',fnameCam2TT,CamTrigger2T)
        fnameCam3TT = append(T_new.RUNNUMBER(i),"_CamTrigger3T");
        assignin('base',fnameCam3TT,CamTrigger3T)
        fname = append(T_new.RUNNUMBER(i),"_MeasuredData");
        save(fullfile(ExpParentPath,"Measured",T_new.RUNNUMBER(i),append(fname,".mat")),fnameMT,fnameCam1TT,fnameCam2TT,fnameCam3TT,'-mat');
        clear("fname*")

        T_new2.MeasuredData{i} = TT;
        T_new2.CamTrigger1TT{i} = CamTrigger1T;
        T_new2.CamTrigger2TT{i} = CamTrigger2T;
        T_new2.CamTrigger3TT{i} = CamTrigger3T;
    end
end

fname = append("NewDataT",string(datetime('now','Format','_uuuuMMdd')));
assignin('base',fname,T_new2)
save(fullfile(ExpParentPath,"MATLAB/MAT/",append(fname,".mat")),fname,'-mat');
% disp("この後の手順について")
% disp("1 : excelReadResultsにエクセルファイルの読み込み結果が入っています。内容を確認し、誤り等がある場合には「実験用HDD内のエクセルファイル」を修正して再度PostProcessing_0を実行してください。")
% disp("基本的に後で修正することは（データの信頼性の観点からも作業のめんどくささからも）推奨しません。")
% disp("2 : LabVIEWで画像をコンバートしてください．")
% disp("3 : PostProcessing_1 を実行してください．")
% disp("4 : PostProcessing_2 を実行してください．")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% ローカル関数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% ファイル転送
function [T,T_new] = filetransfer(DataHDDDrivePrefix,DocsHDDDrivePrefix,ExpParentPath,Excelfilename)

    % 実験条件記録用紙の転送
    % すでに同名のファイルが存在する場合は古いファイルをbackup
    if isfile(fullfile(ExpParentPath,"Docs",Excelfilename))
        movefile(fullfile(ExpParentPath,"Docs",Excelfilename), ...
            fullfile(ExpParentPath,"Docs","backup",insertBefore(Excelfilename,'.xlsx',string(datetime('now','Format','_uuuuMMddHHmmss')))));
    end
    % 転送
    copyfile(fullfile(DocsHDDDrivePrefix,"Docs",Excelfilename),fullfile(ExpParentPath,"Docs",Excelfilename));
    
    % エクセルファイルからテーブルをロード
    T = loadexcelfile(ExpParentPath,Excelfilename);
    T_new = T(:,"RUNNUMBER");

    % Measured Dataの転送
    for i = 1:height(T_new)
        if isfolder(fullfile(ExpParentPath,"Measured",T_new.RUNNUMBER(i)))
            T_new.Transfer(i) = -1;%フォルダが既存の場合はスキップ
        else
            T_new.Transfer(i) = double(copyfile(fullfile(DataHDDDrivePrefix,"Measured",T_new.RUNNUMBER(i)),fullfile(ExpParentPath,"Measured",T_new.RUNNUMBER(i))));
        end
    end
        disp(T_new)
    disp("-1:skip - 転送先フォルダが既存")
    disp("0:error - 何らかの要因で転送できず")
    disp("1:ok - 成功")
    disp("")
end

% function T = DataRecordMaker2(ExpParentPath,RUNNUMBER,T_new,GL840VarNames)
% 
%     % MeasuredDataのフォルダパスを設定
%     DataFolderPath = fullfile(ExpParentPath,"Measured");
% 
%     % 実験データ保存用のレコード
% 
% 
%     [YT,~] = size(T);
% 
%     if YT == 1
%         % GL840のデータのcsv fileをtable変数に
%         [GL840TempTT,GL840VoltTT] = convert2Table_GL840Data2(DataFolderPath,RUNNUMBER,GL840VarNames);
% 
%         % 精密空調機の温度データのcsv fileをtable変数に
%         [PAPTT,~] = convert2Table_PAP01B(DataFolderPath,RUNNUMBER);
% 
%         % Velocity fileをtable変数に
%         [Others1TT,~] = convert2Table_Others1file(DataFolderPath,RUNNUMBER);
% 
%         % 計測データをタイムテーブルに変換,結合
%         % GL840のデータとPAPのデータを一つのタイムテーブルに同期、サンプリング時間を等間隔に修正
%         TT = synchronize(GL840TempTT,GL840VoltTT,PAPTT,'regular','linear','SampleRate',5);
%         TT = synchronize(TT,Others1TT(:,{'TunnelState'}),'first','nearest');
% 
%         %風洞運転状態を追加
%         TT = addstate(TT);
% 
%         Cam1TriggerT = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,1);
%         Cam2TriggerT = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,2); 
%         Cam3TriggerT = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,3); 
%         % Cam2TriggerT = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,1); 
%         % Cam3TriggerT = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,1); 
%         % Cam4TriggerT = convert2Table_cameraTriggerData(DataFolderPath,RUNNUMBER,1); 
%         % [Cam1TT,Cam2TT] = ImageDataPostProcessing(ExpParentPath,DataTable,RUNNUMBER);
% 
%         table2timetable(Cam1TriggerT,"RowTimes","")
% 
%         % データをテーブルに結合
%         T.MeasuredData{1} = TT;
%         T.CamTrigger1TT{1} = Cam1TriggerT;
%         T.CamTrigger2TT{1} = Cam2TriggerT;
%         T.CamTrigger3TT{1} = Cam3TriggerT;
% 
%         disp("データ変換完了")
% %         T.TwAccuracy(1) = max(abs(TT.TPlate(TT.state == "experiment") - T.Tw(1)));
% %         T.TwAccuracyCheck(1) = T.TwAccuracy(1) < Tw_accuracyThrehold;
%     elseif YT == 0
%         T.MeasuredData{1} = table;
%         T.CamTrigger1TT{1} = table;
%         T.CamTrigger2TT{1} = table;
%         T.CamTrigger3TT{1} = table;
%     else
%         disp("RUNNUMBERが重複しています．データ変換できませんでした．")
%     end
% 
% end