for CamNo = 1:4
    cd(fullfile(ExpParentPath,"Convert",num2str(CamNo,"Cam%d"),"Image"))
    Flist = dir("Run*");
    for l=5:height(Flist)
        RUNNUMBER = Flist(l).name;
        disp(num2str(CamNo,"Cam%d") + " : " + RUNNUMBER)
    
        OriginalFolder = fullfile(ExpParentPath,"Convert",num2str(CamNo,"Cam%d"),"Image",RUNNUMBER);
        FFFF = dir(fullfile(OriginalFolder,"*.tiff"));
        if height(FFFF) == 0;continue;end
        % if not(isfolder(OriginalFolder));disp("NO CamData file!!!");continue;end
        DS = imageDatastore(OriginalFolder);
        for i = 1:height(DS.Files)
            status = movefile(DS.Files{i},erase(DS.Files{i},"_time"));
        end
    
        OriginalFolder = fullfile(ExpParentPath,"Convert",num2str(CamNo,"Cam%d"),"TimeHistory",RUNNUMBER);
        % if not(isfolder(OriginalFolder));disp("NO CamData file!!!");continue;end
        FFFF = dir(fullfile(OriginalFolder,"*.csv"));
        for i = 1:height(FFFF)
            status = movefile(fullfile(FFFF(i).folder,FFFF(i).name),replace(fullfile(FFFF(i).folder,FFFF(i).name),"_time_","_"));
        end
    end
end
