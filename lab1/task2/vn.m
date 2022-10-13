% computes the noice variance for a given image using a specific snr
function v = vn(image,snr)
    v = var(image(:))/(100);
end