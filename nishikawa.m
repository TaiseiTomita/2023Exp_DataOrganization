RUNNUMBER = "Run120607";
folderpath = fullfile(ExpParentPath,"Convert","Cam4","Image",RUNNUMBER);
savepath = fullfile(ExpParentPath,"ProcessedImage","Side(LED)");

cd(savepath)
mkdir(RUNNUMBER)

A = imageDatastore(folderpath);

for i = 1:height(A.Files)
    I = fliplr(readimage(A,i));
    filename = append(RUNNUMBER,"_",string(i));
    imwrite(I,fullfile(savepath,RUNNUMBER,append(filename,".tiff")));

end