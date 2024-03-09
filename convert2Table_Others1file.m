function [TT,T] = convert2Table_Others1file(DataFolderPath,RunName)
    arguments
        DataFolderPath (1,1) string
        RunName (1,1) string
    end

    % GL840の計測データの整理
    % 温度計測データの読み込み + 使わないデータは削除
    PAPfile = fullfile(DataFolderPath,RunName,append(RunName,'_Others.csv'));
    
    VarNames = {'Time','ETime','Velocity','Heatflux','AerosolV','AirSupplyV','TCYA','TCYA2','TunnelState'};
    VarUnits = {'s','s','℃','-','-','-','-','-','-'};

    opts = detectImportOptions(PAPfile,"ReadVariableNames",false);
    opts.VariableNames = VarNames;
    T = readtable(PAPfile,opts); 
    T.Properties.VariableUnits = VarUnits;
    T.Time = T.Time/1000;
    
    T.Velocity = [];
    T.Heatflux = [];
    T.AerosolV = [];
    T.AirSupplyV = [];
    T.TCYA = [];
    T.TCYA2 = [];

    T.Time = convetlabviewtime2datetime(T.Time);
    
   

%     T.TunnelState = categorical(T.TunnelState);

    T(1,:) = [];
    TT = table2timetable(T);
    TT.ETime = [];
   
end

function y = frhovap(T,RH)
    %JIS Z 8806 の式（Sonntag 1990）
    
    R_v = 4.619146689012061d2;
    
    b1 = -6096.9385d0;
    b2 = 21.2409642d0;
    b3 = -2.711193d-2;
    b4 = 1.673952d-5;
    b5 = 2.433502d0;
    
    f2 = @(x) exp(b1./x + b2 + b3*x + b4*x.^2.0d0 + b5*log(x));
   
    y = f2(T)/R_v./T.*RH/100;

end
