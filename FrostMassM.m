%Presettingが必要
PostProcessingSetting;

ExcelT = loadExpDataTable(ExpParentPath);
idx = find(ExcelT.CaseNo == 700006);

%vlookup(ExcelT,700006,59,5);
% データの準備
x = [1 2 3 4 5]; % x軸の値
y1 = [2 4 6 8 10]; % y軸の値（1番目の系列）
y2 = [1 3 5 7 9]; % y軸の値（2番目の系列）
y3 = [3 6 9 12 15]; % y軸の値（3番目の系列）
y = [y1; y2; y3]; % y軸の値を行列にまとめる

% 積み上げグラフの作成
bar(x, y, 'stacked') % 積み上げグラフを描画する
xlabel('X') % x軸のラベルを設定する
ylabel('Y') % y軸のラベルを設定する
legend('y1', 'y2', 'y3') % 凡例を表示する
title('Stacked Bar Graph') % グラフのタイトルを設定する
