function [T,err] = loadmThicknessData(ExpParentPath,RUNNUMBER)
%UNTITLED9 この関数の概要をここに記述
%   詳細説明をここに記述
    
    fname = append(RUNNUMBER,"_mThicknessData_v2");
    if not(isfile(fullfile(ExpParentPath,"thickness",RUNNUMBER,append(fname,".mat"))))
        err = true;
        T = table;
        return
    end
    
    m = matfile(fullfile(ExpParentPath,"thickness",RUNNUMBER,append(fname,".mat")));
    T = m.(fname);
    err = false;
end