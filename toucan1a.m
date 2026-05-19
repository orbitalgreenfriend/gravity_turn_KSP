ves_name = "Toucan Ia";
% ========================= %
% initial vehicle states    %
% ========================= %
m0 = [ 15.375;
       3.910  ]; % in tonnes
h0 = 86;         % in m
% ========================= %
% vehicle parameters        %
% ========================= %
% each row is a new stage;
% where applicable, column one is SL performance, col 2 is vacuum
Isp  = [ 275 305;      % stage 1
         275 290 ];    % stage 2
Fmax = [ 216.39 240;
         45.517 48   ]; % in kN
Cd0  = [ 0.86;
         0.86 ]; % cone
A    = [ 2.63;
	       2.63  ]; % m^2
m1   = [ 6.822;
         2.440 ]; % final mass
