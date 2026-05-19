function xdot = dxdt(t,x,u,params)
  m     = x(1);
  v     = x(2);
  beta  = x(3);
  h     = x(4);
  theta = x(5);

  Fmax = [params(1) params(2)];
  Isp  = [params(3) params(4)];
  A    =  params(5);
  g0   =  params(6);
  r0   =  params(7);
  rho0 =  params(8);
  Cd0  =  params(9);

  rho = get_rho_from_y(h);
  Cd  = Cd0*get_pseudoRe(h,v);
  Fmaxnow = Fmax(2) - (rho/rho0)*(Fmax(2)-Fmax(1));
  Ispnow  = Isp(2) - (rho/rho0)*(Isp(2)-Isp(1));
  Fdrag = 0.5*rho*A*Cd*v^2;
  g = g0 * (r0 / (r0+h))^2;

  tdot = (v*sin(beta)) / (r0 + h);
  mdot = -(Fmaxnow*u) / (Ispnow*g0);
  vdot = (Fmaxnow*u - Fdrag)/m - g*cos(beta);
  bdot = (g*sin(beta))/v - tdot;
  hdot = v*cos(beta);

  xdot = [mdot; vdot; bdot; hdot; tdot];
end
