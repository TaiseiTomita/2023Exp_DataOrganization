function [T,err] = funcMistThicknessMeasurement(ExpParentPath,RUNNUMBER,IMMistborder,sCamNo)
    
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
    T0 = m.(fname);TriggerTT = T0(T0.Var1 == 1,:);

    % 霜厚さの計測
    for i = 1:height(TriggerTT)
        if not(isfile(fullfile(ExpParentPath,TriggerTT.file{i})));break;end

        I = imread(fullfile(ExpParentPath,TriggerTT.file{i}));
    
        if i == 1
            [BasePlateTable,errCode] = getBasePlateTable(ExpParentPath,RUNNUMBER,size(im2gray(I)),PixelPerMm,sCamNo);
            if errCode ~= 0;err = true;return;end
        end

        [TriggerTT.IndexT{i}, TriggerTT.DataT{i}] = MistheightMeasurement_Tilt(I,BasePlateTable,IMMistborder,mmPerPixel,sCamNo);
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


function [TInd, TCoord] = MistheightMeasurement_Tilt(Iin,BasePlateTable,border,mmPerPixel,sCamNo)
    TInd = BasePlateTable(:,"XInd");
    TCoord = BasePlateTable(:,"XCoord");

    for l = 1:height(border)
        % disp(border(l))
        BW = Iin(:,:,2) >= border(l);%R成分のみ抽出して 二値化

        A = nan(height(TInd),1);
        for i = 1:height(TInd)
            maxindex = find(diff(BW(:,TInd.XInd(i)))==1,1,"first");
            if height(maxindex) == 0
                A(i) = nan;%検出されなければNAN
            else
                A(i) = maxindex+1;%差分をとる関係で、1に切り替わるインデックスは＋1
            end
    
    %         minindex = find(diff(BW(:,TInd.XInd(i)))==-1,1,"last");
    %         if height(minindex) == 0
    %             TInd.YIndmin(i) = nan;%検出されなければNAN
    %         else
    %             TInd.YIndmin(i) = minindex;%こちらは、1から0になるので+1は不要
    %         end
    
    %         TInd.TomitaMethodInd(i) = TInd.YIndmax(i) + nnz(BW(:,TInd.XInd(i)))*0.5;%検出されなければNAN
        end
        TInd = addvars(TInd,A,'NewVariableNames',num2str(border(l),"YInd%d"));
    %     TInd.YIndave = mean(TInd{:,["YIndmax" "YIndmin"]},2);
        TCoord = addvars(TCoord,(BasePlateTable.YInd - TInd.(num2str(border(l),"YInd%d"))) *mmPerPixel.(append(sCamNo,"Y")),'NewVariableNames',num2str(border(l),"Mistheight%d"));
    end
%     TCoord.fheightTomita = (BasePlateTable.YInd - TInd.TomitaMethodInd) *mmPerPixel.(append(sCamNo,"Y"));
end
