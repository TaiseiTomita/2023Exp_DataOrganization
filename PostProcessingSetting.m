
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%             実験用PCでのPostProcessing用個別設定                %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 共通の設定
CamLabelList = categorical(["Top" "Side" "Tilt" "MacroSide" "MacroTop" "OverAllMacro" "TiltMacro"]);


%% PostProcessing_DataFileTransfer 関連

% 外付けHDD内の実験データ（Docsフォルダ）が保存されたフォルダのPath
% 実験条件記録用紙が入っている場所
DocsHDDDrivePrefix = "J:\2023Flatplate_autumn"; 

% 対象となる実験の実験条件記録用紙のfile名を入力
Excelfilename = "ExpConditionTable_2023FlatPlateExp_総本家.xlsx";

%外付けHDD内の実験データ（計測データ・Measuredフォルダ）が保存されたフォルダのPath
DataHDDDrivePrefix = "" + ...
    "JP:\2023Flatplate_autumn"; 

% データロガーの計測データに割り当てる変数名
GL840VarNames = ...
            {'TPlate','CH2','CH3','AirVelocityV','TBF20',...
            'TBF15','TBF10','TBB10','TBB15','TBB20',...
            'CH11','PAirV','CH13','CH14','PMV', ...
            'PMsignal','CH17','MFT','MFRH','MFQ'};



%% PostProcessing_ConvertFileTransfer 関連
%データ転送をスキップする場合は1,しない場合は0
CamTransferSkip = [0 0 0 0];%左からCam1, Cam2,... 

%外付けHDD内のConvert画像が保存されたフォルダのPath
Cam1HDDDrivePrefix = "I:\2023Flatplate_autumn";%H,J,E
Cam2HDDDrivePrefix = "I:\2023Flatplate_autumn";
Cam3HDDDrivePrefix = "I:\2023Flatplate_autumn";
Cam4HDDDrivePrefix = "I:\2023Flatplate_autumn";


%% PostProcessing_ConvertFileTransfer 関連

% 外付けHDD内のCalibration画像が保存されたフォルダのPath
CalibHDDDrivePrefix = "J:\2023Flatplate_autumn"; 

% キャリブレーション時のトリミング画角(pixel指定)
CalibCropRect.Tilt = [600 50 500 190];
CalibCropRect.Side = [600 50 500 190];% 要修正、これでいいの？
% CalibCropRect.Cam3 = [600 50 500 190]; 
% CalibCropRect.Cam4 = [600 50 500 190]; 

% 強制上書き
% CalibDataFourceOverWrite = false;
CalibDataFourceOverWrite = true;


%% PostProcessing_ImageFileProcessingAndTransfer 関連
%PostProcessing_PlateSurfaceDetectionでも同じパラメータを使う

% PlateEdgeParameterForceOverWrite = false;
PlateEdgeParameterForceOverWrite = true;



DistDirList.Tilt_Red = fullfile(ExpParentPath,"ProcessedImage","Tilt(RED)");
DistDirList.Tilt_Green = fullfile(ExpParentPath,"ProcessedImage","Tilt(GREEN)");
DistDirList.Tilt_LED = fullfile(ExpParentPath,"ProcessedImage","Tilt(LED)");
DistDirList.Side_Red = fullfile(ExpParentPath,"ProcessedImage","Side(RED)");
DistDirList.Side_Green = fullfile(ExpParentPath,"ProcessedImage","Side(GREEN)");
DistDirList.Side_LED = fullfile(ExpParentPath,"ProcessedImage","Side(LED)");
% DistDirList.Top_Red = fullfile(ExpParentPath,"ProcessedImage","Tilt(RED)");
% DistDirList.Top_Green = fullfile(ExpParentPath,"ProcessedImage","Tilt(GREEN)");
DistDirList.Top_LED = fullfile(ExpParentPath,"ProcessedImage","Top(LED)");

% macroについては、要検討

%TempLabelList = categorical(["27" "-25" "-50" "-75" "-100" "-125" "-150" "-170"]);
%PlaceLabelList = categorical(["0mm" "10mm" "20mm" "40mm"]);

DistDirList.MacroSide = fullfile(ExpParentPath,"ProcessedImage","Macro","MacroSide");
DistDirList.MacroTop = fullfile(ExpParentPath,"ProcessedImage","Macro","MacroTop");
DistDirList.OverAllMacro = fullfile(ExpParentPath,"ProcessedImage","Macro","OverAllMacro");


