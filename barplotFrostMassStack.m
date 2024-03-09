function [b,p] = barplotFrostMassStack(T)
    %   テーブルTからエラーバープロットを作成
    %  
    %   T : Table include all objective data
    %   XvarName : X軸として使用するデータのT内での変数名（この変数でデータはグループ化されます）
    %   YvarName : Y軸として使用するデータのT内での変数名
    %   zeropading : [0 0]をプロットに追加するか（オプション、デフォルトはfalse）

    arguments
        T
    end
    gT= groupsummary(T,"duration",["min" "max" "mean"],["fmass"]);
    gT2 = groupsummary(T,"duration",["mean"],["fmass" "fmass_front" "fmass_rear"]);
    
    
    x = gT.duration;
    y = gT.mean_fmass;
    pos = gT.max_fmass - gT.mean_fmass;
    neg = gT.mean_fmass - gT.min_fmass;
    
    % if zeropading
    %     x = [0;x];y = [0;y];pos=[0;pos];neg=[0;neg];
    % end
    

    hold on
    b = bar(gT2.duration,gT2{:,["mean_fmass_front" "mean_fmass_rear"]},"stacked");
    
    p = errorbar(x,y,neg,pos);
    p.LineStyle = "none";p.Marker = "none";p.Color = "k";
    p.HandleVisibility = "off";
    
    hold off
end