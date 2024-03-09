function [T] = loadExpDataTable(ExpParentPath)
%UNTITLED2 ExpDataTableをロード
%   詳細説明をここに記述
    m = matfile(fullfile(ExpParentPath,"MATLAB/MAT/ExpDataTable.mat"));
    T = m.ExpDataTable;
end