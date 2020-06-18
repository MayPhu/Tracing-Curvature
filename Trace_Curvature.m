clc;
clear all;
close all;
%% Read an input image 
img = imread ('Images/Shape1.jpg') ; 
img = rgb2gray (img);   % convert the input image to grayscale
img = imdilate(img,strel('disk',3)); % dilation to smooth the edge of the image
figure, imshow(img);

%% Start tracing the edge pixels

edge_pixel = bwboundaries(img,8); %get the edge pixels of the image

        
  for n = 1 : length(edge_pixel)  % looping to trace every pixels values along the bounday
        
        n_pixel = edge_pixel{n};  % nth pixel of the edge
       
        x = n_pixel(:, 2);      % x_coordinate value of n_pixel
        y = n_pixel(:, 1);      % y_coordinate value of n_pixel
        
        %  Horizontal direction-to-code convention is:  1  0  -1
        %                                                \ | /
        %                                             1 -- P -- -1
        %                                                / | \
        %                                               1  0  -1

        %    Vertical direction-to-code convention is:  1  1  1
        %                                                \ | /
        %                                             0 -- P -- 0
        %                                                / | \
        %                                              -1 -1  -1
        
        for p = 2 : length(n_pixel)  % start tracing from first pixel to second pixel (n=1 and p=2)
      
        coordinate{p-1} = [x(p);y(p)];
        
        
            if x(p) < x(p-1) && y(p) < y(p-1)
			% Moved to the upper left
			horizontal_code_value(p) = -1;
            vertical_code_value(p) = 1;
            
            elseif x(p) == x(p-1) && y(p) < y(p-1)
			% Moved straight up
			horizontal_code_value(p) = 0;
            vertical_code_value(p) = 1;
            
            elseif x(p) > x(p-1) && y(p) < y(p-1)
			% Moved to the upper right
			horizontal_code_value(p) = 1;
            vertical_code_value(p) = 1;
            
            elseif x(p) > x(p-1) && y(p) == y(p-1)
			% Moved right
			horizontal_code_value(p) = 1;
            vertical_code_value(p) = 0;
		
            elseif x(p) > x(p-1) && y(p) > y(p-1)
			% Moved right and down.
			horizontal_code_value(p) = 1;
            vertical_code_value(p) = -1;
		
            elseif x(p) == x(p-1) && y(p) > y(p-1)
			% Moved down
			horizontal_code_value(p) = 0;
            vertical_code_value(p) =-1;
            
            elseif x(p) <= x(p-1) && y(p) > y(p-1)
			% Moved down and left
			horizontal_code_value(p) = -1;
            vertical_code_value(p) = -1;
            
            elseif x(p) <= x(p-1) && y(p) == y(p-1)
			% Moved left
			horizontal_code_value(p) = -1;
            vertical_code_value(p) = 0;
            end
       
        end
        
        % Save the codeword_values that we built up for this edge into the
        % cell arrays.
        all_coordinates{n}= cell2mat(coordinate);
        all_horizontal_codes{n} = horizontal_code_value;    
        all_vertical_codes{n} = vertical_code_value;
        
        %% Apply dilataion and gaussian low-pass filter to reduce noise
        horizontal_smoothed_code{n}= imdilate(all_horizontal_codes{n},strel('disk',5));
        horizontal_smoothed_code{n} = round(imfilter(horizontal_smoothed_code{n},fspecial('gaussian')));
        vertical_smoothed_code{n}= imdilate(all_vertical_codes{n},strel('disk',5));
        vertical_smoothed_code{n} = round(imfilter(vertical_smoothed_code{n},fspecial('gaussian')));
        
        %% Differential operation to calculate infection points (points showing curvature)
        horizontal_differentiated{n}= diff( horizontal_smoothed_code{n});
        vertical_differentiated{n}= diff( vertical_smoothed_code{n});
        
        end
       
        %% Find infection points ( non-zero vlaues)
        horizontal_inflection = [cell2mat(horizontal_differentiated);cell2mat(all_coordinates)];
        vertical_inflection = [cell2mat(vertical_differentiated);cell2mat(all_coordinates)];
        
        
        %% Horizontal Infection Points
        x_indices = find(horizontal_inflection(1,:)== 0);
        horizontal_inflection(:,x_indices) = [];
        
        
        % get coordinate pairs of horizontal inflection points
        horizontal_x= horizontal_inflection(2,:);
        horizontal_y=horizontal_inflection(3,:);
        horizontal_inflection_pairs= [horizontal_x' horizontal_y'];
        
       %% Vertical Infection Points
        y_indices = find(vertical_inflection(1,:)==0);
        vertical_inflection(:,y_indices) = [];
        
        % get coordinate pairs of vertical inflection points
        vertical_x= vertical_inflection(2,:);
        vertical_y=vertical_inflection(3,:);
        vertical_infelection_pairs= [vertical_x' vertical_y'];
%% Show inflection points (points showing curvature)on the image
        hold on;
        plot(horizontal_inflection_pairs(:,1), horizontal_inflection_pairs(:,2), 'b*'); 
        plot(vertical_infelection_pairs(:,1),vertical_infelection_pairs(:,2), 'g*');