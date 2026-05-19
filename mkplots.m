% makes gravity turn plots, assuming a workspace
% containing variables from a successful run of
% get_launch_trajectory

set(groot, "defaultlinelinewidth", 1.5);

figure();
s1 = subplot(3,1,1);
plot(asc.y(4,:)/1000,asc.y(1,:)/1000,'b-'); hold on;
for i = 1:stages
	plot(pwr(i).y(4,:)/1000,pwr(i).y(1,:)/1000,'g-');
  endchar = 'k*';
  if i == stages
    endchar = 'ks';
  endif
	plot(pwr(i).y(4,end)/1000, pwr(i).y(1,end)/1000, endchar);
end
plot(cst.y(4,:)/1000,cst.y(1,:)/1000,'r-');
ylabel("Mass (tons)")#, xlabel("Altitude (m)");
xlabel("Altitude (km)"); xlim([0 tgt_ap/1000]);

s2 = subplot(3,1,2);
plot(asc.y(4,:)/1000,asc.y(3,:)*180/pi,'b-'); hold on;
for i = 1:stages
	plot(pwr(i).y(4,:)/1000,pwr(i).y(3,:)*180/pi,'g-');
  endchar = 'k*';
  if i == stages
    endchar = 'ks';
  endif
	plot(pwr(i).y(4,end)/1000, pwr(i).y(3,end)*180/pi, endchar);
end
plot(cst.y(4,:)/1000,cst.y(3,:)*180/pi,'r-');
ylabel('\beta (deg)');
xlabel("Altitude (km)"); xlim([0 tgt_ap/1000]);

s3 = subplot(3,1,3);
plot(asc.y(4,:)/1000,asc.y(2,:),'b-'); hold on;
for i = 1:stages
	plot(pwr(i).y(4,:)/1000,pwr(i).y(2,:),'g-');
  endchar = 'k*';
  if i == stages
    endchar = 'ks';
  endif
	plot(pwr(i).y(4,end)/1000, pwr(i).y(2,end), endchar);
end
plot(cst.y(4,:)/1000,cst.y(2,:),'r-');
ylabel('Speed (m/s)');
xlabel("Altitude (km)"); xlim([0 tgt_ap/1000]);

set(gca,"defaultlinelinewidth",2);
set([s1, s2, s3], 'fontsize',16, 'ygrid','on');

figure();
plot(asc.y(4,:)/1000,asc.y(3,:)*180/pi,'b-'); hold on;
for i = 1:stages
	plot(pwr(i).y(4,:)/1000,pwr(i).y(3,:)*180/pi,'g-');
  endchar = 'k*';
  if i == stages
    endchar = 'ks';
  endif
	plot(pwr(i).y(4,end)/1000, pwr(i).y(3,end)*180/pi, endchar);
end
plot(cst.y(4,:)/1000,cst.y(3,:)*180/pi,'r-');
ylabel('\beta (deg)'), xlabel("Altitude (km)");
xlim([0 tgt_ap/1000]);
curax = get(gcf,"currentaxes");
set(curax,"fontsize",16);

% make a plot of vehicle flight path
figure();
% convert polar coordinates gotten from theta and altitude into cartesian coordinates for plotting
[asc.xpos,asc.ypos] = pol2cart(asc.y(5,:)+pi/2,r0+asc.y(4,:));
for i = 1:stages
	[pwr(i).xpos,pwr(i).ypos] = pol2cart(pwr(i).y(5,:)+pi/2,r0+pwr(i).y(4,:));
end
[cst.xpos,cst.ypos] = pol2cart(cst.y(5,:)+pi/2,r0+cst.y(4,:));
% generate coordinate set for plotting the surface of kerbin and desired orbit path
[kx,ky] = pol2cart(linspace(0,2*pi,300),ones(1,300)*r0);
[ox,oy] = pol2cart(linspace(0,2*pi,300),ones(1,300)*(r0+tgt_ap));
[sx,sy] = pol2cart(linspace(0,2*pi,300),ones(1,300)*(r0+70000));
% plot Kerbin, Karmann line, and desired orbit
brown = [123 63 0]/norm([123 63 0]);
plot(kx,ky,'color',brown); hold on;
%drawPolygon(kx',ky','g'); hold on; fillPolygon(kx,ky,'g');
plot(sx,sy,'k--');
plot(ox,oy,'c--');
axis equal;
% plot flight path
plot(asc.xpos, asc.ypos, 'b-');
all_xs = [ asc.xpos ]; all_ys = [ asc.ypos ];
for i = 1:stages
	plot(pwr(i).xpos, pwr(i).ypos, 'g-');
  endchar = 'k*';
  if i == stages
    endchar = 'ks';
  endif
	plot(pwr(i).xpos(end), pwr(i).ypos(end), endchar);
	all_xs = [ all_xs, pwr(i).xpos ]; all_ys = [ all_ys, pwr(i).ypos ];
end
plot(cst.xpos, cst.ypos, 'r-');
all_xs = [ all_xs, cst.xpos ]; all_ys = [ all_ys, cst.ypos ];
% set plot limits to be zoomed in on flight path
xtravel = abs(all_xs(end)-all_xs(1));
xlim([median(all_xs)-1.1*xtravel, median(all_xs)+0.6*xtravel]);
ylim([median(all_ys)-0.8*xtravel, median(all_ys)+0.9*xtravel]);
title("Vehicle flight path");
curax = get(gcf,"currentaxes");
set(curax,"fontsize",16);
axis("nolabel");
set(gca,"defaultlinelinewidth",2);
