loadFigureDefaults
wvd = wvd18;

% colors
C = orderedcolors("gem"); 
clear col;
col.waveBold = C(5,:);
col.geoBold = C(6,:);

depths = -2500;
depthIndices = zeros(size(depths));
z = wvd.wvfile.readVariables('mooring/mooring_z');
for iDepth=1:length(depths)
    [~,depthIndices(iDepth)] = min(abs(z - depths(iDepth)));
end

figPos = [50 50 500 300];
fig = figure(Units='points',Position=figPos);
set(gcf,'PaperPositionMode','auto')

ax1 = axes(fig);
set(ax1,'XScale','log')
set(ax1,'YScale','log')
axis tight
box on
hold on

% geostrophic velocity
t = wvd.wvfile.readVariables('mooring/t');
u = wvd.wvfile.readVariables('mooring/mooring_u_g');
v = wvd.wvfile.readVariables('mooring/mooring_v_g');
u = u(depthIndices,:,:);
v = v(depthIndices,:,:);

cv_mooring = shiftdim( u + sqrt(-1)*v, 2);
[PSI,LAMBDA] = sleptap(length(t),5);
[omega_p, Spp, Snn, Spn] = mspec(t(2)-t(1),cv_mooring,PSI);
Spp = mean(Spp,3);
Snn = mean(Snn,3);

plt1 = loglog(ax1,omega_p*86400/2/pi,fliplr(Snn)*2*pi/86400,'-','Color',col.geoBold,'DisplayName','negative geostrophic',LineWidth=2);
plt2 = loglog(ax1,omega_p*86400/2/pi,fliplr(Spp)*2*pi/86400,'-','Color',col.geoBold,'DisplayName','positive geostrophic',LineWidth=1);


% wave velocity
u = wvd.wvfile.readVariables('mooring/mooring_u_w')+wvd.wvfile.readVariables('mooring/mooring_u_io');
v = wvd.wvfile.readVariables('mooring/mooring_v_w')+wvd.wvfile.readVariables('mooring/mooring_v_io');
u = u(depthIndices,:,:);
v = v(depthIndices,:,:);

cv_mooring = shiftdim( u + sqrt(-1)*v, 2);
[omega_p, Spp, Snn, Spn] = mspec(t(2)-t(1),cv_mooring,PSI);
Spp = mean(Spp,3);
Snn = mean(Snn,3);

plt3 = loglog(ax1,omega_p*86400/2/pi,fliplr(Snn)*2*pi/86400,'-','Color',col.waveBold,'DisplayName','negative wave',LineWidth=2);
plt4 = loglog(ax1,omega_p*86400/2/pi,fliplr(Spp)*2*pi/86400,'-','Color',col.waveBold,'DisplayName','positive wave',LineWidth=1);

legend(ax1,[plt1,plt2,plt3,plt4],'location','southwest')
xlabel('frequency (cycles per day)')
ylabel('power (m^2 s^{-2}/cpd)')

% reference frequency lines
M2Period = 12.420602*3600; % M2 tidal period, s
plt5 = plot(ax1,[wvd.wvt.f,wvd.wvt.f]*86400/2/pi,ylim,'k--','DisplayName','f','HandleVisibility','off');
plt6 = plot(ax1,[2*pi/M2Period,2*pi/M2Period]*86400/2/pi,ylim,'k--','DisplayName','M2','HandleVisibility','off');
plt7 = plot(ax1,[2*pi/M2Period+wvd.wvt.f,2*pi/M2Period+wvd.wvt.f]*86400/2/pi,ylim,'k--','DisplayName','f+M2','HandleVisibility','off');
plt8 = plot(ax1,sqrt(wvd.wvt.N2(depthIndices(1)))*86400/2/pi*[1,1],ylim,'k--','DisplayName','N(-2500m)','HandleVisibility','off');

% reference frequency labels
% textY = .5*max(ax2.YLim);
textY = 2*min(ax1.YLim);
text(ax1,wvd.wvt.f*86400/2/pi,textY,'f','Color','k','HorizontalAlignment','right','FontWeight','bold')
text(ax1,2*pi/M2Period*86400/2/pi,textY,'M2','Color','k','HorizontalAlignment','right','FontWeight','bold')
text(ax1,(2*pi/M2Period+wvd.wvt.f)*86400/2/pi,textY,'f+M2','Color','k','HorizontalAlignment','left','FontWeight','bold')
text(ax1,sqrt(wvd.wvt.N2(depthIndices(1)))*86400/2/pi,textY,'N(2500m)','Color','k','HorizontalAlignment','left','FontWeight','bold')


exportgraphics(fig,figureFolder + "/" + "Figure09_moorings_decomposed.png",Resolution=300)

