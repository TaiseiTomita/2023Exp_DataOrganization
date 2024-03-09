function [Results,err] = generateCaliblationData(ExpParentPath,RUNNUMBER,CropRect,sCamNo)
    arguments
        ExpParentPath  (1,1) string 
        RUNNUMBER  (1,1) string 
        CropRect (1,4) double
        sCamNo  (1,1) string 
    end

    Folder = fullfile(ExpParentPath,"Calibration",sCamNo,RUNNUMBER);
    if isfolder(Folder)
        DS = imageDatastore(Folder);
        I0 = im2gray(readimage(DS,1));%画像の読み込み
        [Xlength,Ylength] = fCalibration(I0,CropRect);
        err = false;

        Results.mmPerPixcelX = 1.0/Xlength;
        Results.mmPerPixcelY = 1.0/Ylength;
        Results.PixcelPerMmX = Xlength;
        Results.PixcelPerMmY = Ylength;
    else
        Results.mmPerPixcelX = nan;
        Results.mmPerPixcelY = nan;
        Results.PixcelPerMmX = nan;
        Results.PixcelPerMmY = nan;
        err = true;
    end
end


function [Xlength,Ylength] = fCalibration(I0,CalibCropRect)

    I1 = imcrop(I0,CalibCropRect);%トリミング
    
    [imagePoints,boardSize] = detectCheckerboardPoints(I1);%チェッカーボードを検出
    
    
    %y方向の長さ
    Xwide1 = 0;
    Ywide1 = 0;
    C = [];
    N = 0;
    
    imagePoints = sortrows(imagePoints,1,"ascend");
    for i = 1:boardSize(1,2)-1 
        for j = 1:boardSize(1,1)-1 
            C = [C;imagePoints(j+(i-1)*(boardSize(1,1)-1),2)];
        end
        C = sortrows(C,"ascend");
        [ycell1,~] = size(C);
        for k = 2:ycell1
            Ywide1 = Ywide1 + C(k,1) - C(k-1,1);
            N = N+1;
        end
        C = [];
    end
    Ywide = Ywide1/N;
    Ylength = 2*Ywide;
    
    %%X方向の長さ
    N = 0;
    imagePoints = sortrows(imagePoints,2,"ascend");
    for i = 1:boardSize(1,1)-1 
        for j = 1:boardSize(1,2)-1 
            C = [C;imagePoints(j+(i-1)*(boardSize(1,1)-1),1)];
        end
        C = sortrows(C,"ascend");
        [ycell2,~] = size(C);
        for k = 2:ycell2
            Xwide1 = Xwide1 + C(k,1) - C(k-1,1);
            N = N+1;
        end
        C = [];
    end
    Xwide = Xwide1/N;
    Xlength = 2*Xwide;
end


