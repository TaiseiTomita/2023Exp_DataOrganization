function [CamT] = convert2Table_cameraTriggerData(DataFolderPath,RunName,CamNo)
    arguments
        DataFolderPath (1,1) string
        RunName (1,1) string
        CamNo (1,1) double
    end

    CamLabels = ["_CamTrigger1.csv" "_CamTrigger2.csv" "_CamTrigger3.csv"];

    CamTriggerfile = fullfile(DataFolderPath,RunName,append(RunName,CamLabels(CamNo)));
    VarNames = {'Index','Time','ETime' 'Var1' 'Var2'};
    VarUnits = {'-','s','s','-','-'};

    opts = detectImportOptions(CamTriggerfile,"ReadVariableNames",false,"NumHeaderLines",1);     
    opts.VariableNames = VarNames;
    CamT = readtable(CamTriggerfile,opts); 
    CamT.Properties.VariableUnits = VarUnits;
    if size(CamT,1) ~=0
        CamT.Time = convetlabviewtime2datetime(CamT.Time/1000);
    end
    
end
