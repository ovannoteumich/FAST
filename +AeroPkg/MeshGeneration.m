function geom = MeshGeneration(geom, BaseSize)
  % Turns baseline geometry into a mesh for use in solvers
  %   BaseSize is a base mesh size (m) that all sizes are derived from
  geom.Mesh.Node = []; % (m) [x,y,z] positions of cell corners.
  geom.Mesh.Elem = []; % [1,2,3,4] nodes that compose an element. Tri = [1,2,3,3]
  geom.Mesh.Type = []; % 0:Fuselage, 1:Wing, 2:HTail, 3:VTail, 4+:Props, Negative:Wakes
  
  %% --- FUSELAGE SPLINE HELPER FUNCTION ---
  NoseLen = -geom.Fuselage.Nose.XPos(end)*geom.Fuselage.Diameter/2;
  TubeLen = geom.Fuselage.CylBaseLength + (geom.Fuselage.RowSpacing*ceil(geom.Pax/geom.Fuselage.PaxRow));
  TailLen = geom.Fuselage.Tail.XPos(end)*geom.Fuselage.Diameter/2;

  function [rc, yc] = GetFuselageState(xq)
    rc = zeros(size(xq)); yc = zeros(size(xq));
    idx_nose = xq <= NoseLen;
    if any(idx_nose)
      x_ns = [0 geom.Fuselage.Nose.XPos*geom.Fuselage.Diameter/2] + NoseLen;
      yc(idx_nose) = interp1(x_ns, [0 geom.Fuselage.Nose.YPos]*geom.Fuselage.Diameter/2, xq(idx_nose), geom.Fuselage.Nose.Spline, 'extrap');
      rc(idx_nose) = interp1(x_ns, [1 geom.Fuselage.Nose.Radii]*geom.Fuselage.Diameter/2, xq(idx_nose), geom.Fuselage.Nose.Spline, 'extrap');
    end
    idx_tube = xq > NoseLen & xq <= (TubeLen + NoseLen);
    if any(idx_tube)
      yc(idx_tube) = 0; rc(idx_tube) = geom.Fuselage.Diameter/2;
    end
    idx_tail = xq > (TubeLen + NoseLen);
    if any(idx_tail)
      x_ts = [0 geom.Fuselage.Tail.XPos*geom.Fuselage.Diameter/2] + TubeLen + NoseLen;
      yc(idx_tail) = interp1(x_ts, [0 geom.Fuselage.Tail.YPos]*geom.Fuselage.Diameter/2, xq(idx_tail), geom.Fuselage.Tail.YSpline, 'extrap');
      rc(idx_tail) = interp1(x_ts, [1 geom.Fuselage.Tail.Radii]*geom.Fuselage.Diameter/2, xq(idx_tail), geom.Fuselage.Tail.RSpline, 'extrap');
    end
    rc = max(rc, 0);
  end

  %% --- BUILD FUSELAGE ---
  CylSegs = ceil((pi*geom.Fuselage.Diameter/2)/BaseSize);
  CylThetas = linspace(0,pi,CylSegs);
  geom.Mesh.Node = [0, geom.Fuselage.Nose.YPos(end)*geom.Fuselage.Diameter/2, 0];
  TipIdx = 1;

  % Nose/Tube/Tail Hoops
  NoseSegs = ceil((1 + sqrt(-BaseSize/NoseLen + 1))/(BaseSize/NoseLen));
  x_nose = (linspace(0,1,NoseSegs)'.^2)*NoseLen; x_nose = x_nose(2:end);
  [rc_nose, yc_nose] = GetFuselageState(x_nose);
  for i = 1:NoseSegs-1
    geom.Mesh.Node = [geom.Mesh.Node; x_nose(i)*ones(size(CylThetas))', yc_nose(i)+rc_nose(i)*cos(CylThetas'), rc_nose(i)*sin(CylThetas')];
  end
  TubeSegs = ceil(TubeLen/BaseSize);
  x_tube = linspace(NoseLen, TubeLen+NoseLen, TubeSegs);
  [rc_tube, yc_tube] = GetFuselageState(x_tube(2:end-1));
  for i = 1:TubeSegs-2
    geom.Mesh.Node = [geom.Mesh.Node; x_tube(i+1)*ones(size(CylThetas))', yc_tube(i)+rc_tube(i)*cos(CylThetas'), rc_tube(i)*sin(CylThetas')];
  end
  TailSegs = ceil((1 + sqrt(-BaseSize/TailLen + 1))/(BaseSize/TailLen));
  x_tail = ((1-linspace(1,0,TailSegs)'.^2))*TailLen + TubeLen + NoseLen;
  [rc_tail, yc_tail] = GetFuselageState(x_tail(1:end-1));
  for i = 1:TailSegs-1
    geom.Mesh.Node = [geom.Mesh.Node; x_tail(i)*ones(size(CylThetas))', yc_tail(i)+rc_tail(i)*cos(CylThetas'), rc_tail(i)*sin(CylThetas')];
  end

  % Elements
  NumHoops = (NoseSegs-1) + (TubeSegs-2) + (TailSegs-1);
  PtsPerHoop = length(CylThetas);
  for j = 1:PtsPerHoop-1
    geom.Mesh.Elem = [geom.Mesh.Elem; TipIdx, TipIdx+j, TipIdx+j+1, TipIdx+j+1];
    geom.Mesh.Type = [geom.Mesh.Type; 0];
  end
  for i = 1:NumHoops-1
    c_h = 1 + (i-1)*PtsPerHoop; n_h = 1 + i*PtsPerHoop;
    for j = 1:PtsPerHoop-1
      geom.Mesh.Elem = [geom.Mesh.Elem; c_h+j, n_h+j, n_h+j+1, c_h+j+1];
      geom.Mesh.Type = [geom.Mesh.Type; 0];
    end
  end

  %% --- BUILD VERTICAL TAIL ---
  VTailStartIdx = size(geom.Mesh.Node, 1) + 1;
  coords_v = AeroPkg.AirfoilGeometries.NACA(geom.VTail.Thicc);
  S_v = [0;cumsum(sqrt(diff(coords_v.x').^2 + diff(coords_v.y').^2))];
  Npts_v = ceil((pi * S_v(end)/2) / (BaseSize/geom.VTail.Chord(1)));
  [~,SLE_v] = min(coords_v.x'); SLE_v = S_v(SLE_v);
  sc_v = unique([(SLE_v/2)*(1-cos(linspace(0,pi,Npts_v)')); SLE_v+((S_v(end)-SLE_v)/2)*(1-cos(linspace(0,pi,Npts_v)'))]);
  xc_v_base = interp1(S_v, coords_v.x', sc_v, 'pchip');
  zc_v_base = interp1(S_v, coords_v.y', sc_v, 'pchip');
  NVTail = ceil(2*geom.VTail.Height/BaseSize) + 1;
  s_v_span = linspace(0, 1, NVTail);
  VTail_TE_Nodes = [];
  
  for i = 1:NVTail
    chord_v = interp1([0,1], geom.VTail.Chord, s_v_span(i), 'linear');
    % Pivot logic: Rotation/Sweep around SweepBase
    z_off = s_v_span(i) * geom.VTail.Height;
    x_swp = tan(deg2rad(geom.VTail.Sweep)) * z_off;
    pivot_x = geom.VTail.RootX + x_swp + geom.VTail.SweepBase*geom.VTail.Chord(1);
    
    xc_v = (xc_v_base - geom.VTail.SweepBase)*chord_v + pivot_x;
    yc_v = ones(size(xc_v)) * (z_off + geom.Fuselage.Diameter/2);
    zc_v = zc_v_base * chord_v;
    
    if i == 1 % Root Stitch
      [rc_f, yc_f] = GetFuselageState(xc_v);
      zc_v = max(zc_v, sqrt(max(0, rc_f.^2 - (yc_v - yc_f).^2)));
    end
    geom.Mesh.Node = [geom.Mesh.Node; xc_v(:), yc_v(:), zc_v(:)];
    VTail_TE_Nodes = [VTail_TE_Nodes; size(geom.Mesh.Node, 1) - length(xc_v) + 1, size(geom.Mesh.Node, 1)];
  end
  for i = 1:NVTail-1
    c_s = VTailStartIdx-1+(i-1)*length(xc_v_base); n_s = VTailStartIdx-1+i*length(xc_v_base);
    for j = 1:length(xc_v_base)-1
      geom.Mesh.Elem = [geom.Mesh.Elem; c_s+j, n_s+j, n_s+j+1, c_s+j+1];
      geom.Mesh.Type = [geom.Mesh.Type; 3];
    end
  end

  %% --- BUILD HORIZONTAL SURFACES ---
  TE_Wakes = cell(length(geom.Surfaces), 1);
  for idx_surf = 1:length(geom.Surfaces)
    surf = geom.Surfaces{idx_surf};
    SurfStartIdx = size(geom.Mesh.Node, 1) + 1;
    
    % Input structure normalization and smoothing defaults
    if ~isfield(surf, "Chord"); error(['Chord length required for surface:' num2str(idx_surf)]); end
    if ~isfield(surf, "Twist"); error(['Twist required for surface:' num2str(idx_surf)]); end
    if ~isfield(surf, "Thicc"); surf.Thicc = ones(1,surf.NumCtrlPts); end
    if ~isfield(surf, "Hedral"); surf.Hedral = zeros(1,surf.NumCtrlPts); end
    if isscalar(surf.Chord); surf.Chord = ones(1,surf.NumCtrlPts)*surf.Chord; end
    if isscalar(surf.Twist); surf.Twist = ones(1,surf.NumCtrlPts)*surf.Twist; end
    if isscalar(surf.Thicc); surf.Thicc = ones(1,surf.NumCtrlPts)*surf.Thicc; end
    if isscalar(surf.Hedral); surf.Hedral = ones(1,surf.NumCtrlPts)*surf.Hedral; end
    if ~isfield(surf, "Spacing"); surf.Spacing = 1; end
    if ~isfield(surf, "RootBase"); surf.RootBase = 0.25; end
    if ~isfield(surf, "TwistBase"); surf.TwistBase = surf.RootBase; end
    if ~isfield(surf, "ChordSmoothing"); surf.ChordSmoothing = 'linear'; end
    if ~isfield(surf, "TwistSmoothing"); surf.TwistSmoothing = 'linear'; end
    if ~isfield(surf, "ThiccSmoothing"); surf.ThiccSmoothing = 'linear'; end
    if ~isfield(surf, "HedralSmoothing"); surf.HedralSmoothing = 'linear'; end

    S = [0;cumsum(sqrt(diff(surf.Airfoil.x').^2 + diff(surf.Airfoil.y').^2))];
    Npts = ceil((pi*S(end)/2)/(BaseSize/surf.Chord(1)));
    [~,SLE] = min(surf.Airfoil.x'); SLE = S(SLE);
    sc = unique([(SLE/2)*(1-cos(linspace(0,pi,Npts)')); SLE+((S(end)-SLE)/2)*(1-cos(linspace(0,pi,Npts)'))]);
    xc_b = interp1(S, surf.Airfoil.x', sc, 'pchip'); yc_b = interp1(S, surf.Airfoil.y', sc, 'pchip');

    s_ctrl = linspace(0, 1, surf.NumCtrlPts);
    num_span_steps = ceil(surf.Span/2/BaseSize);
    s_lin = linspace(0, 1, num_span_steps + 1);
    
    % SPACING LOGIC
    if surf.Spacing == 1
      s_span = (1 - cos(pi*s_lin))/2;
    elseif surf.Spacing == -1
      s_span = asin(2*s_lin - 1)/pi + 0.5;
    elseif surf.Spacing > 1
      s_span = 1 - (1 - s_lin).^surf.Spacing;
    elseif surf.Spacing < -1
      s_span = s_lin.^(-surf.Spacing);
    else
      s_span = s_lin;
    end
    s_span = unique(s_span);

    s_fine = linspace(0, 1, 500);
    h_fine = interp1(s_ctrl, surf.Hedral, s_fine, surf.HedralSmoothing);
    y_int = cumtrapz(s_fine * surf.Span/2, tan(deg2rad(h_fine)));
    
    Surf_TE_Nodes = []; PointsPerAirfoil = length(xc_b);
    for i = 1:length(s_span)
      s = s_span(i);
      chord_s = interp1(s_ctrl, surf.Chord, s, surf.ChordSmoothing);
      twist_s = interp1(s_ctrl, -surf.Twist, s, surf.TwistSmoothing);
      z_val = s * surf.Span/2;
      x_swp = surf.RootX + tan(deg2rad(surf.Sweep)) * z_val;
      y_hed = interp1(s_fine, y_int, s) + surf.RootY;
      
      % THE PIVOT LOGIC: Apply Sweep/Scaling relative to RootBase
      xc_s = (xc_b - surf.RootBase) * chord_s + x_swp;
      yc_s = yc_b * chord_s + y_hed;
      zc_s = ones(size(xc_b)) * z_val;
      
      % Twist around TwistBase
      t_rad = deg2rad(twist_s);
      px = x_swp + (surf.TwistBase - surf.RootBase)*chord_s; 
      dx = xc_s - px; dy = yc_s - y_hed;
      xc_s = px + dx*cos(t_rad) - dy*sin(t_rad);
      yc_s = y_hed + dx*sin(t_rad) + dy*cos(t_rad);
      
      if s == 0 % CONTIGUOUS GEOMETRY: Snap to Fuselage skin
        [rf, yf] = GetFuselageState(xc_s);
        zc_s = sqrt(max(0, rf.^2 - (yc_s - yf).^2));
      end
      
      geom.Mesh.Node = [geom.Mesh.Node; xc_s(:), yc_s(:), zc_s(:)];
      Surf_TE_Nodes = [Surf_TE_Nodes; size(geom.Mesh.Node,1)-PointsPerAirfoil+1, size(geom.Mesh.Node,1)];
    end
    
    for i = 1:length(s_span)-1
      r1 = SurfStartIdx + (i-1)*PointsPerAirfoil; r2 = SurfStartIdx + i*PointsPerAirfoil;
      for j = 1:PointsPerAirfoil-1
        geom.Mesh.Elem = [geom.Mesh.Elem; r1+j-1, r2+j-1, r2+j, r1+j];
        geom.Mesh.Type = [geom.Mesh.Type; idx_surf];
      end
    end
    
    % WINGTIP CAPPING: Close the volume for correct vortex modeling
    TipStart = SurfStartIdx + (length(s_span)-1)*PointsPerAirfoil;
    TipCenter = size(geom.Mesh.Node,1) + 1;
    geom.Mesh.Node = [geom.Mesh.Node; mean(geom.Mesh.Node(TipStart:end,:),1)];
    for j = 1:PointsPerAirfoil-1
      geom.Mesh.Elem = [geom.Mesh.Elem; TipStart+j-1, TipStart+j, TipCenter, TipCenter];
      geom.Mesh.Type = [geom.Mesh.Type; idx_surf];
    end
    TE_Wakes{idx_surf} = Surf_TE_Nodes;
  end

  %% --- FUSELAGE WAKE (Type -100) ---
  FuseWakeStart = size(geom.Mesh.Node, 1) + 1;
  HoopIdx = 1 + (NumHoops-1)*PtsPerHoop;
  for j = 1:PtsPerHoop
    node = geom.Mesh.Node(HoopIdx+j-1, :);
    for w = 1:20
      geom.Mesh.Node = [geom.Mesh.Node; node(1)+w*BaseSize*5, node(2), node(3)];
    end
  end
  for j = 1:PtsPerHoop-1
    r1 = FuseWakeStart + (j-1)*20; r2 = FuseWakeStart + j*20;
    for w = 1:19
      geom.Mesh.Elem = [geom.Mesh.Elem; r1+w-1, r2+w-1, r2+w, r1+w];
      geom.Mesh.Type = [geom.Mesh.Type; -100];
    end
  end

  %% --- SURFACE WAKES (Including Horizontal Tail) ---
  for idx_surf = 1:length(geom.Surfaces)
    Surf_TE = TE_Wakes{idx_surf};
    WakeStart = size(geom.Mesh.Node, 1) + 1;
    for i = 1:size(Surf_TE, 1)
      mid = (geom.Mesh.Node(Surf_TE(i,1), :) + geom.Mesh.Node(Surf_TE(i,2), :))/2;
      for w = 1:20
        wx = mid(1) + w*BaseSize*10; [rf, yf] = GetFuselageState(wx);
        d = sqrt(mid(3)^2 + (mid(2)-yf)^2);
        if d < rf; scale = (rf+0.001)/d; mid(3)=mid(3)*scale; mid(2)=yf+(mid(2)-yf)*scale; end
        geom.Mesh.Node = [geom.Mesh.Node; wx, mid(2), mid(3)];
      end
    end
    for i = 1:size(Surf_TE, 1)-1
      r1 = WakeStart+(i-1)*20; r2 = WakeStart+i*20;
      for w = 1:19
        geom.Mesh.Elem = [geom.Mesh.Elem; r1+w-1, r2+w-1, r2+w, r1+w];
        geom.Mesh.Type = [geom.Mesh.Type; -idx_surf];
      end
    end
  end
end