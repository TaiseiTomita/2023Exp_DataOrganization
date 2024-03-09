% 画像フォルダのパスを指定する
folder_path = 'C:\Users\mikio\Pictures\test\test';

% 画像フォルダ内のすべての画像ファイルを取得する
image_files = dir(fullfile(folder_path, '*.tiff'));

% 条件に一致するファイルのみを抽出する
selected_files = {};
for i = 1:length(image_files)
    % ファイル名を解析する
    file_name = image_files(i).name;
    file_parts = split(file_name, '_');
    file_ext = split(file_name, '.');
    file_num = str2double(file_parts(end-1));
    if mod(file_num, 3) == 2 && strcmp(file_ext(end), 'tiff')
        selected_files{end+1} = file_name;
    end
end

% 抽出されたファイルに対して、輝度を調整する
for i = 1:length(selected_files)
    % 画像を読み込む
    img = imread(fullfile(folder_path, selected_files{i}));

    % 画像の輝度を調整する
    img_adjusted = imadjust(img, [0.2 0.8], []);

    % 調整後の画像を保存する
    new_folder_path = 'C:\Users\mikio\Pictures\test\save';
    imwrite(img_adjusted, fullfile(new_folder_path, selected_files{i}));
end