%画像トリミングをスキップする場合は1,しない場合は0
CamProcessingCropSkip = [0 0 0 1 1];%左から"Top" "Side" "Tilt" "MacroSide" "MacroTop" "OverAllMacro"
%画像処理で左右反転をスキップする場合は1,しない場合は0
CamProcessingflipSkip = [1 0 0 0 1];%左から"Top" "Side" "Tilt" "MacroSide" "MacroTop" "OverAllMacro"

%画像のトリミング画角（pixel単位で指定）
CropRect.Top = [70 200 1250 1850];
CropRect.Side = [200 50 3800 800];
% CropRect.MacroSide = [600 50 500 190];
% CropRect.MacroTop = [600 50 500 190];
CropRect.Tilt = [50 150 2100 550];


%画像の回転角画角
RotateAngle.Top = 0;
RotateAngle.Side = 0;
RotateAngle.MacroSide = 0;
RotateAngle.MacroTop = 0;
RotateAngle.Tilt = 0;

%% ImageMeasurement 関連
%PostProcessing_PlateSurfaceDetectionでも同じパラメータを使う

IMDirList.Tilt_Red = fullfile(ExpParentPath,"ProcessedImage","Tilt(RED)");
IMDirList.Tilt_Green = fullfile(ExpParentPath,"ProcessedImage","Tilt(GREEN)");

IMDirList.IMFrostDist = fullfile(ExpParentPath,"thickness");

IMFrostborder = 60; %40

IMMistborder = [5 10:80]';


% DistDirList.Tilt_LED = fullfile(ExpParentPath,"ProcessedImage","Tilt(LED)");
% DistDirList.Side_Red = fullfile(ExpParentPath,"ProcessedImage","Side(RED)");
% DistDirList.Side_Green = fullfile(ExpParentPath,"ProcessedImage","Side(GREEN)");
% DistDirList.Side_LED = fullfile(ExpParentPath,"ProcessedImage","Side(LED)");
% DistDirList.Top_Red = fullfile(ExpParentPath,"ProcessedImage","Tilt(RED)");
% DistDirList.Top_Green = fullfile(ExpParentPath,"ProcessedImage","Tilt(GREEN)");
% DistDirList.Top_LED = fullfile(ExpParentPath,"ProcessedImage","Top(LED)");

% macroについては、要検討
% DistDirList.MacroSide = fullfile(ExpParentPath,"ProcessedImage","MacroSide");
% DistDirList.MacroSide = fullfile(ExpParentPath,"ProcessedImage","MacroSide");
% DistDirList.MacroTop = fullfile(ExpParentPath,"ProcessedImage","MacroTop");


% CamLabelList = categorical(["Top" "Side" "Tilt" "MacroSide" "MacroTop"]);

%画像処理をスキップする場合は1,しない場合は0
% CamProcessingSkip = [0 0 0 1 1];%左から"Top" "Side" "Tilt" "MacroSide" "MacroTop"
%画像処理で左右反転をスキップする場合は1,しない場合は0
% CamProcessingflipSkip = [1 0 0 0 1];%左から"Top" "Side" "Tilt" "MacroSide" "MacroTop"

%画像のトリミング画角（mm単位で指定）
% CropRect.Top = [600 50 500 190];
% CropRect.Side = [600 50 500 190]; 
% CropRect.MacroSide = [600 50 500 190]; 
% CropRect.MacroTop = [600 50 500 190]; 
% CropRect.Tilt = [1 7 70 15]; 

%画像の回転角画角
% RotateAngle.Top = 0;
% RotateAngle.Side = 0;
% RotateAngle.MacroSide = 0;
% RotateAngle.MacroTop = 0;
% RotateAngle.Tilt = 0;






% トリミング領域と回転角の設定
% Cam1rect = [300 200 3400 600];
% Cam1angle = 0.2;
% 
% Cam2rect = [100 100 2100 1900];
% Cam2angle = -0.6;
% 
% 
% Cam2rect = [100 100 2100 1900];
% Cam2angle = -0.6;
% 
% Cam2rect = [100 100 2100 1900];
% Cam2angle = -0.6;
% 
% Cam2rect = [100 100 2100 1900];
% Cam2angle = -0.6;

% 冷却面の制御精度のしきい値
Tw_accuracyThrehold = 5.5d0;