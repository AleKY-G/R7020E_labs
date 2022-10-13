



function [feed,features,featuresa,featuresb] = feature_match(feed,img1, ...
                                                img2, varargin)
    % A function that maches features in 2 images. It returns the current
    % feed ( or context ) the features matched, the features detected in
    % image1, and the feature detected in image b in that order.
    % 
    % The features can be matched using either Harris or the SIFT detector,
    % Allowing the end user to use the optimal one for their usecase.
    % The default feature detector is HARRIS, but if you want to change it
    % to SIFT, then just pass SIFT in as the 4th argument.

    function [args] = parse(vararg)
        % Assume no inputs
        args = "";
        % We only want to handle 1 optional arument
        if (numel(vararg) >= 2)
            % Since we only want to handle a set of different methods we
            % can assume that the method is the first argument
            args = vararg{2};
        end
    end
    [method] = parse(["",varargin{:}]);
    
    if strcmpi(method,"SIFT")
        featuresa = detectSIFTFeatures(img1);
        featuresb = detectSIFTFeatures(img2);
        
    
        % Get feature descriptors
        [features1,loc1] = extractFeatures(img1,featuresa,"Method",method);
        [features2,loc2] = extractFeatures(img2,featuresb,"Method",method);
    else
        featuresa = detectHarrisFeatures(img1);
        featuresb = detectHarrisFeatures(img2);
        
    
        % Get feature descriptors
        [features1,loc1] = extractFeatures(img1,featuresa);
        [features2,loc2] = extractFeatures(img2,featuresb);
    end

    % Match the features using said descriptors
    features = matchFeatures(features1,features2);
    
    % Store the result for later use
    obj = [];
    obj.img1 = img1;
    obj.img2 = img2;
    obj.loc1 = loc1;
    obj.loc2 = loc2;
    obj.features = features;
    obj.features1 = featuresa;
    obj.features2 = featuresb;
    
    % Append the current feature match to the previous matches
    feed = [feed; obj];
end
