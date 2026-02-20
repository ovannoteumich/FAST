function coords = NACA(series)
% returns coords of the open naca 4 or 5 series airfoil
%   takes it in as an int :/
  if series < 1 || series > 99999 || mod(series,1) ~= 0
    error(['Invalid NACA Series Airfoil ' num2str(series)]);
  end

  t = mod(series,100)/100;
  
  x = 0:1e-2:1;
  x = 6*x.^5 - 15*x.^4 + 10*x.^3;
  y = 5*t*(0.2969*sqrt(x) - 0.1260*x - 0.3516*x.^2 + 0.2843*x.^3 - 0.1015*x.^4);
  
  coords.x = [flip(x),x(2:end)];
  coords.y = [flip(y),-y(2:end)];
  
  if series < 10000
    m = floor(series/1000)/100;
  
    if m > 0
      p = mod(floor(series/100),10)/10;
  
      x = coords.x;
  
      theta = zeros(size(coords.y));
      theta(x <= p) = atan(2*m/p^2*(p - x(x <= p)));
      theta(x > p) = atan(2*m/(1-p)^2*(p - x(x > p)));
  
      coords.x = x - coords.y.*sin(theta);

      coords.y(x <= p) = coords.y(x <= p).*cos(theta(x <= p)) + m/p^2*(2*p*x(x <= p) - x(x <= p).^2);
      coords.y(x > p) = coords.y(x > p).*cos(theta(x > p)) + m/(1-p)^2*((1-2*p) + 2*p*x(x > p) - x(x > p).^2);
    end
  else
    l = floor(series/10000);

    if l > 0
      s = mod(floor(series/100),10);
      p = mod(floor(series/1000),10);
      
      if s == 0 && p > 0 && p < 6
        % Standard Camber Coefficients
        r = [0.0580, 0.1260, 0.2025, 0.2900, 0.3910];
        k1 = [361.4, 51.64, 15.957, 6.643, 3.230];

        r = r(p);
        k1 = k1(p);
    
        x = coords.x;
    
        theta = zeros(size(coords.y));
        theta(x <= r) = atan(k1/6*(3*x(x <= r).^2 - 6*r*x(x <= r) + r^2*(3-r)));
        theta(x > r) = atan(-k1*r^3/6)*ones(size(theta(x > r)));
    
        coords.x = x - coords.y.*sin(theta);
  
        coords.y(x <= r) = coords.y(x <= r).*cos(theta(x <= r)) + k1/6*(x(x <= r).^3 - 3*r*x(x <= r).^2 + r^2*(3-r)*x(x <= r));
        coords.y(x > r) = coords.y(x > r).*cos(theta(x > r)) + k1*r^3/6*(1-x(x > r));
            
      elseif s == 1 && p > 1 && p < 6
        % Reflexed Camber Coefficients
        r = [0, 0.1300, 0.2170, 0.3180, 0.4410];
        k1 = [0, 51.99, 15.793, 6.520, 3.191];
        k2k1 = [0, 0.000764, 0.00677, 0.0303, 0.1355];

        r = r(p);
        k1 = k1(p);
        k2k1 = k2k1(p);

        x = coords.x;
    
        theta = zeros(size(coords.y));
        theta(x <= r) = atan(k1/6*(3*(x(x <= r)-r).^2 - k2k1*(1-r)^3 - r^3));
        theta(x > r) = atan(k1/6*(3*k2k1*(x(x > r)-r).^2 - k2k1*(1-r)^3 - r^3));
    
        coords.x = x - coords.y.*sin(theta);
  
        coords.y(x <= r) = coords.y(x <= r).*cos(theta(x <= r)) + k1/6*((x(x <= r)-r).^3 - k2k1*(1-r)^3*x(x <= r) - r^3*x(x <= r) + r^3);
        coords.y(x > r) = coords.y(x > r).*cos(theta(x > r)) + k1/6*(k2k1*(x(x > r)-r).^3 - k2k1*(1-r)^3*x(x > r) - r^3*x(x > r) + r^3);
      else
        error(['Invalid NACA Series Airfoil ' num2str(series)]);
      end
    end
  end
end