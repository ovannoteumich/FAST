function results = AeroSolver(geom,conditions)
% Solves everything needed for results and stability analysis (condition dependent)
  gamma = 1.4;
  R = 287.15;
  [T, P, rho] = MissionSegsPkg.StdAtm(conditions.alt);
  if isfield(conditions,"Mach")
    conditions.V = conditions.Mach * sqrt(gamma*R*T); 
  end
  q = rho*conditions.V^2/2;
  
  % Actuator Disk Velocity Jump (Delta V)
  Vprop = sqrt(conditions.V^2 + conditions.T*2/(rho*sum(pi*(geom.Props.Diameter/2).^2) + 1e-20)) - conditions.V;
  
  %% MAIN SOLVER LOOP
  atest = deg2rad(conditions.alpha);
  h = 1e-12; % Standard complex step h
  hi = h*1i;
  
  SfPlan = 0.96*geom.Mesh.FuselageLength*geom.Fuselage.Diameter;
  SfWet = 0.9*geom.Mesh.FuselageLength*geom.Fuselage.Diameter*pi;
  Vf = 0.8*geom.Mesh.FuselageLength*(geom.Fuselage.Diameter/2)^2;
  
  isLifting = geom.Mesh.Type < 3;
  idxL = find(isLifting);
  idxP = find(geom.Mesh.Type == 3);
  nL = length(idxL);
  
  % Pre-calculate prop centers to avoid repeated mesh access
  propCenters = zeros(length(idxP), 3);
  for k_p = 1:length(idxP)
    propCenters(k_p,:) = geom.Mesh.Node(geom.Mesh.Elem(idxP(k_p),1),:);
  end
  for i = 1:20 % Increased iterations for convergence
    a = atest + hi;
    
    %% FUSELAGE COMPONENTS
    Lf = 1.5*q*SfPlan*a;
    Df = 0.003*q*SfWet*(1 + 60/(geom.Mesh.FuselageLength/geom.Fuselage.Diameter)^3 + 0.0025*(geom.Mesh.FuselageLength/geom.Fuselage.Diameter)) + abs(Lf*tan(a));
    Mf = 0.9*q*Vf*a + Lf*geom.Mesh.FuselageLength/4;
    
    %% WING COMPONENTS (VLM)
    uinf = [cos(a), 0, sin(a)]; 
    Vinf = conditions.V * uinf;
    
    VL = zeros(nL,3); VR = zeros(nL,3);
    CP = zeros(nL,3); nvec = zeros(nL,3);
    TE2 = zeros(nL,3); TE3 = zeros(nL,3);
    
    for j = 1:nL
      id = idxL(j);
      p1 = geom.Mesh.Node(geom.Mesh.Elem(id,1),:);
      p2 = geom.Mesh.Node(geom.Mesh.Elem(id,2),:);
      p3 = geom.Mesh.Node(geom.Mesh.Elem(id,3),:);
      p4 = geom.Mesh.Node(geom.Mesh.Elem(id,4),:);
      
      VL(j,:) = 0.75*p1 + 0.25*p2;
      VR(j,:) = 0.75*p4 + 0.25*p3;
      CP(j,:) = (0.25*p1 + 0.75*p2 + 0.25*p4 + 0.75*p3)/2;
      TE2(j,:) = p2;
      TE3(j,:) = p3;
      
      nv = cross(p2-p1, p4-p1); 
      nvec(j,:) = nv / (norm(nv) + 1e-20);
      
      if nvec(j,3) < 0 && geom.Mesh.Type(id) ~= 2; nvec(j,:) = -nvec(j,:); end
      if nvec(j,2) < 0 && geom.Mesh.Type(id) == 2; nvec(j,:) = -nvec(j,:); end
    end
    
    A = zeros(nL+1,nL+1);
    b = zeros(nL+1,1);
    
    for j = 1:nL
      curr_j = idxL(j);
      Vlocal = Vinf;
      % Optimized Prop Wash Check
      for k_p = 1:size(propCenters,1)
          dist_sq = sum((CP(j,2:3) - propCenters(k_p,2:3)).^2);
          if dist_sq < (geom.Props.Diameter(1)/2)^2 && CP(j,1) > propCenters(k_p,1)
              Vlocal = Vlocal + Vprop*[1,0,0]; 
              break; % Apply once per panel
          end
      end
      
      b(j) = -dot(Vlocal, nvec(j,:));
      
      % Trim Column: d(B.C.)/d(delta_e)
      if abs(geom.Mesh.Type(curr_j) - (1+(conditions.TrimSurf-1)/10)) < 1e-5
        dn_ddelta = [-nvec(j,3), 0, nvec(j,1)]; 
        A(j,end) = -dot(Vlocal, dn_ddelta); 
      end
      
      for k = 1:nL
        id_k = idxL(k);
        vidx = vortex(CP(j,:),VL(k,:),VR(k,:)) + vortex(CP(j,:),TE2(k,:),VL(k,:)) + ...
               vortex(CP(j,:),VR(k,:),TE3(k,:)) - infvortex(CP(j,:),TE2(k,:),[1,0,0]) + ...
               infvortex(CP(j,:),TE3(k,:),[1,0,0]);
        A(j,k) = dot(vidx, nvec(j,:));
        
        if geom.Mesh.Type(id_k) ~= 2 
          VLs = [VL(k,1), -VL(k,2), VL(k,3)];
          VRs = [VR(k,1), -VR(k,2), VR(k,3)];
          p2s = [TE2(k,1), -TE2(k,2), TE2(k,3)];
          p3s = [TE3(k,1), -TE3(k,2), TE3(k,3)];
          
          vidx_s = vortex(CP(j,:),VLs,VRs) + vortex(CP(j,:),p2s,VLs) + ...
                   vortex(CP(j,:),VRs,p3s) - infvortex(CP(j,:),p2s,[1,0,0]) + ...
                   infvortex(CP(j,:),p3s,[1,0,0]);
          A(j,k) = A(j,k) + dot(vidx_s, nvec(j,:));
        end
      end
      
      % Moment Row
      dl = VR(j,:) - VL(j,:);
      dFdG = rho * cross(Vlocal, dl);
      if geom.Mesh.Type(curr_j) ~= 2
          dFdG = dFdG * 2; 
      end
      rcp = CP(j,:) - conditions.CG;
      % Final normalization to keep matrix well-conditioned
      A(end, j) = (rcp(3)*dFdG(1) - rcp(1)*dFdG(3)) / (q + 1e-4); 
    end
    
    A(end,end) = 1e-12; 
    % Check if any trim surface was actually found to populate A(end,end)
    % otherwise the system is singular.
    b(end) = -Mf / (q + 1e-4); 
    
    x = A\b;
    
    L = Lf; D = Df; M = Mf; 
    for j = 1:nL
      curr_j = idxL(j);
      Vlocal = Vinf;
      for k_p = 1:size(propCenters,1)
          dist_sq = sum((CP(j,2:3) - propCenters(k_p,2:3)).^2);
          if dist_sq < (geom.Props.Diameter(1)/2)^2 && CP(j,1) > propCenters(k_p,1)
              Vlocal = Vlocal + Vprop*[1,0,0];
              break;
          end
      end
      dl = VR(j,:) - VL(j,:);
      F = rho*x(j)*cross(Vlocal,dl);
      if geom.Mesh.Type(curr_j) ~= 2
        F = F * 2;
      end
      L = L + F(3); 
      D = D + dot(F, uinf);
      rcp = CP(j,:) - conditions.CG;
      M = M + (rcp(3)*F(1) - rcp(1)*F(3));
    end
    
    resL = real(L) - conditions.L;
    dLda = imag(L)/h;
    
    if abs(resL/conditions.L) < 1e-4; break; end
    
    if abs(dLda) > 1e-12
        step = resL/dLda;
        atest = atest - max(min(step, 0.05), -0.05); 
    else
        break;
    end
    atest = max(min(atest, deg2rad(25)), deg2rad(-10));
  end
  
  results.alpha = rad2deg(real(atest));
  results.L = real(L);
  results.dLda = imag(L)/h;
  results.D = real(D);
  results.dDda = imag(D)/h;
  results.M = real(M);
  results.dMda = imag(M)/h;
  results.del = rad2deg(real(x(end))); 
  results.iters = i;

  %% STABILITY ANALYSIS
  if isfield(conditions,"Stab") && conditions.Stab
    idxR = find(geom.Mesh.Type < 3);
    idxS = find(geom.Mesh.Type < 2);
    nM = length(idxR) + length(idxS);
    
    a_base = real(atest);
    del_trim = real(x(end));
    
    for st = 1:2
      a = a_base; b = 0;
      if st == 1; a = a + hi; end
      if st == 2; b = b + hi; end
      
      %% FUSELAGE COMPONENTS
      Lf = 1.5*q*SfPlan*a;
      Yf = -1.5*q*SfPlan*b; 
      Df = 0.003*q*SfWet*(1 + 60/(geom.Mesh.FuselageLength/geom.Fuselage.Diameter)^3 + 0.0025*(geom.Mesh.FuselageLength/geom.Fuselage.Diameter)) + abs(Lf*tan(a));
      Mf = 0.9*q*Vf*a + Lf*geom.Mesh.FuselageLength/4;
      Nf = -0.9*q*Vf*b - Yf*geom.Mesh.FuselageLength/4;
      
      %% WING COMPONENTS (ASYSMMETRIC REBUILD)
      % uinf based on X-forward, Z-up
      uinf = [cos(a)*cos(b), sin(b), sin(a)*cos(b)]; 
      Vinf = conditions.V * uinf;
      
      VL_a = zeros(nM,3); VR_a = zeros(nM,3);
      CP_a = zeros(nM,3); nvec_a = zeros(nM,3);
      TE2_a = zeros(nM,3); TE3_a = zeros(nM,3);
      
      for j = 1:nM
        if j <= length(idxR)
          id = idxR(j);
          p1 = geom.Mesh.Node(geom.Mesh.Elem(id,1),:);
          p2 = geom.Mesh.Node(geom.Mesh.Elem(id,2),:);
          p3 = geom.Mesh.Node(geom.Mesh.Elem(id,3),:);
          p4 = geom.Mesh.Node(geom.Mesh.Elem(id,4),:);
          mType = geom.Mesh.Type(id);
        else
          id = idxS(j - length(idxR));
          % Mirror nodes across Y plane (Symmetric logic)
          mS = [1, -1, 1];
          p1 = geom.Mesh.Node(geom.Mesh.Elem(id,1),:) .* mS;
          p2 = geom.Mesh.Node(geom.Mesh.Elem(id,2),:) .* mS;
          p3 = geom.Mesh.Node(geom.Mesh.Elem(id,3),:) .* mS;
          p4 = geom.Mesh.Node(geom.Mesh.Elem(id,4),:) .* mS;
          mType = geom.Mesh.Type(id);
        end
        
        VL_a(j,:) = 0.75*p1 + 0.25*p2;
        VR_a(j,:) = 0.75*p4 + 0.25*p3;
        CP_a(j,:) = (0.25*p1 + 0.75*p2 + 0.25*p4 + 0.75*p3)/2;
        TE2_a(j,:) = p2;
        TE3_a(j,:) = p3;
        
        nv = cross(p2-p1, p4-p1); 
        nvec_a(j,:) = nv / (norm(nv) + 1e-20);
        
        if nvec_a(j,3) < 0 && mType ~= 2; nvec_a(j,:) = -nvec_a(j,:); end
        if nvec_a(j,2) < 0 && mType == 2; nvec_a(j,:) = -nvec_a(j,:); end
        
        % Apply Elevator Trim (Pitch rotation about Y-axis in Z-up)
        if abs(mType - (1+(conditions.TrimSurf-1)/10)) < 1e-5
          Rdel = [cos(del_trim) 0 -sin(del_trim); 0 1 0; sin(del_trim) 0 cos(del_trim)];
          nvec_a(j,:) = (Rdel * nvec_a(j,:)')';
        end
      end
      
      A_a = zeros(nM,nM);
      b_a = zeros(nM,1);
      for j = 1:nM
        Vlocal = Vinf;
        for k_p = 1:size(propCenters,1)
          dist_sq = sum((CP_a(j,2:3) - propCenters(k_p,2:3)).^2);
          if dist_sq < (geom.Props.Diameter(1)/2)^2 && CP_a(j,1) > propCenters(k_p,1)
            Vlocal = Vlocal + Vprop*[1,0,0]; break;
          end
        end
        b_a(j) = -dot(Vlocal, nvec_a(j,:));
        for k = 1:nM
          vidx = vortex(CP_a(j,:),VL_a(k,:),VR_a(k,:)) + vortex(CP_a(j,:),TE2_a(k,:),VL_a(k,:)) + ...
                 vortex(CP_a(j,:),VR_a(k,:),TE3_a(k,:)) - infvortex(CP_a(j,:),TE2_a(k,:),[1,0,0]) + ...
                 infvortex(CP_a(j,:),TE3_a(k,:),[1,0,0]);
          A_a(j,k) = dot(vidx, nvec_a(j,:));
        end
      end
      
      x_a = A_a\b_a;
      
      L_s = Lf; D_s = Df; M_s = Mf; Y_s = Yf; N_s = Nf;
      for j = 1:nM
        Vlocal = Vinf;
        for k_p = 1:size(propCenters,1)
          dist_sq = sum((CP_a(j,2:3) - propCenters(k_p,2:3)).^2);
          if dist_sq < (geom.Props.Diameter(1)/2)^2 && CP_a(j,1) > propCenters(k_p,1)
            Vlocal = Vlocal + Vprop*[1,0,0]; break;
          end
        end
        dl = VR_a(j,:) - VL_a(j,:);
        F = rho*x_a(j)*cross(Vlocal,dl);
        L_s = L_s + F(3);
        Y_s = Y_s + F(2);
        D_s = D_s + dot(F, real(uinf));
        rcp = CP_a(j,:) - conditions.CG;
        M_s = M_s + (rcp(3)*F(1) - rcp(1)*F(3));
        N_s = N_s + (rcp(1)*F(2) - rcp(2)*F(1));
      end
      
      if st == 1
        results.L = real(L_s);
        results.D = real(D_s);
        results.M = real(M_s);
        results.dLda = imag(L_s)/h;
        results.dDda = imag(D_s)/h;
        results.dMda = imag(M_s)/h;
      elseif st == 2
        results.Y = real(Y_s);
        results.N = real(N_s);
        results.dYdb = imag(Y_s)/h;
        results.dNdb = imag(N_s)/h;
      end
    end
    
    % Static Margins
    results.SM_Pitch = -results.dMda / (results.dLda * geom.Mesh.FuselageLength + 1e-20);
    results.SM_Yaw = results.dNdb / (abs(results.dYdb) * geom.Mesh.FuselageLength + 1e-20);
  end
end

function v = vortex(P, p1, p2)
  r1 = P - p1; r2 = P - p2; r0 = p2 - p1;
  c = cross(r1,r2);
  mag1 = sqrt(sum(r1.^2) + 1e-20);
  mag2 = sqrt(sum(r2.^2) + 1e-20);
  v = 1/(4*pi) * c/(sum(c.^2) + 1e-7) * dot(r0, (r1/mag1 - r2/mag2));
end

function v = infvortex(P, p, dir)
  r = P - p;
  c = cross(dir,r);
  mag = sqrt(sum(r.^2) + 1e-20);
  v = 1/(4*pi) * c/(sum(c.^2) + 1e-7) * (1 + dot(dir,r)/mag);
end