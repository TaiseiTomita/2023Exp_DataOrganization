function [Iout] = ImagePostProcessing0(Iin,croprect,angle,cropSkip,flipSkip)%トリミングと回転
    arguments
        Iin
        croprect  (1,4) double
        angle (1,1) double
        cropSkip (1,1) logical
        flipSkip (1,1) logical
    end
    
    

    if flipSkip
        I1 = Iin;
    else
        I1 = fliplr(Iin);
    end

    if angle ~= 0
        I1 = imrotate(I1,angle,"crop");
    end
    
    if cropSkip
        Iout = I1;
    else
        Iout = imcrop(I1,croprect);
    end
    
end