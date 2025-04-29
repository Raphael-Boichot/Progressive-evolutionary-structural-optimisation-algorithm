%https://github.com/Raphael-Boichot/Progressive-evolutionary-structural-optimisation-algorithm
clear;
clc;
close all;
rng('shuffle', 'twister')
format long

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%User parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------Conditions for thermal science-----------------------------------
high_conductivity = 10;         %conductivity of the draining material
low_conductivity = 1;           %conductivity of the heating matter
heat_sink_temperature = 298;    %self explanatory
delta_x = 0.001;                %size of x/y square cells
p_vol=1e6;                      %surface of volume power
filling_ratio=0.3;              %ratio of conductive matter on the surface
starting_image='20x20.bmp';     %self explanatory
%----------Hyper parameters for the ESO algorithm--------------------------
silent_mode=0;                  %if 1, limits the output to strict minimum, faster
max_rank=5;                     %maximum allowed rank for exchange
max_cell_swap=1;                %maximum number of simultaneous cell swap
max_redounding_move_allowed=20; %stopping criterion, max_redounding_move_allowed*(1+step)
max_steps=3;                    %number of scales tried into the run, 0 is the first run 3 is 2^3 scaling factor
%--------------------------------------------------------------------------

if max_cell_swap>max_rank
    max_cell_swap=max_rank;
end

if silent_mode==0
    mkdir('Figure');
    mkdir('Topology');
    delete('Figure/*.png');
    delete('Topology/*.png');
end

disp('Starting from a random topology...')
initial_boundary_conditions=imread(starting_image);
[height,width,profondeur]=size(initial_boundary_conditions);
number_of_images = max([height,width]);
boundary_conditions = zeros(height,width);
history_map=zeros(height,width);
history_map(1,1)=1;

%conversion of an image to boundary conditions
non_conductive_cells=0;
conductive_cells=0;
for k = 1:1:height
    for l = 1:1:width
        red = initial_boundary_conditions(k,l,1);
        green = initial_boundary_conditions(k,l,2);
        blue = initial_boundary_conditions(k,l,3);
        if (red == 255) && (green == 255) && (blue == 255)
            pixel = low_conductivity;
            non_conductive_cells=non_conductive_cells+1;
        end
        if (red == 127) && (green == 127) && (blue == 127)
            pixel = -2;
        end
        if (red == 0) && (green == 0) && (blue == 255)
            pixel = -3;
        end
        if (red == 0) && (green == 0) && (blue == 0)
            pixel = high_conductivity;
            conductive_cells=conductive_cells+1;
        end
        boundary_conditions(k, l) = pixel;
    end
end

disp('Filling blank image with conductive pixels...')
number_conductive_cells=ceil(non_conductive_cells*filling_ratio);
%boundary_conditions=init_image(boundary_conditions,number_conductive_cells, low_conductivity, high_conductivity);
%***********************
objective_ini=1e15;
disp('Trying some Monte Carlo search for beginning with a not too bad topology')
max_trial=100;
for i=1:max_trial
    disp(['Initial trial: ',num2str(i),'/',num2str(max_trial)])
    temp_conditions=init_image(boundary_conditions,number_conductive_cells, low_conductivity, high_conductivity);
    for j=1:1:50
        [temp_conditions,~,~] = fun_ESO_algorithm(temp_conditions,high_conductivity,low_conductivity,heat_sink_temperature,delta_x,p_vol, max_rank, max_cell_swap);
    end
    % Variables output in this order :
    % 1. Distance of the hotest cell to the heat sink (scalar)
    % 2. Sum of cell entropy (scalar)
    % 3. Entropy map (matrix)
    % 4. Variance of temperatures accross the 1D adabatic borders (scalar)
    % 5. Variance of temperatures accross the 2D domain (scalar)
    % 6. Mean temperature (scalar)
    % 7. Maximal temperature accross the 2D domain (scalar)
    % 8. Map of temperatures (matrix)
    % 9. map of thermal gradients (matrix)
    % 10. Variance of gradients across the 2D domain (scalar)
    [~,~,~,~,~,~,objective_function,~,~,~]=finite_temp_direct_sparse(high_conductivity,low_conductivity,heat_sink_temperature,delta_x,p_vol,temp_conditions);
    if objective_function<objective_ini
        objective_ini=objective_function;
        best_initial_topology=temp_conditions;
        disp('Best topology found and kept !')
    end
end
boundary_conditions=best_initial_topology;
%***********************

disp('Starting the ESO algorithm...');
%variable pre-allocation
temp=ones(height,width).*heat_sink_temperature;
boundary_output=initial_boundary_conditions;
affichage=zeros(1,4);
m=0;
u=0;
if silent_mode==0
    figure('Position',[100 100 1100 600]);
