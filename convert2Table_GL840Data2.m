function [TempTT,VoltTT] = convert2Table_GL840Data2(DataFolderPath,RunName,VarNames)
    arguments
        DataFolderPath (1,1) string
        RunName (1,1) string
        VarNames (1,20) cell
    end

    VarNames = [{'Time','ETime'} VarNames];

    TempUnits = ...
            {'s','s',...
            '℃','℃','℃','℃','℃',...
            '℃','℃','℃','℃','℃',...
            '℃','℃','℃','℃','℃',...
            '℃','℃','℃','℃','℃'};

    VoltageUnits = ...
            {'s','s',...
            '℃','℃','℃','℃','℃',...
            '℃','℃','℃','℃','℃',...
            '℃','℃','℃','℃','℃',...
            '℃','℃','℃','℃','℃'};

    % GL840の計測データの整理
    % 温度計測データの読み込み + 使わないデータは削除
    Tempfile = fullfile(DataFolderPath,RunName,append(RunName,'_Temp_GL840.csv'));
    opts = detectImportOptions(Tempfile,"ReadVariableNames",false,"NumHeaderLines",1);
    opts.VariableNames = VarNames;
    TempT = readtable(Tempfile,opts); 
    TempT.Properties.VariableUnits = TempUnits;
    TempT.Time = TempT.Time/1000;
    TempT.Time = convetlabviewtime2datetime(TempT.Time);
    TempTT = table2timetable(TempT);
    TempTT(1,:) = [];

    % 電圧計測データの読み込み + 使わないデータは削除
    Voltagefile = fullfile(DataFolderPath,RunName,append(RunName,'_Volt_GL840.csv'));
    opts = detectImportOptions(Voltagefile,"ReadVariableNames",false,"NumHeaderLines",1);
    opts.VariableNames = VarNames;    
    VoltT = readtable(Voltagefile,opts);
    VoltT.Properties.VariableUnits = VoltageUnits;
    VoltT.Time = VoltT.Time/1000;
    VoltT.Time = convetlabviewtime2datetime(VoltT.Time);
    VoltTT = table2timetable(VoltT);   
    VoltTT(1,:) = [];

%     T = TempT(:,["Time","ETime"]);
%     T.Time = convetlabviewtime2datetime(T.Time);
%     
%     for i = 1:20
%         if TempDataLoical(i)
%             T = [T TempT(:,i+2)];
%         else
%             T = [T VoltT(:,i+2)];
%         end
%     end
    
%     T = Volt2Velocity_KANOMAX(T,"AirVelocityV"); % 流速のデータを電圧から変換
%     T = addvars(T,T.AirVelocity_in/(0.17d0*0.17d0),NewVariableNames="AirVolumeVelocity");
%     T = addvars(T,T.AirVolumeVelocity/(0.027d0*0.1d0),NewVariableNames="AirVelocity_TS");
%     T = Volt2RH_OMRON_ES2THBN(T,"VAirRH_in","AirTemp_in");

%     T = addvars(T,T.IR1V/5.0d0*100d0-50d0,NewVariableNames="T_IR1");
%     T = addvars(T,T.IR2V/5.0d0*100d0-50d0,NewVariableNames="T_IR2"); 
end

