function points = harris_corners(img,thresh)
% Computes corners in a provided image [img], thresholding with the value specified in thresh
%
% Returns an array of points where each point represens a corner
% A corner is represented with a vector [x,y,confidence,Ix,Iy]

       % Create the two filters, index 1 is horisontal gradient
       % index 2 is vertical gradient
       gray = im2double(im2gray(img));
       dx = [ -1 0 1];
       dy = dx';
       % Compute gradiants
       gradx = imfilter(gray,dx,'replicate','conv');
       grady = imfilter(gray,dy,'replicate','conv');
       
       % Greatly improves performance
       gauss = fspecial("gaussian",3,.5);

       gradxx = imfilter(gradx.^2,gauss);
       gradyy = imfilter(grady.^2,gauss);
       gradxy = imfilter(gradx.*grady,gauss);

       % Create temporary array to hold the lambda1 value
       harris = zeros(size(gray));
       for i = 1:size(gray,1)
           for j = 1:size(gray,2)
                H = [
                        gradxx(i,j) gradxy(i,j);
                        gradxy(i,j) gradyy(i,j)
                    ];
                lambda1 = det(H) / trace(H);
                if trace(H) ~= 0
                    harris(i,j) = abs(lambda1);
                end
           end
       end

       % get mean R before the non maxima suppression
       meanval = mean(mean(harris));
       % The threashold value is decided by a multiple of the mean val and
       % a user provided thresh value
       threshold = meanval*thresh;
       % Holding variable, this will change size on every itteration, since
       % matlab has no good dpp support this is the way it has to be. And I
       % can't pre allocate without risking memory waste
       points = [];

       % size of non max kernel
       n = 7;
       n = floor(n/2);
       % non maxima suppression
       for i = 1+n:size(harris,1)-n
           for j = 1+n:size(harris,2)-n
                v = harris(i,j);
                % Threshold the image
                if v < threshold
                    continue
                end
                % assume it's a max
                max = 1;
                for k = -n:n
                    for l = -n:n
                        if v < harris(i+k,j+l)
                            max = 0;
                        end
                    end
                end
                
                if max
                    points = [points;[i,j,v,gradx(i,j),grady(i,j)]];
                end
           end
       end
end