end
step=0;
while not(step==(max_steps+1))
    Max_temperature=1e12;
    Best_topology=zeros(height,width);
    while max(max(history_map))<max_redounding_move_allowed*(1+step)
        tic
        m=m+1;
        disp(' ');
        disp(['------------Epoch: ',num2str(m),' Step: ',num2str(step),'/',num2str(max_steps),'------------']);
        disp('Applying ESO algorithm...');
        [boundary_conditions,growth,etching] = fun_ESO_algorithm(boundary_conditions,high_conductivity,low_conductivity,heat_sink_temperature,delta_x,p_vol, max_rank, max_cell_swap);
        % Variables output in this order :
        % 1. Distance of the hotest cell to the heat sink (scalar)
        % 2. Sum of cell entropy (scalar)
        % 3. Entropy map (matrix)
        % 4. Variance of temperatures accross the 1D adabatic borders (scalar)
        % 5. Variance of temperatures accross the 2D domain (scalar)
        % 6. Mean temperature (scalar)
        % 7. Maximal temperature accross the 2D domain (scalar)
        % 8. Map of temperatures (matrix)
        % 9. map of thermal gradients (matrix)
        % 10. Variance of gradients across the 2D domain (scalar)
        [~,~,entropy_map, ~,~, ~,t_max,temp,grad,~]=finite_temp_direct_sparse(high_conductivity,low_conductivity,heat_sink_temperature,delta_x,p_vol,boundary_conditions);
        history_objective_function(m)=t_max;
        
        for k = 1:1:height
            for l = 1:1:width
                pixel = boundary_conditions(k, l) ;
                if pixel == low_conductivity
                    red = 255;
                    green = 255;
                    blue = 255;
                end
                if pixel == -2
                    red = 127;
                    green = 127 ;
                    blue = 127 ;
                end
                if pixel == -3
                    red = 0;
                    green = 0 ;
                    blue = 255;
                end
                if pixel == high_conductivity
                    red = 0 ;
                    green = 0 ;
                    blue = 0;
                end
                boundary_output(k,l,1)=red;
                boundary_output(k,l,2)=green;
                boundary_output(k,l,3)=blue;
            end
        end
        
        boundary_output=uint8(boundary_output);
        mirror=fliplr(boundary_output(1:height-1,1:width-1,:));
        mirror2=rot90(mirror);
        arbre=[mirror2,mirror];
        if silent_mode==0
            figure(1)
            subplot(2,4,1:2);
            
            if (m)>2
                if (m)<100; plot(history_objective_function,'.r'); end
                if (m)>=100; plot((history_objective_function(end-98:end)),'.r'); end
            end
            title('Max temperature');
            
            subplot(2,4,3:4);
            imagesc([mirror2,mirror]);
            title('Topology');
            
            subplot(2,4,5);
            min_entropy=min(min(entropy_map));
            imagesc(log10(max(entropy_map(2:end-1,2:end-1),min_entropy)));
            title('Log10 Entropy');
            
            subplot(2,4,6);
            imagesc(temp(2:end-1,2:end-1));
            title('Temperatures map');
            
            subplot(2,4,7);
            imagesc(grad);
            title('Gradients map');
        end
        old_max_history=max(max(history_map));
        for i=1:1:max_cell_swap
            history_map(growth(i,1),growth(i,2))=history_map(growth(i,1),growth(i,2))+1;
            history_map(etching(i,1),etching(i,2))=history_map(etching(i,1),etching(i,2))+1;
        end
        
        %allows to avoid cell swapping again and again at the same positions
        if max(max(history_map))>old_max_history
            max_cell_swap=max_cell_swap-1;
            if max_cell_swap<1
                max_cell_swap=1;
            end
        end
        
        %allows speed up convergence a bit
        %     if rand<0.01
        %         max_cell_swap=max_cell_swap+1;
        %         if max_cell_swap>max_rank
        %             max_cell_swap=max_rank;
        %         end
        %     end
        
        if silent_mode==0
            subplot(2,4,8);
            imagesc(sqrt(history_map));
            title('History map');
            
            disp(['Maximal temperature: ',num2str(history_objective_function(m))]);
            initial_boundary_conditions=boundary_output;
            colormap jet
            drawnow;
        end
        if history_objective_function(m)<Max_temperature
            Max_temperature=history_objective_function(m);
            Best_topology=boundary_conditions;
            disp('*********Best topology detected !**********')
        end
        
        imwrite([arbre;rot90(rot90(arbre))],['Topology_kp_ko_',num2str(high_conductivity),'_phi_',num2str(filling_ratio),'.png']);
        if silent_mode==0
            saveas(gcf,['Figure_kp_ko_',num2str(high_conductivity),'_phi_',num2str(filling_ratio),'.png']);
            saveas(gcf,['Figure/Figure_kp_ko_',num2str(high_conductivity),'_phi_',num2str(filling_ratio),'_',num2str(m,'%06.f'),'.png']);
            imwrite([arbre;rot90(rot90(arbre))],['Topology/Topology_kp_ko_',num2str(high_conductivity),'_phi_',num2str(filling_ratio),'_',num2str(m,'%06.f'),'.png']);
        end
        disp(['Max redunding moves: ',num2str(max(max(history_map))),'/',num2str(max_redounding_move_allowed*(1+step))]);
        disp(['Cells allowed for swapping: ',num2str(max_cell_swap)])
        disp(['Current topology size: ',num2str(height),'*',num2str(width)])
        toc
    end
    disp('Converged at the current scale, doubling the scale');
    boundary_conditions=repelem(Best_topology,2,2);           %changes scale but from the best topology
    boundary_conditions=boundary_conditions(2:end-1,2:end-1); %removes the redunding external pixel border after doubling
    delta_x=delta_x/2;
    height=height*2-2;
    width=width*2-2;
    history_map=zeros(height,width);
    history_map(1,1)=1;
    step=step+1;
end
disp('Converged !');
