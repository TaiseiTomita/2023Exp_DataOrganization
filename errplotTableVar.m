function p = errplotTableVar(T,XvarName,YvarName,zeropading)
    %   テーブルTからエラーバープロットを作成
    %  
    %   T : Table include all objective data
    %   XvarName : X軸として使用するデータのT内での変数名（この変数でデータはグループ化されます）
    %   YvarName : Y軸として使用するデータのT内での変数名
    %   zeropading : [0 0]をプロットに追加するか（オプション、デフォルトはfalse）

    arguments
        T
        XvarName (1,1) string
        YvarName (1,1) string
        zeropading (1,1) logical = false
    end
    gT = groupsummary(T,XvarName,["min" "max" "mean"],YvarName);
    
    x = gT.(XvarName);
    y = gT.(append("mean_",YvarName));
    pos = gT.(append("max_",YvarName)) - gT.(append("mean_",YvarName));
    neg = gT.(append("mean_",YvarName)) - gT.(append("min_",YvarName));
    
    if zeropading
        x = [0;x];y = [0;y];pos=[0;pos];neg=[0;neg];
    end
    p = errorbar(x,y,neg,pos);
    p.LineStyle = "-";p.Marker = 'o';p.MarkerFaceColor ="auto";
end