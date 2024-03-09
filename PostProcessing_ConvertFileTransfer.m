PostProcessingSetting;
%%
% エクセルファイルからテーブルをロード

ExcelT = loadExpDataTable(ExpParentPath);

disp("データの転送")
[~,T_Cam1] = filetransfer(Cam1HDDDrivePrefix,ExpParentPath,ExcelT,1,logical(CamTransferSkip(1)));
[~,T_Cam2] = filetransfer(Cam2HDDDrivePrefix,ExpParentPath,ExcelT,2,logical(CamTransferSkip(2)));
[~,T_Cam3] = filetransfer(Cam3HDDDrivePrefix,ExpParentPath,ExcelT,3,logical(CamTransferSkip(3)));
[~,T_Cam4] = filetransfer(Cam4HDDDrivePrefix,ExpParentPath,ExcelT,4,logical(CamTransferSkip(4)));

T = T_Cam1(:,"RUNNUMBER");
T.Cam1 = T_Cam1.Transfer;
T.Cam2 = T_Cam2.Transfer;
T.Cam3 = T_Cam3.Transfer;
T.Cam4 = T_Cam4.Transfer;

clear T_Cam?
fname = append("NewConvertT",string(datetime('now','Format','_uuuuMMdd')));
assignin('base',fname,T)
save(fullfile(ExpParentPath,"MATLAB/MAT/",append(fname,".mat")),fname,'-mat');

disp(T)
disp("-3:skip - 撮影しているが，データなし")%Excel上は撮影したことになっているが，データが見つからない
disp("-2:skip - 撮影なし")
disp("-1:skip - 転送先フォルダが既存")
disp("0:error - 何らかの要因で転送できず")
disp("1:ok - 成功")
disp("")

%% ローカル関数

%% ファイル転送
function [ExcelT,T_new] = filetransfer(HDDDrivePrefix,ExpParentPath,ExcelT,CamNo,Skip)
    arguments
        HDDDrivePrefix  (1,1) string 
        ExpParentPath  (1,1) string 
        ExcelT (:,:) table
        CamNo (1,1) double
        Skip (1,1) logical
    end

    T_new = ExcelT(:,"RUNNUMBER");
    T_new=addvars(T_new,zeros(height(T_new),1),'NewVariableNames',"Transfer");

    if Skip;return;end
    
    CamLogical = ExcelT.(num2str(CamNo,"Cam%d"));
    % Convert Dataの転送
    for i = 1:height(T_new)
        disp(append(num2str(CamNo,"Cam%d : "),T_new.RUNNUMBER(i)))
        if CamLogical(i)
            if isfolder(fullfile(ExpParentPath,"Convert",num2str(CamNo,"Cam%d"),"Image",T_new.RUNNUMBER(i)))
                T_new.Transfer(i) = -1;%宛先フォルダが既存の場合はスキップ
            elseif isfolder(fullfile(HDDDrivePrefix,"Convert",num2str(CamNo,"Cam%d"),T_new.RUNNUMBER(i)))
                disp("転送中...")
                T_new.Transfer(i) = ...
                    double(copyfile(fullfile(HDDDrivePrefix,"Convert",num2str(CamNo,"Cam%d"),T_new.RUNNUMBER(i),'*.tiff') ...
                    ,fullfile(ExpParentPath,"Convert",num2str(CamNo,"Cam%d"),"Image",T_new.RUNNUMBER(i))));
                T_new.Transfer(i) = ...
                    double(copyfile(fullfile(HDDDrivePrefix,"Convert",num2str(CamNo,"Cam%d"),T_new.RUNNUMBER(i),'*.csv') ...
                    ,fullfile(ExpParentPath,"Convert",num2str(CamNo,"Cam%d"),"TimeHistory",T_new.RUNNUMBER(i))));

            else
                T_new.Transfer(i) = -3;%コピー元フォルダがない場合はスキップ
            end
        else
            T_new.Transfer(i) = -2;%撮影なし
        end
    end
end
