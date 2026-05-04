loadFigureDefaults

fig = PlotTwoSimComparison3D(wvd22,wvd18,yForXZSlice1=40e3,yForXZSlice2=110e3);

exportgraphics(fig,figureFolder + "/" + "Figure01_two_sim_comparison_3D_H.png",Resolution=300)