function [T,err] = funcfThicknessMeasurement(ExpParentPath,RUNNUMBER,IMFrostborder,sCamNo)
    
    T = table;
    err = false;

    fname = append(RUNNUMBER,"_CalibrationData");
    if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat"))) == 0
        disp("NO CalibrationData file!!!")
        err = true;
        return;
    end
    load(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat")));

        
    fname = append(RUNNUMBER,"_TiltImageDataT");
    if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat"))) == 0
        disp("TiltImageDataT");
        err = true;
        return;
    end
    m = matfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat")));
    T0 = m.(fname);TriggerTT = T0(T0.Var1 == 0,:);

    % 霜厚さの計測
    for i = 1:height(TriggerTT)
        if not(isfile(fullfile(ExpParentPath,TriggerTT.file{i})));break;end

        I = imread(fullfile(ExpParentPath,TriggerTT.file{i}));
    
        if i == 1
            [BasePlateTable,errCode] = getBasePlateTable(ExpParentPath,RUNNUMBER,size(im2gray(I)),PixelPerMm,sCamNo);
            if errCode ~= 0;err = true;return;end
        end

        [TriggerTT.IndexT{i}, TriggerTT.DataT{i}] = FrostheightMeasurement_Tilt(I,BasePlateTable,IMFrostborder,mmPerPixel,sCamNo);
    end 
    T = TriggerTT;
end



function [T,err] = getBasePlateTable(ExpParentPath,RUNNUMBER,ImageSize,PixelPerMm,sCamNo)

    err = 0;
    fname = append(RUNNUMBER,"_PlateEdgeParameterTilt");
    if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat"))) == 0
        disp("NO TrimParameterTilt file!!!");
        err = 1;
        return;
    end
    
    m = matfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat")));
    A = m.(fname);
    Trim = A.PlateEdgeParameter;

    A = (Trim(1,2)-Trim(2,2))/(Trim(1,1)-Trim(2,1));
    B = Trim(1,2) - Trim(1,1)*A;
    XInd = (1:ImageSize(2))';
    YInd = A*XInd + B;

    XCoord = (XInd - Trim(1,1))/PixelPerMm.(append(sCamNo,"X"));
    YCoord = zeros(size(XCoord));
    
    T = array2table([XInd YInd XCoord YCoord],VariableNames=["XInd" "YInd" "XCoord" "YCoord"]);

end


function [TInd, TCoord] = FrostheightMeasurement_Tilt(Iin,BasePlateTable,border,mmPerPixel,sCamNo)

    BW = Iin(:,:,1) >= border;%R成分のみ抽出して 二値化

    TInd = BasePlateTable(:,"XInd");
    TCoord = BasePlateTable(:,"XCoord");

    for i = 1:height(TInd)
        maxindex = find(diff(BW(:,TInd.XInd(i)))==1,1,"first");%1wを探索
        if height(maxindex) == 0
            TInd.YIndmax(i) = nan;%検出されなければNAN
        else
            TInd.YIndmax(i) = maxindex+1;%差分をとる関係で、1に切り替わるインデックスは＋1
        end

        minindex = find(diff(BW(:,TInd.XInd(i)))==-1,1,"last");
        if height(minindex) == 0
            TInd.YIndmin(i) = nan;%検出されなければNAN
        else
            TInd.YIndmin(i) = minindex;%こちらは、1から0になるので+1は不要
        end

        TInd.TomitaMethodInd(i) = TInd.YIndmax(i) + nnz(BW(:,TInd.XInd(i)))*0.5;%検出されなければNAN
    end

    TInd.YIndave = mean(TInd{:,["YIndmax" "YIndmin"]},2);
    TCoord.fheight = (BasePlateTable.YInd - TInd.YIndave) *mmPerPixel.(append(sCamNo,"Y"));
    TCoord.fheightTomita = (BasePlateTable.YInd - TInd.TomitaMethodInd) *mmPerPixel.(append(sCamNo,"Y"));
end
