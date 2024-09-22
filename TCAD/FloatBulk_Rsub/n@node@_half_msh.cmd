Title ""

Controls {
}

IOControls {
	EnableSections
}

Definitions {
	Constant "Const.Substrate" {
		Species = "BoronActiveConcentration"
		Value = 1e+16
	}
	AnalyticalProfile "Impl.CHprof" {
		Species = "BoronActiveConcentration"
		Function = Gauss(PeakPos = 0, PeakVal = 1e+18, ValueAtDepth = 1e+16, Depth = 0.36)
		LateralFunction = Gauss(Factor = 0.4)
	}
	Constant "Const.Gate" {
		Species = "ArsenicActiveConcentration"
		Value = 1e+20
	}
	AnalyticalProfile "Impl.SDprof" {
		Species = "ArsenicActiveConcentration"
		Function = Gauss(PeakPos = 0, PeakVal = 6e+20, ValueAtDepth = 1e+16, Depth = 0.18)
		LateralFunction = Gauss(Factor = 0.4)
	}
	AnalyticalProfile "Impl.SDextprof" {
		Species = "ArsenicActiveConcentration"
		Function = Gauss(PeakPos = 0, PeakVal = 2e+20, ValueAtDepth = 1e+16, Depth = 0.045)
		LateralFunction = Gauss(Factor = 0.25)
	}
	Refinement "Global_def" {
		MaxElementSize = ( 0.75 0.1525 )
		MinElementSize = ( 0.15 0.0305 )
	}
	Refinement "Active_def" {
		MaxElementSize = ( 0.0225 0.035 )
		MinElementSize = ( 0.0045 0.007 )
	}
	Refinement "Channel_def" {
		MaxElementSize = ( 0.01125 0.02125 )
		MinElementSize = ( 0.00225 0.00425 )
	}
	Refinement "RD_def_0" {
		MaxElementSize = ( 6.104 3.05 0 )
		MinElementSize = ( 0.001 0.001 0.001 )
		RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
	}
	Refinement "refintdef_0" {
		MaxElementSize = 100
		MinElementSize = 0.0002
		RefineFunction = MaxLenInt(Interface("R.Polygate","R.Gateox"), Value=0.0002, factor=2, UseRegionNames)
	}
	Refinement "refintdef_1" {
		MaxElementSize = 100
		MinElementSize = 0.0001
		RefineFunction = MaxLenInt(Interface("R.Substrate","R.Gateox"), Value=0.0001, factor=1.6, UseRegionNames)
	}
}

Placements {
	Constant "PlaceCD.Substrate" {
		Reference = "Const.Substrate"
		EvaluateWindow {
			Element = region ["R.Substrate"]
		}
	}
	AnalyticalProfile "Impl.CH" {
		Reference = "Impl.CHprof"
		ReferenceElement {
			Element = Line [(0 3.05) (0 0)]
			Direction = positive
		}
	}
	Constant "PlaceCD.Gate" {
		Reference = "Const.Gate"
		EvaluateWindow {
			Element = region ["R.Polygate"]
		}
	}
	AnalyticalProfile "Impl.Drain" {
		Reference = "Impl.SDprof"
		ReferenceElement {
			Element = Line [(0 0.61) (0 0.165)]
			Direction = positive
		}
	}
	AnalyticalProfile "Impl.DrainExt" {
		Reference = "Impl.SDextprof"
		ReferenceElement {
			Element = Line [(0 0.61) (0 0.085)]
			Direction = positive
		}
	}
	Refinement "Global_plc" {
		Reference = "Global_def"
		RefineWindow = Rectangle [(-100 -100) (100 100)]
	}
	Refinement "Active_plc" {
		Reference = "Active_def"
		RefineWindow = Rectangle [(0 0) (0.216 0.305)]
	}
	Refinement "Channel_plc" {
		Reference = "Channel_def"
		RefineWindow = Rectangle [(0 0) (0.18 0.265)]
	}
	Refinement "RD_plc_0" {
		Reference = "RD_def_0"
		RefineWindow = material ["Silicon"]
	}
	Refinement "refintplc_0" {
		Reference = "refintdef_0"
		RefineWindow = region ["R.Polygate"]
	}
	Refinement "refintplc_1" {
		Reference = "refintdef_1"
		RefineWindow = region ["R.Substrate"]
	}
}

