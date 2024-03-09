function [rect,err] = generateCropRectForPostProcessing(CamName,sCamNo,CropRect,PixelPerMm)
    if isnan(PixelPerMm.(append(sCamNo,"X"))) || isnan(PixelPerMm.(append(sCamNo,"Y")))
        rect = [0 0 0 0];
        err = true;
        return;
    end
    err = false;
    x0 = CropRect.(CamName)(1)*PixelPerMm.(append(sCamNo,"X"));
    y0 = CropRect.(CamName)(2)*PixelPerMm.(append(sCamNo,"Y"));
    width = CropRect.(CamName)(3)*PixelPerMm.(append(sCamNo,"X"));
    height = CropRect.(CamName)(4)*PixelPerMm.(append(sCamNo,"Y"));
    rect = [x0 y0 width height];%トリミング
end