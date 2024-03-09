function figExport2(fig, x, y, fs, fn)
 
    if      fn == 'T'; fn = 'Times New Roman';
    elseif  fn == 'A'; fn = 'Arial'          ; end
     
    fig.Units         = 'centimeters';
    fig.PaperUnits    = 'centimeters';
    fig.PaperType     = 'a4';
    fig.PaperPosition = [2, 2, x, y];
    fig.Position      = [2, 2, x, y];
     
    if isa(fig.Children, 'matlab.graphics.layout.TiledChartLayout') 
        fig = fig.Children;
    end
     
    nAxes = length(fig.Children);
    for iAxes = 1 : nAxes
        if isa(fig.Children(iAxes), 'matlab.graphics.axis.Axes') 
            set(fig.Children(iAxes), 'FontName', fn)
            set(fig.Children(iAxes), 'FontSize', fs)

            set(fig.Children(iAxes), 'TitleFontSizeMultiplier', 1)
            set(fig.Children(iAxes), 'TitleFontWeight', 'normal')
            fig.Children(iAxes).XLabel.FontSize = fs;
            fig.Children(iAxes).YLabel.FontSize = fs;
            fig.Children(iAxes).ZLabel.FontSize = fs;
            if ~isempty(fig.Children(iAxes).Legend)
                fig.Children(iAxes).Legend.FontSize = fs; end
            fig.Children(iAxes).Title.FontSize = fs;
        end
    end
end