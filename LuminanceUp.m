% 画像フォルダのパスを指定する
folder_path = 'F:\Image\Tilt\LED\Run111702_-75R';

% 画像フォルダ内のすべての画像を読み込む
image_files = dir(fullfile(folder_path, '*.tiff'));
num_images = length(image_files);

% 画像の輝度を調整する
for i = 1:num_images
    % 画像を読み込む
    img = imread(fullfile(folder_path, image_files(i).name));

    % 画像の輝度を調整する
    img_adjusted = imadjust(img, [0.2 0.8], []);

    % 調整後の画像を保存する
    new_folder_path = 'C:\Users\mikio\Pictures\test\save1';
    imwrite(img_adjusted, fullfile(new_folder_path, image_files(i).name));
end
