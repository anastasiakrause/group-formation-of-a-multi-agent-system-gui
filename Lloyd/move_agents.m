function [agentPositions,distance_travelled,E, charged_counter] = move_agents(agentPositions,...
        centroids,distance_travelled,Velocity_Type,velocity,max_velocity,...
        MOVEMENTSCALE,algorithm_type,E,Mass,charged_counter)
    % Moves each agent towards its assigned centroid.
    %
    % Centroids is a nx2 matrix, where (i,1) and (i,2) represent the ith
    % agent's centroid's x and y value, respectively.
    % agentPositions is nx2 matrix, where (i,1) and (i,2) is the ith's
    % agent's x and y position, respectively.
    %
    % MOVEMENTSCALE must be greater than 0 and should be less than 2. It is
    % the fraction of the distance that an agent will travel in the x and y
    % direction. For example, if it is 1 then the agent will move to its
    % desired point in one iteration. If it is 0.5 the agent will be halfway
    % there.
    %
    % Velocity is the constant velocity at which the user wishes the agent to
    % travel.
    %
    % Using a MOVEMENTSCALE of around 1.8 will usually cause the algorithm to
    % converge the fastest, but for the purposes of this project having a
    % MOVEMENTSCALE greater than 1 may be unrealistic.
    
    % E: energy content of agents in percentage
    %
    %% Used for Energy example
    % The energy will be decreased using the energy after one iteration being
    % E_(i+1) = E_i - (1/2)*m*v^2
    %%
    %     m = 1.0; % Physical mass of agents
    %     time_unit = 30; %30 seconds per iteration
    %     space_unit = 0.1; % 10 cm per space unit
    
    max_energy_of_agents = 100; % Total energy in Joules of a 9V battery
    n = size(agentPositions,1); % Find number of agents
    
    total_distance = distance_travelled(end); % Track the sum of the total distance travelled by each of the robots
    
    for i = 1 : n
        direction = [centroids(i,1) - agentPositions(i,1), centroids(i,2) - agentPositions(i,2)];
        
        [delta_x, delta_y] = velocity_fun(Velocity_Type,direction,velocity,...
            max_velocity,MOVEMENTSCALE,algorithm_type,Mass(i));
        
        total_distance = total_distance + sqrt(delta_x^2 + delta_y^2);
        
        %% May need to add a way for agents to not exceed the arena's boundaries
        % Pass in Length of Arena and Partitions
        if charged_counter(i) < 3
            charged_counter(i) = charged_counter(i) + 1;
            delta_x = 0;
            delta_y = 0;
        end
        if (delta_x < 0.1) && (delta_y < 0.1) && (charged_counter(i) == 3)
            if agentPositions(i,1) <= 25
                delta_x = (-2)*rand(1,1);
                fprintf('delta_x = %d\n',delta_x);
            else
                delta_x = 2*rand(1,1);
                fprintf('delta_x = %d\n',delta_x);
            end
            if agentPositions(i,2) <= 25
                delta_y = (-2)*rand(1,1);
                fprintf('delta_y = %d\n',delta_y);
            else
                delta_y = 2*rand(1,1);
                fprintf('delta_y = %d\n',delta_y);
            end            
            
            %delta_x = (5).*rand(1,1)-2.5;
            %delta_y = (5).*rand(1,1)-2.5;
            %delta_x = delta_x.*3;
            %delta_y = delta_y.*3;
        end
        
        agentPositions(i,1) = agentPositions(i,1) + delta_x;
        agentPositions(i,2) = agentPositions(i,2) + delta_y;
        % Constant decrease of battery life for agents with addtional loss
        % that's proportional to the sqyure of the velocity of the agents
        if charged_counter(i) == 3
            E(i) = E(i) - 1;
            %             if delta_x ~= 0 && delta_y ~= 0
            E(i) = E(i) - (delta_x^2+delta_y^2); % Decreasing energy of agents after they move
            %             end
        end
        
        if E(i) < 0
            E(i) = 0;
        end
        
        fprintf("Energy(%d): %5.2f %%\n", i, E(i));
        
        if E(i) <= 10
            
            charged_counter(i) = 0;
            E(i) = max_energy_of_agents;
            
            agentPositions(i,1) = 50*((.51-.49)*rand+.49);
            agentPositions(i,2) = 50*((.51-.49)*rand+.49);
        end
    end
    
    distance_travelled = horzcat(distance_travelled, total_distance);
    
    
end
