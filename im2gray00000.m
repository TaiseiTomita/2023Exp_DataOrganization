PostProcessingSetting;

% imagefolder = "F:\2023FlatplateExp\ThicknessMeasurementAccuracy";
% imagename = "GeenLaser";
% savefolder = "F:\2023FlatplateExp\ThicknessMeasurementAccuracy";
savename = "Red";


I = imread("F:\2023FlatplateExp\ThicknessMeasurementAccuracy\RedLaser.tif");

boder = [100,40];

for i = 1:width(boder)
    
    BW = I(:,:,1) > boder(i);
    imwrite(BW,fullfile(savefolder,append(savename,"_",string(boder(i)),".tiff")));

end