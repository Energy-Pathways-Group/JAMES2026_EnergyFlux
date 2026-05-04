loadFigureDefaults

fig = wvd.plotFluidDecompositionMultipanel(yForXZSlice=110e3,title="none",visible="on");
exportgraphics(fig,figureFolder + "/" + "Figure07_fluid_decomposition.png",Resolution=300)