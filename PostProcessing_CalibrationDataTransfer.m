PostProcessingSetting;
%%
% エクセルファイルからテーブルをロード
ExcelT = loadExpDataTable(ExpParentPath);

disp("データの転送")
[~,T_new] = filetransfer(CalibHDDDrivePrefix,ExpParentPath,ExcelT,1,logical(CamTransferSkip(1)));

% PostProcessing_CalibrationDataTransferRunning = true;%ダミー


%% キャリブレーションデータの計測

PostProcessing_CalibrationDataMeasurement;

% clear PostProcessing_CalibrationDataTransferRunning;

%% ローカル関数

%% ファイル転送
function [ExcelT,T_new] = filetransfer(HDDDrivePrefix,ExpParentPath,ExcelT)
    arguments
        HDDDrivePrefix  (1,1) string 
        ExpParentPath  (1,1) string 
        ExcelT (:,:) table
    end

    T_new = ExcelT(:,"RUNNUMBER");
    for CamNo = 1:4
        T_new = addvars(T_new,zeros(height(T_new),1),num2str(CamNo,"TransferCam%d"));
    end

    for CamNo = 1:4
        for i = 1:height(T_new)
            disp(append(num2str(CamNo,"Cam%d : "),T_new.RUNNUMBER(i)))
            DistDir = fullfile(ExpParentPath,"Calibration",num2str(CamNo,"Cam%d"),T_new.RUNNUMBER(i));
            BaseDir = fullfile(HDDDrivePrefix,"Calibration",num2str(CamNo,"Cam%d"),T_new.RUNNUMBER(i));
            
            if isfolder(DistDir)
                T_new.(num2str(CamNo,"TransferCam%d"))(i) = -1;%宛先フォルダが既存の場合はスキップ
            elseif isfolder(BaseDir)
                disp("転送中...")
                T_new.(num2str(CamNo,"TransferCam%d"))(i) = double(copyfile(fullfile(BaseDir,'*.*'),DistDir));
            else
                T_new.(num2str(CamNo,"TransferCam%d"))(i) = -3;%コピー元フォルダがない場合はスキップ
            end
        end
    end
end
