% 冷却面平板の位置を決定するコード
% 基本はPostProcessing_ImageFileProcessingAndTransferと同じ
% DistDirSelectorとmakeDistDirにカメラごとの設定を追記
% 33行目をコメントアウトすればすべて条件で動くはず
% トリミングの画角等をRunごとに変える必要がある場合は要検討（条件分岐を追加するだけ）
% 多分下のローカル関数のところだけ、Tigger3の条件分岐をすればいいと思う。
% 
% 
%% 
PostProcessingSetting;
%%
T0 = loadExpDataTable(ExpParentPath);

ExcelT = T0(T0.No > 101700 & T0.No < 112800,:);







%%

for k = 20:height(ExcelT.RUNNUMBER)
    RUNNUMBER = ExcelT.RUNNUMBER(k);
    

    for CamLabelNo = 2:3
        % if CamLabelNo ~= 3;continue;end% 要動作確認、削除すればすべての画像処理が可能なはず
        disp(append(string(CamLabelList(CamLabelNo))," : ",RUNNUMBER))
        CamNo = ExcelT.(append(string(CamLabelList(CamLabelNo)),"Camera"))(ExcelT.RUNNUMBER == RUNNUMBER);
        sCamNo = string(CamNo);
        if CamNo == "None";continue;end
        
        % [croprect,err] = generateCropRectForPostProcessing(string(CamLabelList(CamLabelNo)),sCamNo,CropRect,PixelPerMm);
        % if err;disp("キャリブレーションデータエラー!!!");continue;end
        
        fname = append(RUNNUMBER,"_PlateEdgeParameter",string(CamLabelList(CamLabelNo)));
        if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat"))) && not(PlateEdgeParameterForceOverWrite)
           disp("Already TrimParameter File Exist!!")
           continue;
        end
        
        OriginalFolder = fullfile(ExpParentPath,"Convert",string(CamNo),"Image",RUNNUMBER);
        if not(isfolder(OriginalFolder));disp("NO CamData file!!!");continue;end
        
        DS = imageDatastore(OriginalFolder);

        [I0,err] = ImageSelector(CamLabelList(CamLabelNo),sCamNo,ExpParentPath,RUNNUMBER);
        if err;disp("画像選択エラー!!!");continue;end

        I1 = ImagePostProcessing0(I0, ...
                CropRect.(string(CamLabelList(CamLabelNo))), ...
                RotateAngle.(string(CamLabelList(CamLabelNo))), ...
                CamProcessingCropSkip(CamLabelNo), ...
                CamProcessingflipSkip(CamLabelNo));%画像の処理
        
        [A.PlateEdgeParameter,err] = detectPlateEdgeParameter(I1,CamLabelList(CamLabelNo));
        A.RotateAngle = RotateAngle.(string(CamLabelList(CamLabelNo)));
        A.CropRect = CropRect.(string(CamLabelList(CamLabelNo)));
        A.CamProcessingSkip = CamProcessingCropSkip(CamLabelNo);
        A.CamProcessingflipSkip = CamProcessingflipSkip(CamLabelNo);

        assignin('base',fname,A)
        save(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat")),fname,'-mat');
    end
end

%%

function [I,err] = ImageSelector(CamLabel,sCamNo,ExpParentPath,RUNNUMBER)
    arguments
        CamLabel (1,1) categorical
        sCamNo
        ExpParentPath
        RUNNUMBER
    end
    err = false;
    I = [];
    % figure;
    % imshow(I,"Border","tight")
    
    switch CamLabel
        case "Top"
            err = true;
            return;
        case "Side"
            % OriginalFolder = fullfile(ExpParentPath,"Convert",sCamNo,"Image",RUNNUMBER);
            OriginalFolder = fullfile(ExpParentPath,"Calibration",sCamNo,RUNNUMBER);
            if not(isfolder(OriginalFolder));disp("NO CamData file!!!");err = true;return;end
            DS = imageDatastore(OriginalFolder);
            I = readimage(DS,1);
        case "Tilt"
            OriginalFolder = fullfile(ExpParentPath,"Convert",sCamNo,"Image",RUNNUMBER);
            if not(isfolder(OriginalFolder));disp("NO CamData file!!!");err = true;return;end
            DS = imageDatastore(OriginalFolder);
            I = readimage(DS,1);
        case "MacroSide"
            err = true;
            return;
        case "MacroTop"
            err = true;
            return;
        otherwise
            disp("CamLabelがおかしいです。")
            err = true;
            return;
    end
end


function [Trim,err] = detectPlateEdgeParameter(I,CamLabel)
    arguments
        I
        CamLabel (1,1) categorical
    end
    err = false;

    figure;
    imshow(I,"Border","tight")
    
    switch CamLabel
        case "Top"

        case "Side"
            roi = drawline(LineWidth=1);
            wait(roi);
            Trim = roi.Position;
            close
        case "Tilt"
            roi = drawline(LineWidth=1);
            wait(roi);
            Trim = roi.Position;
            close
        case "MacroSide"

        case "MacroTop"

        otherwise
            disp("CamLabelがおかしいです。")
            err = true;
            return;
    end
end