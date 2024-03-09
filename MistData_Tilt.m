%% 
% 初期設定

Runnumber = "Run111805";
Frostborder = 10; %40
outputPath = "F:\2023FlatplateExp\thickness\";
inputPath = "F:\2023FlatplateExp\ProcessedImage\Tilt(GREEN)\";
%% 
% パスの追加

addpath 'F:\'
%% 
% 諸データの取得
% 
% パス、基準の座標の算出(選択する時、線の下側をクリック

%[Runnumber] = MistPlotData1(Runnumber,Frostborder,outputPath,inputPath);
%%
%function [Runnumber] = MistPlotData1(Runnumber,Frostborder,outputPath,inputPath)

    load("F:\2023FlatplateExp\Measured\Run111805\Run111805_CalibrationData.mat");
    load("F:\2023FlatplateExp\Measured\Run111805\Run111805_TrimParameterTilt.mat");
    for k = 1:4
        Camnum = num2str(k,"Cam%d");
        if (isnan(mmPerPixcelY.(Camnum))==0) && (isnan(mmPerPixcelX.(Camnum))== 0)
           images = imageDatastore(fullfile(inputPath,Runnumber));

            A = (Trim(1,2)-Trim(2,2))/(Trim(1,1)-Trim(2,1));
            B = Trim(1,2) - Trim(1,1)*A;
            [ycell,xcell] = size(im2gray(readimage(images,1)));
            thickness1 = nan(1,xcell);
            for i = 1:xcell
                thickness1(1,i) = (A*i + B)/mmPerPixcelX.(Camnum);
            end


            Frostborder1 = string(Frostborder);
            NAME = append('Border',Frostborder1);
%% 
% ファイルの生成

            cd(outputPath)
            mkdir (Runnumber)
            cd(Runnumber)
            mkdir Mist
            savefile = fullfile(outputPath,Runnumber,"Mist");
%% 
% 霜厚さの計算

            figure(Visible="off");
            hold on 
                                
            xlim([-10 70]);%X軸の範囲を指定
            ylim([-0.5, 6]);%Y軸の範囲を指定
            pbaspect([3 1 1]);%クラフの大きさを指定
            xlabel('前端からの距離 [mm]');%x軸のラベル
            ylabel('霜厚さ [mm]');%y軸のラベル
            for t = 1:height(images.Files)
                if rem(100,t) == 1
                  image1 = readimage(images,t);
                  Newimage2 = image1(:,:,2);% G成分のlogical配列のみ抽出
%% 
% 画像を二値化(一旦,色の濃さを最大まで引き上げています),

                   BW2 = Newimage2 >= Frostborder;   
                   %figure (Visible="on")
                   %imshow(BW2)
%% 厚みを求める方針
% 1,両方の画像で黒が白に切り替わるピクセルを求める
% 
% 2, 白ピクセルの数を数えて,半分にする
% 
% 3, その差分を取ることで,レーザーの上辺同士の差となるため,霜厚さを測定したことになる
% 着霜後の黒が白に切り替わるピクセルを求める計算(NaNで外れ値を弾くこともしている)

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
%% 
% 霜の厚みを求める計算+グラフの明らかな外れ値を弾く補正

                             thickness = zeros(1,xcell);
                              for i = 1:xcell
                                         thickness(1,i) = thickness1(1,i) - (thickness2(1,i));
                              end
%% 
% X座標を求める計算

                              xplot = ones(1,xcell);
                            
                               for i = 1:xcell
                                    xplot(1,i) = (i - Trim(1,1))/mmPerPixcelX.(Camnum);
                               end
%% 
% グラフの設定･保存、ファイル名の指定   

                   plot(xplot,thickness);%線グラフ
                end
            end
        end
        
            filename1 = append(Runnumber,'_Mist_',NAME,'.jpg');
            filename = fullfile(savefile,filename1);%ファイル名
            legend('0s','100s','200s','300s','400s');
            
            %if isfile(filename) == 0
               saveas(gcf,filename);%保存 
            %end
            
            hold off
    end
    
%end