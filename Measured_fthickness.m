PostProcessingSetting;

RUNNUMBER = "Run101801";
fname = "PlateEdgeParameter";
close

ExcelT = loadExpDataTable(ExpParentPath);
T = ExcelT(ExcelT.RUNNUMBER == RUNNUMBER,:);

sCamNo = string(T.TiltCamera);

if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(RUNNUMBER,"_",fname,"Tilt",".mat"))) == 1

    folderpath = fullfile(ExpParentPath,"Calibration",sCamNo,RUNNUMBER);
    I = imageDatastore(folderpath);
    I1 = fliplr(imcrop(readimage(I,1),CropRect.Tilt));
    if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(RUNNUMBER,"_","Calibratoinboard",".mat"))) == 0
        [imagePoints,boardSize] = detectCheckerboardPoints(I1);
        save(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(RUNNUMBER,"_","Calibratoinboard",".mat")),"imagePoints","boardSize","-mat")
    end

    Cab = load(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(RUNNUMBER,"_","Calibratoinboard",".mat")));

    A = load(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(RUNNUMBER,"_",fname,"Tilt",".mat")));
    Plate = A.(append(RUNNUMBER,"_",fname,"Tilt")).(fname);

    [TInd] = flatplate(Plate,width(I1));%各位置における0mmの座標
    
    fname1 = "000001200";
    I2 = imread(fullfile(ExpParentPath,"Convert",sCamNo,"Image",RUNNUMBER,append(RUNNUMBER,"_",fname1,".tiff")));

    [TInd] = fthickness(I2,TInd,IMFrostborder,CropRect.Tilt);%霜厚さのピクセルを算出

    %%　キャリブレーションボードを元に高さを算出
    [fThickness] = measurefThickness(TInd,Cab);

    figure;hold on
    ylim([-0.5 4])
    plot(TInd.XInd/,fThickness)
    hold off
    
end


function [TInd] = flatplate(Plate,Width) %各位置における0mmのY座標の算出
    TInd.YInd = [];
    TInd.XInd = [];
    a = (Plate(1,2)-Plate(2,2))/(Plate(1,1)-Plate(2,1));
    b = -Plate(1,1)*a + Plate(1,2);
    for i = 1:Width
        TInd.YInd = [TInd.YInd;a*i+b];
        TInd.XInd = [TInd.XInd;i];
    end
end

function [TInd,BW] = fthickness(Iin,TInd,border,crop)
     BW = Iin(:,:,1) >= border;%R成分のみ抽出して 二値化
     BW = fliplr(imcrop(BW,crop));

    for i = 1:height(TInd.XInd)
        maxindex = find(diff(BW(:,TInd.XInd(i)))==1,1,"first"); %1wを探索
        if height(maxindex) == 0
            TInd.YIndmax{i} = nan;%検出されなければNAN
        else
            TInd.YIndmax{i} = maxindex+1;%差分をとる関係で、1に切り替わるインデックスは＋1
        end

        minindex = find(diff(BW(:,TInd.XInd(i)))==-1,1,"last");
        if height(minindex) == 0
            TInd.YIndmin{i} = nan;%検出されなければNAN
        else
            TInd.YIndmin{i} = minindex;%こちらは、1から0になるので+1は不要
        end
    end
    TInd.YIndave = mean(transpose(cell2mat(vertcat(TInd.YIndmax,TInd.YIndmin))),2);
end

function [fThickness] = measurefThickness(TInd,Cab)

    for j = 1:Cab.boardSize(1)-1
        for i = 1:height(Cab.imagePoints)/(Cab.boardSize(1)-1)      
            Aveheight{j} = Cab.imagePoints(j+(Cab.boardSize(1)-1)*(i-1),2);
        end
    end
    Aveheight1 = flip(Aveheight);
    board = diff(cell2mat(Aveheight)) / 0.5;

    for i = 1:height(TInd.YInd)

        fThickness(i) = 0;
        if isnan(TInd.YIndave(i)); fThickness(i) = NaN;continue;end
        if TInd.YIndave(i) > TInd.YInd(i); fThickness(i) = NaN;continue;end
    
        for j = 1:width(board)  
            if j == 1
                if cell2mat(Aveheight1(2)) > TInd.YIndave(i)
                    fThickness(i) = abs(cell2mat(Aveheight1(2))-TInd.YInd(i))...
                                    /board(1);
                else
                    fThickness(i) = abs(TInd.YIndave(i)-TInd.YInd(i))...
                                /board(1);
                    break
                end

            elseif TInd.YIndave(i) < cell2mat(Aveheight1(j))
                fThickness(i) = abs(cell2mat(Aveheight1(j-1))-cell2mat(Aveheight1(j)))...
                                /board(j-1) + fThickness(i);
            else
                fThickness(i) = abs(cell2mat(Aveheight1(j-1))-TInd.YIndave(i))...
                                /board(j-1) + fThickness(i);
                break;
            end
        end

    end

end

% function [widthlength] = measureflength(Cab)
%      for j = 1:Cab.boardSize(1)-1
% 
% 
% 
% end


