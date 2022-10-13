function output_image = slic_super_pixel(img, n)
    % Lets try this
    img = (img);
    struct
    [clusters, S, img] = initialize_cluster(img, n)

    function clusters = move_to_low_grad(img, clusters)

    end

    function clusters = reset(clusters)

        for index = 1:numel(clusters)
            % Nullify counters
            cluster(index).n = 0;
            cluster(index).z = 0;
        end

    end

    function [clusters] = sample_cluster(img, clusters, S, id)
        c_x = cluster(id).x;
        c_y = cluster(id).y;
        best_cluster = struct("x",0,"y",0,"cid",1);
        for y = -S:S

            for x = -S:S
                % Get a sample of the clusters
                d = distance(img, x + c_x, y + c_y, clusters(id));
                
                if d < img(c_y + y, x_d + x).d
                    best_cluster.x = c_y + y;
                    best_cluster.y = c_y + y;
                    best_cluster.cid = c_y + id;
                end

            end

        end
        
                    % The cluster now contains one more element
                    clusters(id).n = clusters(id).n +1;
                    clusters(id).z = [clusters(id).z(1)+]
                    img(c_y + y, x_d + x).d = d;
                    img(c_y + y, x_d + x).l = id;

    end

    function d = distance(img, x, y, cluster, S)
        % A modifier, just like in the original paper
        M = S;
        % TODO: Handle out of bounds
        % Computes sum of euclidian distance and color distance
        % This is an approximation since it only works for greyscale
        d = abs(img(y, x).value - cluster.value) + (M / S) * sqrt((x - cluster.x)^2 + (y - cluster.y)^2);

    end

    function [clusters, S, output_image] = initialize_cluster(img, n)
        output_image = repmat(struct('l', -1, 'd', inf, 'value', 0), size(img, 1), size(img, 2));
        % Compute S§
        S = floor(sqrt((size(img, 1) * size(img, 2)) / n));

        % Sample the image
        clusters = repmat(struct('value', 0, 'x', 0, 'y', 0, 'n', 0, 'z', [0, 0]), n, 1);
        counter = 1;

        for y = floor(S / 2):S:size(img, 1)

            if counter > n
                break;
            end

            for x = floor(S / 2):S:size(img, 2)

                if counter > n
                    break;
                end

                cluster = [];
                % Just grab the latest element
                P = [];
                P.l = -1;
                P.d = inf;
                P.value = img(y, x);
                output_image(y, x) = P;
                clusters(counter) = struct('value', img(y, x), 'x', x, 'y', x, 'n', 0, 'z', [0, 0]);
                counter = counter + 1;
            end

        end

    end

    function offset = min_grad(img, start_x, start_y, n)
        min = [start_x, start_y, grad(img, start_x, start_y)];

        for x = start_x:start_x + n

            for y = start_y:start_y + n
                g = grad(img, x, y);

                if g < min(3)
                    min = [x, y, g];
                end

            end

        end

        offset = min(1:2);

        function grad = gradient(img, x, y)
            % Computes the gradient at a given x and y index
            xp1 = x + 1;
            yp1 = y + 1;
            xm1 = x - 1;
            ym1 = y - 1;
            % Handle wrapping
            if xp1 > size(img, 1)
                xp1 = 1;
            end

            if yp1 > size(img, 2)
                yp1 = 1;
            end

            if xm1 < 1
                xm1 = size(img, 1);
            end

            if ym1 < 1
                ym1 = size(img, 2);
            end

            % Compute grad according to the  method described in the paper
            grad = abs(img(xp1, y) - img(xm1, y))^2 +abs(img(x, yp1) - img(x, ym1))^2;
        end

    end

end
