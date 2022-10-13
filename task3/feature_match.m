

function [feed,features] = feature_match(feed,img1,img2)
    % Not quite sure what we are inteded to do here, we might be intended
    % to do this "inplace" but if that were the case it would not be
    % suitible for online implementations. So instead this implementation
    % will take in a "feed" variable, which will contain all the previous
    % feature matched images, 
    
    % Get the features from the image using SIFT
    features1 = detectSIFTFeatures(img1);
    features2 = detectSIFTFeatures(img2);
    

    % Get feature descriptors
    [features1,loc1] = extractFeatures(img1,features1);
    [features2,loc2] = extractFeatures(img2,features2);
    % Match the features
    features = matchFeatures(features1,features2);
    % Display the matched images
    showMatchedFeatures(img1,img2,loc1(features(:,1),:),loc2(features(:,2),:));
    obj = [];
    obj.img1 = img1;
    obj.img2 = img2;
    obj.loc1 = loc1;
    obj.loc2 = loc2;
    obj.features = features;
    feed = [feed; obj];
end
