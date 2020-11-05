function output = sysf_serpenoid_lowRe_9ratio(input_mode,pathnames)
% System file for a low Reynolds

    % Default arguments
	if ~exist('input_mode','var')
		
		input_mode = 'initialize';
		
	end
		
	%%%%%%%
	
	switch input_mode

		case 'name'

			output = 'Viscous swimmer: Serpenoid 9:1 ratio'; % Display name

		case 'dependency'

			output.dependency = fullfile(pathnames.sysplotterpath,...
                {'Geometry/ContinuousBackbone/',...
                'Physics/LowReynoldsRFT/'});

		case 'initialize'

            %%%%%%%%%
            % System definition

            %%%
            % Define the geometry of the system

            % this system's shape is defined by a set of basis functions
            % whose weighted sum is curvature as a function of distance
            % along the backbone
            s.geometry.type = 'curvature basis';                

            % The specific basis functions are those for a serpenoid curve,
            % in which the curvature varies sinusoidally along the length
            % of the body. This function is normalized such that the body length
            % is taken as one unit long. For this system, we use a
            % wavelength equal to the body length.
            n_waves = 1;
            s.geometry.function = {@(s)serpenoid_1(s,n_waves);@(s)serpenoid_2(s,n_waves)};

            % Total length of the swimmer, in real units
            s.geometry.length = 1;
            
            % base the system off of its center frame
            s.geometry.baseframe = 'center';

            %%%
            
            %%%
            % Define properties for visualizing the system
            
            % Make a grid of values at which to visualize the system in
            % illustrate_shapespace. The code below uses properties of cell
            % arrays to automatically match the dimensionality of the grid
            % with the number of shape basis functions in use
            s.visual.grid = cell(size(s.geometry.function));
            [s.visual.grid{:}] = ndgrid([-1 -0.5 0 0.5 1]*6);

            
            %%%

            %%%
            % Define the physics of the system

            % This system is treated as moving in a viscous fluid. Key elements we
            % need for this model are a drag coefficient and a drag ratio
            s.physics.drag_coefficient = 1;                   % multiplier from longitudinal velocity to drag force. Changing this scales the dissipation matrix
            s.physics.drag_ratio = 9;                         % ratio of lateral:longitudinal drag

            % Locomotion model derived from viscous drag forces reacting to
            % local velocities of elements on the body
            s.A = @(a1,a2) LowRE_local_connection(s.geometry,s.physics,[a1;a2]);
            
            % Locomotion model derived from viscous drag forces reacting to
            % local velocities of elements on the body
            s.metric = @(a1,a2) LowRE_dissipation_metric(s.geometry,s.physics,[a1;a2]);
            %%%


            %%%
            % Processing details

            %Range over which to evaluate connection
            s.grid_range = [-1,1,-1,1]*12;

            %densities for various operations
            s.density.vector = [11 11]; %density to display vector field
            s.density.scalar = [21 21]; %density to display scalar functions
            s.density.eval = [21 21];   %density for function evaluations
            s.density.metric_eval = [1 1]*11;
            s.density.finite_element=31;

            %shape space tic locations
            s.tic_locs.x = [-1 0 1]*6;
            s.tic_locs.y = [-1 0 1]*6;
            %%%%
    
    
			%Save the system properties
			output = s;


	end
end