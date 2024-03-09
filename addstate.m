function TT = addstate(TT_in)

%     TT_in.TunnelState = categorical(TT_in.TunnelState);
    
    str = strings(size(TT_in,1),1);
    
    L = TT_in.TunnelState == 0;
    str(L) = "precooling";
    L = TT_in.TunnelState == 1;
    str(L) = "experiment";

    tlist = TT_in.Time(str == "experiment");
    if height(tlist) ~= 0
        t = tlist(1);        
        TT_in.ETime = seconds(TT_in.Time - t);
    end
    
    L = TT_in.TunnelState == 0 & TT_in.Time > max(tlist);
    str(L) = "ending";
    
    TT = addvars(TT_in,categorical(str),'After','ETime','NewVariableNames',{'state'});

end