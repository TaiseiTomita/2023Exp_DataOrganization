function p = plotmThThicknessData(ThT,mT,Time,border)
%UNTITLED9 この関数の概要をここに記述
%   詳細説明をここに記述
    
    mData = mT.DataT{mynearest(mT.ETime) == Time};
    ThData = ThT.DataT{mynearest(ThT.ETime) == Time};
    if height(ThData) == 0
        p = [];
        return
    end
    A = mData.(num2str(border,"Mistheight%d"));
    p = plot(ThData.XCoord(ThData.XCoord > 0 & ThData.XCoord < 50), A(ThData.XCoord > 0 & ThData.XCoord < 50)- ThData.fheight(ThData.XCoord > 0 & ThData.XCoord < 50));
    
    xlabel("x / mm")
    ylabel("\delta_{f} / mm")
end


