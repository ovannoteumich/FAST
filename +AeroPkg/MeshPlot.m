function [] = MeshPlot(geom,data)
%MESHPLOT Summary of this function goes here
%   Detailed explanation goes here

  data = lower(char(data));
  
  switch data
    case 'points'
      scatter3(geom.Mesh.Node(:,1),-geom.Mesh.Node(:,3),geom.Mesh.Node(:,2));
      axis equal
      xlabel("x")
      ylabel("-z")
      zlabel("y")

    case 'grid'

    case 'surface'
      clf
      patch('Faces', geom.Mesh.Elem, ...
                 'Vertices', [geom.Mesh.Node(:,1) -geom.Mesh.Node(:,3) geom.Mesh.Node(:,2)], ...
                 'FaceColor', [0.8, 0.9, 1.0], ... % Light blue
                 'EdgeColor', [0.2, 0.2, 0.2], ... % Dark gray mesh lines
                 'LineWidth', 0.5, ...
                 'FaceAlpha', 0.5);

      % Set labels and view
      axis equal
      xlabel("x")
      ylabel("-z")
      zlabel("y")
      view(3)
      
      % Add lighting for better surface definition
      camlight headlight;
      lighting gouraud;
  
    case 'pressure'
      
    otherwise
  
  end

end