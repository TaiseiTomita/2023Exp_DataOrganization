function p = plotfThicknessData(T,Time)
%UNTITLED9 この関数の概要をここに記述
%   詳細説明をここに記述
    
    Data = T.DataT{mynearest(T.ETime) == Time};
    if height(Data) == 0
        p = [];
        return
    end

    plot(Data.XCoord,Data.fheight)
    
    xlabel("x / mm")
    ylabel("\delta_{f} / mm")
end