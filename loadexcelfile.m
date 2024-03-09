function T = loadexcelfile(ExpParentPath,Excelfilename)
    arguments
        ExpParentPath  (1,1) string 
        Excelfilename (1,1) string 
    end
    ExcelFilePath = fullfile(ExpParentPath,"Docs",Excelfilename);
    T = convert2TableExperimentConditionExcelFile(ExcelFilePath,"Data");
    T = T(T.State=="Done" | T.State=="Except",:);
end
