function [T,err] = loadfThicknessData(ExpParentPath,RUNNUMBER)
%UNTITLED9 この関数の概要をここに記述
%   詳細説明をここに記述
    
    fname = append(RUNNUMBER,"_fThicknessData_60_");
    if not(isfile(fullfile(ExpParentPath,"thickness",RUNNUMBER,append(fname,".mat"))))
        err = true;
        T = table;
        return
    end
    
    m = matfile(fullfile(ExpParentPath,"thickness",RUNNUMBER,append(fname,".mat")));
    T = m.(fname);
    err = false;
end