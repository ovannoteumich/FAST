function geom = MeshGeneration(geom, BaseSize)
  % Turns baseline geometry into a mesh for use in solvers
  % BaseSize is a base mesh size (m) that all sizes are derived from
  geom.Mesh.Node = []; % (m) [x,y,z] positions of cell corners.
  geom.Mesh.Elem = []; % [1,2,3,4] nodes that compose an element. Tri = [1,2,3,3]
  geom.Mesh.Type = []; % 0:Fuselage, not in this version, 1:Wing (+ 1/10 per surface, up to 9 allowed), 2:VTail, 3+:Props

  geom.Mesh.FuselageLength = geom.Fuselage.Diameter/2*(geom.Fuselage.Tail.XPos(end)-geom.Fuselage.Nose.XPos(end)) + geom.Fuselage.CylBaseLength + ceil(geom.Pax/geom.Fuselage.PaxRow)*geom.Fuselage.RowSpacing;

  %% BUILD HORIZONTAL SURFACES
  for idx_surf = 1:length(geom.Surfaces)
    surf = geom.Surfaces{idx_surf};
    SurfStartIdx(idx_surf) = size(geom.Mesh.Node, 1) + 1;
    
    % Input structure normalization and smoothing defaults
    if ~isfield(surf, "Chord"); error(['Chord length required for surface:' num2str(idx_surf)]); end
    if ~isfield(surf, "Twist"); error(['Twist required for surface:' num2str(idx_surf)]); end
    if ~isfield(surf, "Thicc"); surf.Thicc = ones(1,surf.NumCtrlPts); end
    if ~isfield(surf, "Hedral"); surf.Hedral = zeros(1,surf.NumCtrlPts); end
    if ~isfield(surf, "Sweep"); surf.Sweep = 0; end
    if isscalar(surf.Chord); surf.Chord = ones(1,surf.NumCtrlPts)*surf.Chord; end
    if isscalar(surf.Twist); surf.Twist = ones(1,surf.NumCtrlPts)*surf.Twist; end
    if isscalar(surf.Thicc); surf.Thicc = ones(1,surf.NumCtrlPts)*surf.Thicc; end
    if isscalar(surf.Hedral); surf.Hedral = ones(1,surf.NumCtrlPts)*surf.Hedral; end
    if ~isfield(surf, "Spacing"); surf.Spacing = 1; end
    if ~isfield(surf, "RootBase"); surf.RootBase = 0.25; end
    if ~isfield(surf, "TwistBase"); surf.TwistBase = surf.RootBase; end
    if ~isfield(surf, "SweepBase"); surf.SweepBase = 0; end
    if ~isfield(surf, "ChordSmoothing"); surf.ChordSmoothing = 'linear'; end
    if ~isfield(surf, "TwistSmoothing"); surf.TwistSmoothing = 'linear'; end
    if ~isfield(surf, "ThiccSmoothing"); surf.ThiccSmoothing = 'linear'; end
    if ~isfield(surf, "HedralSmoothing"); surf.HedralSmoothing = 'next'; end

    S = [0;cumsum(sqrt(diff(surf.Airfoil.x').^2 + diff(surf.Airfoil.y').^2))];
    Npts = real(ceil(max((pi*S(end)/2)/(BaseSize/surf.Chord(1)),2)));
    cNpts(idx_surf) = Npts;
    sc = (S(end)/2)*(1-cos(linspace(0,pi,Npts)'));
    xc_b = interp1(S, surf.Airfoil.x', sc, 'pchip');
    yc_b = interp1(S, surf.Airfoil.y', sc, 'pchip');

    s_ctrl = linspace(0, 1, surf.NumCtrlPts);
    
    % SPACING LOGIC
    if surf.Spacing == 1
      s_ctrl = (1 - cos(pi*s_ctrl))/2;
    elseif surf.Spacing == -1
      s_ctrl = asin(2*s_ctrl - 1)/pi + 0.5;
    elseif surf.Spacing > 1
      s_ctrl = 1 - (1 - s_ctrl).^surf.Spacing;
    elseif surf.Spacing < -1
      s_ctrl = s_ctrl.^(-surf.Spacing);
    else
      s_ctrl = s_ctrl;
    end
    s_ctrl = unique(s_ctrl);
    
    NumSpanPts = real(ceil(max(2,1+max(diff(s_ctrl)).*surf.Span/BaseSize)*(surf.NumCtrlPts-1)));
    s_loc = linspace(0,1,NumSpanPts);
    
    % SPACING LOGIC (AGAIN)
    if surf.Spacing == 1
      s_loc = (1 - cos(pi*s_loc))/2;
    elseif surf.Spacing == -1
      s_loc = asin(2*s_loc - 1)/pi + 0.5;
    elseif surf.Spacing > 1
      s_loc = 1 - (1 - s_loc).^surf.Spacing;
    elseif surf.Spacing < -1
      s_loc = s_loc.^(-surf.Spacing);
    else
      s_loc = s_loc;
    end
    s_loc = unique(s_loc);

    chord_s = interp1(s_ctrl,surf.Chord,s_loc,surf.ChordSmoothing);
    twist_s = interp1(s_ctrl,-surf.Twist,s_loc,surf.TwistSmoothing);
    thicc_s = interp1(s_ctrl,surf.Thicc,s_loc,surf.ThiccSmoothing);
    hedral_s = interp1(s_ctrl,surf.Hedral,s_loc,surf.HedralSmoothing);
    hedral_y = cumsum(tand(hedral_s).*[0 diff(s_loc)])*surf.Span;
    hedral_s = [0, (hedral_s(1:end-1)+hedral_s(2:end))/2];

    for i = 1:NumSpanPts
      geom.Mesh.Node = [geom.Mesh.Node; ((xc_b-surf.TwistBase)*cosd(twist_s(i)) + yc_b*thicc_s(i)*sind(twist_s(i)) + surf.TwistBase - surf.SweepBase)*chord_s(i) + (s_loc(i)*tand(surf.Sweep) + surf.SweepBase - surf.RootBase)*chord_s(1) + surf.RootX, (((xc_b-surf.TwistBase)*sind(twist_s(i)) + yc_b*thicc_s(i)*cosd(twist_s(i)))*cosd(hedral_s(i)))*chord_s(i) + hedral_y(i) + surf.RootY, ones(size(xc_b))*s_loc(i)*surf.Span + (((xc_b-surf.TwistBase)*sind(twist_s(i)) + yc_b*thicc_s(i)*cosd(twist_s(i)))*sind(-hedral_s(i)))*chord_s(i)];
    end
    
    for i = 1:NumSpanPts-1
      c_s = SurfStartIdx(idx_surf)-1+(i-1)*Npts;
      n_s = SurfStartIdx(idx_surf)-1+i*Npts;
      for j = 1:Npts-1
        geom.Mesh.Elem = [geom.Mesh.Elem; n_s+j, n_s+j+1, c_s+j+1, c_s+j];
        geom.Mesh.Type = [geom.Mesh.Type; 1+(idx_surf-1)/10];
      end
    end
  end

  %% BUILD VERTICAL TAIL
  VTailStartIdx = size(geom.Mesh.Node, 1) + 1;
  Npts_v = ceil((pi/2) / (BaseSize/geom.VTail.Chord(1)));
  sc_v = (1/2)*(1-cos(linspace(0,pi,Npts_v)'));
  xc_v_base = interp1([0 1], [0 1], sc_v, 'pchip');
  NVTail = ceil(geom.VTail.Height/BaseSize) + 1;
  s_v_span = linspace(0, 1, NVTail);
  dspan = max(diff(s_v_span))*geom.VTail.Height;
  
  for i = 1:NVTail
    chord_v = interp1([0,1], geom.VTail.Chord, s_v_span(i), 'linear');
    % Pivot logic: Rotation/Sweep around SweepBase
    z_off = s_v_span(i)*geom.VTail.Height;
    x_swp = tan(deg2rad(geom.VTail.Sweep))*z_off;
    pivot_x = geom.VTail.RootX + x_swp + geom.VTail.SweepBase*geom.VTail.Chord(1);
    
    xc_v = (xc_v_base - geom.VTail.SweepBase)*chord_v + pivot_x;
    yc_v = ones(size(xc_v)) * (z_off + geom.Fuselage.Diameter/2);
    
    geom.Mesh.Node = [geom.Mesh.Node; xc_v(:), yc_v(:), zeros(size(xc_v(:)))];
  end
  for i = 1:NVTail-1
    c_s = VTailStartIdx-1+(i-1)*length(xc_v_base);
    n_s = VTailStartIdx-1+i*length(xc_v_base);
    for j = 1:length(xc_v_base)-1
      geom.Mesh.Elem = [geom.Mesh.Elem; c_s+j, c_s+j+1, n_s+j+1, n_s+j];
      geom.Mesh.Type = [geom.Mesh.Type; 2];
    end
  end

  %% BUILD PROPELLERS
  if isscalar(geom.Props.Diameter)
    geom.Props.Diameter = ones(1,geom.Props.Number)*geom.Props.Diameter;
  end

  rRat = 0.05;
  nRadPanels = 2;
  nThetaPanels = 8;

  rad = rRat + (1-rRat)*sin(linspace(0,pi/2,nRadPanels));

  thetas = linspace(0,2*pi,nThetaPanels+1);

  nodes = [];
  for i = 1:(nThetaPanels+1)
    nodes = [nodes; zeros(size(rad')), rad'*cos(thetas(i)), rad'*sin(thetas(i))];
  end

  elems = [];
  for i = 1:nThetaPanels
    elems = [elems; (1:(nRadPanels-1))'+(i-1)*nRadPanels, (2:nRadPanels)'+(i-1)*nRadPanels, (2:nRadPanels)'+i*nRadPanels, (1:(nRadPanels-1))'+i*nRadPanels];
  end

  for i = 1:geom.Props.Number
    geom.Mesh.Elem = [geom.Mesh.Elem; elems+length(geom.Mesh.Node)];
    geom.Mesh.Type = [geom.Mesh.Type; ones(length(elems),1)*3];
    geom.Mesh.Node = [geom.Mesh.Node; (nodes*geom.Props.Diameter(i)/2)+[geom.Props.X(i),geom.Props.Y(i),geom.Props.Z(i)]];
  end

end