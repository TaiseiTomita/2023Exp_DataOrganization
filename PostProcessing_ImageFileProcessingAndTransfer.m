% 
% 
% DistDirSelectorとmakeDistDirにカメラごとの設定を追記
% 33行目をコメントアウトすればすべて条件で動くはず
% トリミングの画角等をRunごとに変える必要がある場合は要検討（条件分岐を追加するだけ）
% 多分下のローカル関数のところだけ、Tigger3の条件分岐をすればいいと思う。
% 
% 
%%
PostProcessingSetting;

%%
% エクセルファイルからテーブルをロード
T0 = loadExpDataTable(ExpParentPath);

ExcelT = T0(T0.No > 101700 & T0.No < 112800,:);

%% 画像のトリミング、反転、回転と振り分け

for k = 1:height(ExcelT)
    RUNNUMBER = ExcelT.RUNNUMBER(k);
%     RUNNUMBER = "Run112904";

    [MT,TriggerT0,err] = loadMeasuredDataEachRun(ExpParentPath,RUNNUMBER);
    if err;disp("NO MeasuredData file!!!");continue;end
    expTime = max(MT.ETime(MT.state == "experiment"));
    if ExcelT.TiltCameraTrigger(k) ~= "CamTrigger3"
            disp("Not Laser")
            continue
    end

    
    % if ExcelT.TiltCameraTrigger(k) == "CamTrigger3"
    %     [PixelPerMm,err] = loadCalibDataEachRun(ExpParentPath,RUNNUMBER);
    %     if err;disp("NO CalibrationData file!!!");continue;end
    % end
    
    for CamLabelNo = 1:1
        % if CamLabelNo ~= 3;continue;end% 要動作確認、削除すればすべての画像処理が可能なはず
        disp(append(string(CamLabelList(CamLabelNo))," : ",RUNNUMBER))

        CamNo = ExcelT.(append(string(CamLabelList(CamLabelNo)),"Camera"))(ExcelT.RUNNUMBER == RUNNUMBER);
        sCamNo = string(CamNo);
        if CamNo == "None";continue;end
        if ExcelT.(sCamNo)(k) == false;continue;end
    
        TriggerNo = ExcelT.(append(string(CamLabelList(CamLabelNo)),"CameraTrigger"))(ExcelT.RUNNUMBER == RUNNUMBER);
        %     [croprect,err] = generateCropRectForPostProcessing(string(CamLabelList(CamLabelNo)),sCamNo,CropRect,PixelPerMm);
        %     if err;disp("キャリブレーションデータエラー!!!");continue;end
        % end

        [err] = makeDistDir(CamLabelList(CamLabelNo),TriggerNo,DistDirList,RUNNUMBER,ExcelT,k);
        if err;disp("フォルダ作成ミス!!!");continue;end
   
        OriginalFolder = fullfile(ExpParentPath,"Convert",sCamNo,"Image",RUNNUMBER);
        if not(isfolder(OriginalFolder));disp("NO CamData file!!!");continue;end
        DS = imageDatastore(OriginalFolder);
        if height(DS.Files) == 0;disp("NO CamData file!!!");continue;end

        TriggerT = TriggerT0.(append(string(TriggerNo),"T"));
        TriggerT(height(DS.Files):end,:)=[];
        
        
        for i = 1:height(DS.Files)
            
            if height(TriggerT) <= i;break;end
            if TriggerT.ETime(i+1) > expTime+1;break;end %念のため1秒くらいマージンつけます。%Triggerfileの最小の行に実験開始直前の記録が残っていたので＋１してます．
            [DistDir,err] = DistDirSelector(CamLabelList(CamLabelNo),TriggerNo,DistDirList,TriggerT.Var1(i));%転送先のディレクトリの選択
            if err;continue;end
            
            newfilename = extractAfter(DS.Files{i},append(RUNNUMBER,"\"));
            DistFile = fullfile(DistDir,RUNNUMBER,newfilename);
            %if isfile(DistFile);continue;end

            I1 = ImagePostProcessing0(readimage(DS,i), ...
                CropRect.(string(CamLabelList(CamLabelNo))), ...
                RotateAngle.(string(CamLabelList(CamLabelNo))), ...
                CamProcessingCropSkip(CamLabelNo), ...
                CamProcessingflipSkip(CamLabelNo));%画像の処理
            imwrite(I1,DistFile)
            TriggerT.file{i} = extractAfter(DistFile,ExpParentPath);
        end
        
        fname = append(RUNNUMBER,"_",string(CamLabelList(CamLabelNo)),"ImageDataT");
        assignin('base',fname,TriggerT)
        if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat"))) == 0
            save(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat")),fname,'-mat');
        end
        clear(fname)
    end  
end


%% ローカル関数

%% ファイル転送
function [DistDir,err] = DistDirSelector(CamLabel,TriggerNo,DistDirList,TriggerTTVar1)
    arguments
        CamLabel (1,1) categorical
        TriggerNo (1,1) categorical
        DistDirList
        TriggerTTVar1 (1,1) double %{mustbeInteger}
    end
    
    %コピーをスキップしたいときはerr=trueを返せばいい。
    err = false;

    switch TriggerNo
        case "CamTrigger3"
            switch CamLabel
                case "Top"
                    if TriggerTTVar1 == 0
%                         disp("レーザースキップ")
                        err = true;
                        DistDir = [];
                    elseif TriggerTTVar1 == 1
%                         disp("レーザースキップ")
                        err = true;
                        DistDir = [];
                    elseif TriggerTTVar1 == 2
                        DistDir = DistDirList.Top_LED;
                    else
                        disp("Var1が変")
                        err = true;
                    end
                case "Side"
                    if TriggerTTVar1 == 0
                        DistDir = DistDirList.Side_Red;
                    elseif TriggerTTVar1 == 1
                        DistDir = DistDirList.Side_Green;
                    elseif TriggerTTVar1 == 2
                        DistDir = DistDirList.Side_LED;
                    else
                        disp("Var1が変")
                        err = true;
                    end
                case "Tilt"
                    if TriggerTTVar1 == 0
                        DistDir = DistDirList.Tilt_Red;
                    elseif TriggerTTVar1 == 1
                        DistDir = DistDirList.Tilt_Green;
                    elseif TriggerTTVar1 == 2
                        DistDir = DistDirList.Tilt_LED;
                    else
                        disp("Var1が変")
                        err = true;
                    end
                case "MacroSide"
                    err = true;
                case "MacroTop"
                    err = true;
                otherwise
                    disp("CamLabelがおかしいです。")
                    err = true;
            end

        case "CamTrigger1"
            switch CamLabel
                case "Top"
                    DistDir = DistDirList.Top_LED;
                    % if TriggerTTVar1 == 0
                    %     disp("レーザースキップ")
                    %     err = true;
                    % elseif TriggerTTVar1 == 1
                    %     disp("レーザースキップ")
                    %     err = true;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Top_LED;
                    % else
                    %     disp("Var1が変")
                    %err = true;
                    % end
                case "Side"
                    DistDir = DistDirList.Side_LED;
                    % if TriggerTTVar1 == 0
                    %     DistDir = DistDirList.Side_Red;
                    % elseif TriggerTTVar1 == 1
                    %     DistDir = DistDirList.Side_Green;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Side_LED;
                    % else
                    %     disp("Var1が変")
                    %     err = true;
                    % end
                case "Tilt"
                    DistDir = DistDirList.Tilt_LED;
                    % if TriggerTTVar1 == 0
                    %     DistDir = DistDirList.Tilt_Red;
                    % elseif TriggerTTVar1 == 1
                    %     DistDir = DistDirList.Tilt_Green;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Tilt_LED;
                    % else
                    %     disp("Var1が変")
                    err = true;
                    % end
                case "MacroSide"
                    DistDir = append(DistDirList.MacroSide,'_',string(ExcelT.MacroSidePlace(k)),'_',string(ExcelT.Tw(k)));
                    err=true;
                case "MacroTop"
                    DistDir = append(DistDirList.MacroTop,'_',string(ExcelT.MacroTopPlace(k)),'_',string(ExcelT.Tw(k)));
                    err=true;
                otherwise
                    disp("CamLabelがおかしいです。")
                    err = true;
            end

            case "CamTrigger2"
            switch CamLabel
                case "Top"
                    DistDir = DistDirList.Top_LED;
                    % if TriggerTTVar1 == 0
                    %     disp("レーザースキップ")
                    %     err = true;
                    % elseif TriggerTTVar1 == 1
                    %     disp("レーザースキップ")
                    %     err = true;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Top_LED;
                    % else
                    %     disp("Var1が変")
                    %err = true;
                    % end
                case "Side"
                    DistDir = DistDirList.Side_LED;
                    % if TriggerTTVar1 == 0
                    %     DistDir = DistDirList.Side_Red;
                    % elseif TriggerTTVar1 == 1
                    %     DistDir = DistDirList.Side_Green;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Side_LED;
                    % else
                    %     disp("Var1が変")
                    err = true;
                    % end
                case "Tilt"
                    DistDir = DistDirList.Tilt_LED;
                    % if TriggerTTVar1 == 0
                    %     DistDir = DistDirList.Tilt_Red;
                    % elseif TriggerTTVar1 == 1
                    %     DistDir = DistDirList.Tilt_Green;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Tilt_LED;
                    % else
                    %     disp("Var1が変")
                    err = true;
                    % end
                case "MacroSide"
                    DistDir = append(DistDirList.MacroSide,'_',ExcelT.MacroSidePlace(k),'_',ExcelT.Tw(k));
                    err=true;
        
                case "MacroTop"
                    DistDir = append(DistDirList.MacroTop,'_',ExcelT.MacroTopPlace(k),'_',ExcelT.Tw(k));
                    err=true;
                otherwise
                    disp("CamLabelがおかしいです。")
                    err = true;
            end

        otherwise
            disp("TriggerNoがおかしいです。")
            err = true;
    end
end


function [err] = makeDistDir(CamLabel,TriggerNo,DistDirList,RUNNUMBER,ExcelT,k)
    arguments
        CamLabel (1,1) categorical
        TriggerNo (1,1) categorical
        DistDirList
        RUNNUMBER
        ExcelT
        k
    end
    
    switch TriggerNo
        case "CamTrigger3"
            switch CamLabel
                case "Top"
                    err0(1) = mkdir(fullfile(DistDirList.Top_LED,RUNNUMBER));
                case "Side"
                    err0(1) = mkdir(fullfile(DistDirList.Side_Red,RUNNUMBER));
                    err0(2) = mkdir(fullfile(DistDirList.Side_Green,RUNNUMBER));
                    err0(3) = mkdir(fullfile(DistDirList.Side_LED,RUNNUMBER));
                case "Tilt"
                    err0(1) = mkdir(fullfile(DistDirList.Tilt_Red,RUNNUMBER));
                    err0(2) = mkdir(fullfile(DistDirList.Tilt_Green,RUNNUMBER));
                    err0(3) = mkdir(fullfile(DistDirList.Tilt_LED,RUNNUMBER));
                case "MacroSide"
        
                case "MacroTop"
        
                otherwise
                    disp("CamLabelがおかしいです。")
                    err = true;
                    return;
            end

        case "CamTrigger1"
            switch CamLabel
                case "Top"
                    err0(1) = mkdir(fullfile(DistDirList.Top_LED,RUNNUMBER));
                    % if TriggerTTVar1 == 0
                    %     disp("レーザースキップ")
                    %     err = true;
                    % elseif TriggerTTVar1 == 1
                    %     disp("レーザースキップ")
                    %     err = true;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Top_LED;
                    % else
                    %     disp("Var1が変")
                    %     err = true;
                    % end
                case "Side"
                    err0(1) = mkdir(fullfile(DistDirList.Side_LED,RUNNUMBER));
                    % if TriggerTTVar1 == 0
                    %     DistDir = DistDirList.Side_Red;
                    % elseif TriggerTTVar1 == 1
                    %     DistDir = DistDirList.Side_Green;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Side_LED;
                    % else
                    %     disp("Var1が変")
                    %     err = true;
                    % end
                case "Tilt"
                    err0(1) = mkdir(fullfile(DistDirList.Tilt_LED,RUNNUMBER));
                    % if TriggerTTVar1 == 0
                    %     DistDir = DistDirList.Tilt_Red;
                    % elseif TriggerTTVar1 == 1
                    %     DistDir = DistDirList.Tilt_Green;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Tilt_LED;
                    % else
                    %     disp("Var1が変")
                    %     err = true;
                    % end
                case "MacroSide"
                    err0(1) = mkdir(fullfile(append(DistDirList.MacroSide,'_',string(ExcelT.MacroSidePlace(k)),'_',string(ExcelT.Tw(k))),RUNNUMBER));
        
                case "MacroTop"
                    err0(1) = mkdir(fullfile(append(DistDirList.MacroTop,'_',string(ExcelT.MacroTopPlace(k)),'_',string(ExcelT.Tw(k))),RUNNUMBER));
                otherwise
                    disp("CamLabelがおかしいです。")
                    err = true;
                    return;
            end

        case "CamTrigger2"
            switch CamLabel
                case "Top"
                    err0(1) = mkdir(fullfile(DistDirList.Top_LED,RUNNUMBER));
                    % if TriggerTTVar1 == 0
                    %     disp("レーザースキップ")
                    %     err = true;
                    % elseif TriggerTTVar1 == 1
                    %     disp("レーザースキップ")
                    %     err = true;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Top_LED;
                    % else
                    %     disp("Var1が変")
                    %     err = true;
                    % end
                case "Side"
                    err0(1) = mkdir(fullfile(DistDirList.Side_LED,RUNNUMBER));
                    % if TriggerTTVar1 == 0
                    %     DistDir = DistDirList.Side_Red;
                    % elseif TriggerTTVar1 == 1
                    %     DistDir = DistDirList.Side_Green;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Side_LED;
                    % else
                    %     disp("Var1が変")
                    %     err = true;
                    % end
                case "Tilt"
                    err0(1) = mkdir(fullfile(DistDirList.Tilt_LED,RUNNUMBER));
                    % if TriggerTTVar1 == 0
                    %     DistDir = DistDirList.Tilt_Red;
                    % elseif TriggerTTVar1 == 1
                    %     DistDir = DistDirList.Tilt_Green;
                    % elseif TriggerTTVar1 == 2
                    %     DistDir = DistDirList.Tilt_LED;
                    % else
                    %     disp("Var1が変")
                    %     err = true;
                    % end
                case "MacroSide"
                    err0(1) = mkdir(fullfile(append(DistDirList.MacroSide,'_',ExcelT.MacroSidePlace(k),'_',num2str(-ExcelT.Tw(k),"%03d"),RUNNUMBER)));
        
                case "MacroTop"
                    err0(1) = mkdir(fullfile(append(DistDirList.MacroTop,'_',ExcelT.MacroTopPlace(k),'_',ExcelT.Tw(k)),RUNNUMBER));
                otherwise
                    disp("CamLabelがおかしいです。")
                    err = true;
                    return;
            end

        otherwise
            disp("TriggerNoがおかしいです。")
            err = true;
            return;
    end
    
    

    if all(logical(err0))
        err = false;
    else
        err = true;
    end
end
