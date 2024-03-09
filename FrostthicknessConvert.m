%%霜厚さのグラフ化のコード
PostProcessingSetting;
ExcelT = loadexcelfile(ExpParentPath,Excelfilename);

D = 100;  %　D秒毎の霜厚さのグラフを出力

for a = 1:height(ExcelT.RUNNUMBER)
    RUNNUMBER =  ExcelT.RUNNUMBER(a)
    %RUNNUMBER = "Run111606";
  %%エラーかどうかの判別
   if ExcelT.TiltCameraTrigger(a) ~= "CamTrigger3" 
      disp("Not TiltData !!")
      continue;
   end

    if isfile(fullfile(ExpParentPath,"thickness",RUNNUMBER,"Frost","Frost.mat")) == 0
       disp("NO Frost file!!!")
       continue;
    end
    load(fullfile(ExpParentPath,"thickness",RUNNUMBER,"Frost","Frost.mat"));

    if ExcelT.duration(a) > height(Allthickness)
        disp("lack CamData (>_<)!!");
        continue;
    end

%%霜厚さのグラフ化 

    legendBox = [];%初期化
    figure(Visible="off");
    hold on
    xlim([-10 70]);%X軸の範囲を指定
    ylim([-0.5, 4]);%Y軸の範囲を指定
    pbaspect([3 1 1]);%クラフの大きさを指定
    xlabel('前端からの距離 [mm]');%x軸のラベル
    ylabel('霜厚さ [mm]');%y軸のラベル

    for i = 1:ExcelT.duration(a)+1
        if rem(i,D) == 1      
            plot(double(Allthickness(1,2:width(Allthickness))),double(Allthickness(i+1,2:width(Allthickness))));
            legendBox = [legendBox,append(Allthickness(i+1,1),'s')];
        end
    end
    fname = append(RUNNUMBER,'_','Width=',string(D));
    legend(legendBox);
    saveas(gcf,fullfile(ExpParentPath,"thickness",RUNNUMBER,"Frost",append(fname,".png")))
    hold off
    disp("make file !!")
end


function T = loadexcelfile(ExpParentPath,Excelfilename)
    ExcelFilePath = fullfile(ExpParentPath,"Docs",Excelfilename);
    T = convert2TableExperimentConditionExcelFile(ExcelFilePath,"Data");
    T = T(T.State=="Done" | T.State=="Except",:);
end