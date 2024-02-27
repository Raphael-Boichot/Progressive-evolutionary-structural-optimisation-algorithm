clc
clear
format long
delete('Average.png');
%---------Conditions for thermal science-----------------------------------
high_conductivity = 10;         %conductivity of the draining material
low_conductivity = 1;           %conductivity of the heating matter
heat_sink_temperature = 298;    %self explanatory
delta_x = 0.001;                %size of x/y square cells
p_vol=1e6;                      %surface of volume power

listing = dir('*.png');
for i=1:1:length(listing)
    name=listing(i).name;
    frame=imread(name);
    [height,width,~]=size(frame);
    for k = 1:1:height
        for l = 1:1:width
            red = frame(k,l,1);
            green = frame(k,l,2);
            blue = frame(k,l,3);
            if (red == 255) && (green == 255) && (blue == 255)
                pixel = low_conductivity;
            end
            if (red == 127) && (green == 127) && (blue == 127)
                pixel = -2;
            end
            if (red == 0) && (green == 0) && (blue == 255)
                pixel = -3;
            end
            if (red == 0) && (green == 0) && (blue == 0)
                pixel = high_conductivity;
            end
            boundary_conditions(k, l) = pixel;
        end
    end
    [distance,somme_entropie, entropie, border_variance,variance, moyenne_temp,t_max,temp,grad,variance_grad]=finite_temp_direct_sparse(high_conductivity,low_conductivity,heat_sink_temperature,delta_x,p_vol,boundary_conditions);
    %see https://hal.science/hal-01366564/document for details
    R(i)=(t_max-heat_sink_temperature)/((p_vol*height*delta_x*width*delta_x)/low_conductivity);
    listing(i).R=R(i);
    data(:,:,i)=frame(:,:,1);
end
average=mean(data,3);
minimum=min(min(min(average)));
maximum=max(max(max(average)));
average=(average-minimum)*(255/(maximum-minimum));
average=uint8(average);
imwrite(average,'Average.png')
figure(1)
imshow(average);
S0=std(R)/mean(R);
disp(['The relative standard deviation of the batch is ',num2str(S0*100),'%'])
[~, val]=min(R);
disp(['The best topology is ',listing(val).name])
[~, val]=max(R);
disp(['The worst topology is ',listing(val).name])
disp('Geometry, from best to worst:')
T = struct2table(listing); % convert the struct array to a table
sortedT = sortrows(T, 'R');
sortedT.name
sortedT.R