function [final_x, final_y,final_z, rv, D,EI] = isomap(x, y, springs, neutral_lengths, w, plot3d)
% Runs underlying MDS to finish Isomap
% x, y, springs, and neutral_lengths are from springs computation
% plot3d tells whether or not to plot 3d manifold
% w is weighting factor
	
    % Use spring lengths to set up sparse distance matrix
    n = numel(x);
    [D, G] = graph_matrix(springs, neutral_lengths, n);
    
%     Call Isomap 
    options.dims = 1:10;
    options.display = 0;
    options.verbose = 1;
    options.G = G;
    options.Kmax=8;
     [Y, R, E] = isomap_fast(D, 'epsilon', 8, options);
    len=length(x(:,1));
    
    %opts=statset('Display','iter');
    z=zeros(len*len,1);
    for i=1:len/2
        z(len*(i-1)+1:len*i,1)=(i-1)*0.005/20;
        z((len-i)*len+1:(len-i+1)*len,1)=(i-1)*0.005/20;
    end
    
    [Y,stress,disparities]=mdscale(D,3,'Start',[x(:),y(:),z],'Criterion','strain');%,'Options',opts);
Y=Y';
%     figure(14)
% sf=fit([Y(:,1),Y(:,2)],Y(:,3),'poly23');
% plot(sf,[Y(:,1),Y(:,2)],Y(:,3))
    
    % Call MDS
    weights = G~=0;
    weights = w*(1+weights)-(w-1);
%     [Y, R] = mdimscale(D, 1:3, 'stress', ones(size(weights)));

    % 3D Mesh plot
    if plot3d == 1
        a = Y(1,:);
        b = Y(2,:);
        c = Y(3,:);
        dx = .05;
        dy = .05;
%         x_edge = [floor(min(a)):dx:ceil(max(a))];
%         y_edge = [floor(min(b)):dy:ceil(max(b))];

        y_edge = linspace(min(a),max(a),23);%[(min(a)+0.01):dx:(max(a)-0.01)];
        x_edge = linspace(min(b),max(b),23);%[(min(b)+0.01):dy:(max(b)-0.01)];
        [A,B] = ndgrid(x_edge,y_edge);
        C = griddata(a,b,c,A,B,'cubic');
        
        A = reshape(a,[],size(x,2));
        B = reshape(b,[],size(x,2));
        C = reshape(c,[],size(x,2));

%         figure;
% %         mesh(A,B,C);
%         surf(A,B,C);
%         axis equal;
    end
    
    new_coords = Y;
    final_x = reshape(new_coords(1,:), size(x));
    final_y = reshape(new_coords(2,:), size(y));
    final_z = reshape(new_coords(3,:), size(y));
    rv = R(2);
    
%     final_x = symmetry_vector(final_x);
%     final_y = symmetry_vector(final_y);
%     final_z = symmetry_vector(final_z);
    
    % export extra info
    EI.A = A;
    EI.B = B;
    EI.C = C;
    
end