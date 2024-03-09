PostProcessingSetting;

ExcelT = loadexcelfile(ExpParentPath,Excelfilename);


outputPath = "F:\2023FlatplateExp\thickness\";
inputPath = "F:\2023FlatplateExp\ProcessedImage\Tilt(RED)\";



% 初期設定
for a = 1:height(ExcelT.RUNNUMBER)
    RUNNUMBER = ExcelT.RUNNUMBER(a)
    Frostborder = 80; %40
    Allthickness = [];
    %% フィルターをかける
        matfname = append(RUNNUMBER,"_CalibrationData");
        if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(matfname,".mat"))) == 0
            disp("NO CalibrationData file!!!")
            continue;
        end
        load(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(matfname,".mat")));

        fname = append(RUNNUMBER,"_PlateEdgeParameterTilt");
        if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat"))) == 0
            disp("NO TrimParameterTilt file!!!")
            continue;
        end
        m = matfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat")),'-mat');
        Trim = m.(fname);

        fname = append(RUNNUMBER,"_TiltTriggerTT");
        if isfile(fullfile(ExpParentPath,"Measured",RUNNUMBER,append(fname,".mat"))) == 0
            disp("NO TiltTriggerTT File");
            continue;
        end
        

        for k = 1:4
            L = 0;
            Camnum = num2str(k,"Cam%d");


            if  ExcelT.TiltCamera(a) == Camnum
                images = imageDatastore(fullfile(inputPath,RUNNUMBER));
    
                A = (Trim(1,2)-Trim(2,2))/(Trim(1,1)-Trim(2,1));
                B = Trim(1,2) - Trim(1,1)*A;
                [ycell,xcell] = size(im2gray(readimage(images,1)));
                thickness1 = nan(1,xcell);
                for i = 1:xcell
                    thickness1(1,i) = (A*i + B)/mmPerPixcelX.(Camnum);
                end
               
    %% ファイルの生成
                cd(outputPath)
                mkdir (RUNNUMBER)
                cd(fullfile(outputPath,RUNNUMBER))
                mkdir Frost

    %% 霜厚さの計算
                for t = 1:height(images.Files)
               
                      image1 = readimage(images,t);
                      Newimage2 = image1(:,:,1);% R成分のlogical配列のみ抽出
    
                       BW2 = Newimage2 >= Frostborder;   
                       %figure (Visible="on")
                       %imshow(BW2)
    %% 厚みを求める方針
                      thickness2 = zeros(1,xcell);   
                      maxhight2 = 0;
                    
                      for i = 1:xcell
                        for j = 2:ycell
                            if (BW2(j,i) == 1) && (BW2(j-1,i) == 0)%黒が白に切り替わるタイミング
                                maxhight2 = j;
                                break
                            end
                        end
                        thickness2(1,i) = maxhight2/mmPerPixcelY.(Camnum);%ピクセルをmmに変換   
                         maxhight2 = 0;%初期化
                      end
                      thickness2(thickness2==0) = NaN;%0となっている部分をNaNに変換

                      whitepixel = 0;
                      thickness4 = zeros(1,xcell);
                      for i = 1:xcell
                          for j = 1:ycell
                                if BW2(j,i) == 1
                                    whitepixel = whitepixel + 1;
                                end
                          end
                          thickness4(1,i) = whitepixel/2/mmPerPixcelY.(Camnum);%白ピクセルを数えて割る2+ピクセルをmmに変換
                          whitepixel = 0;%初期化
                      end

                     thickness = zeros(1,xcell);
                      for i = 1:xcell
                                 thickness(1,i) = thickness1(1,i) - (thickness2(1,i)+thickness4(1,i));
                      end

                      xplot = ones(1,xcell);
                    
                       for i = 1:xcell
                            xplot(1,i) = (i - Trim(1,1))/mmPerPixcelX.(Camnum);
                       end


                       Time = t-1;
                       if L == 0
                            Allthickness = horzcat("Time",xplot);
                            L = 1;
                       end
                       Allthickness = vertcat(Allthickness,horzcat(Time,thickness));          
                end 
                %if isfile(fullfile(ExpParentPath,"thickness",RUNNUMBER,"Frost",append("Frost",".mat"))) == 0
                   save(fullfile(ExpParentPath,"thickness",RUNNUMBER,"Frost",append("Frost",".mat")),'Allthickness','-mat');
                %end
            end
        end
end

%% exceldfileをロードする関数
% function T = loadexcelfile(ExpParentPath,Excelfilename)
%     ExcelFilePath = fullfile(ExpParentPath,"Docs",Excelfilename);
%     T = convert2TableExperimentConditionExcelFile(ExcelFilePath,"Data");
%     T = T(T.State=="Done" | T.State=="Except",:);
% end


       