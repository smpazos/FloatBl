#setdep @node|nMOS@

*-- @tmodel@

#if "@tmodel@" == "DD"
#define _Tmodel_     * DriftDiffusion
#define _DF_           GradQuasiFermi
#define _AvaDF_        GradQuasiFermi
#define _EQUATIONSET_  nmos1.Poisson nmos1.Electron nmos1.Hole
#elif "@tmodel@" == "HD"
#define _Tmodel_       Hydrodynamic(eTemperature)
#define _DF_           CarrierTempDrive
#define _AvaDF_        CarrierTempDrive
#define _EQUATIONSET_  nmos1.Poisson nmos1.Electron nmos1.Hole nmos1.eTemperature nmos1.Temperature
#elif "@tmodel@" == "Thermo"
#define _Tmodel_       Thermodynamic 
#define _DF_           GradQuasiFermi
#define _AvaDF_        GradQuasiFermi
#define _EQUATIONSET_  nmos1.Poisson nmos1.Electron nmos1.Hole nmos1.Temperature
#endif


#-- quantum correction
#if "@QC@" == "DG"
#define _QC_ eQuantumPotential
#define _QCmodel_ eQuantumPotential
#else
#define _QC_
#define _QCmodel_
#endif

#define _vdd_ 1e4


Device "MOS" {
	File {
	   Grid      = "@tdr@"
	   Plot      = "@tdrdat@"
	   Parameter = "@parameter@"
	   Current   = "@plot@"
	   #Output    = "@log@"
	}

	Electrode {
	   { Name="source"    Voltage=0.0 }
	   { Name="drain"     Voltage=0.0 }
	   #{ Name="drain"     Voltage=0.0 Resistor= 1e7 }
	   { Name="gate"      Voltage=0.0 }
	   #{ Name="substrate" Voltage=0.0 Resistor= 1e8 }
	   { Name="substrate" Voltage=0.0}
	}

	Thermode{ 
	  { Name="substrate" Temperature=300 SurfaceResistance=5e-4 } 
	  { Name="drain" Temperature=300 SurfaceResistance=1e-3 } 
	  { Name="source" Temperature=300 SurfaceResistance=1e-3 } 
	}

	Physics {
	   _Tmodel_  
	   _QCmodel_
	}

	Physics(Material="Silicon") {
	   Fermi
	   EffectiveIntrinsicDensity( OldSlotboom )     
	   Mobility(
	      DopingDep
	      eHighFieldsaturation( _DF_ )
	      hHighFieldsaturation( GradQuasiFermi )
	      Enormal
	   )
	   Recombination(
	      Auger
	      SRH( DopingDep TempDependence )
              *- Band2Band(Model=NonlocalPath)
	      eAvalanche( _AvaDF_)
	      hAvalanche( GradQuasiFermi )
	   )           
	}
} * End of Device{}

Plot{
*--Density and Currents, etc
   eDensity hDensity
   TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
   eMobility hMobility
   eVelocity hVelocity
   eQuasiFermi hQuasiFermi

*--Temperature 
   eTemperature Temperature * hTemperature

*--Fields and charges
   ElectricField/Vector Potential SpaceCharge

*--Doping Profiles
   Doping DonorConcentration AcceptorConcentration

*--Generation/Recombination
   SRH Band2Band Auger
   ImpactIonization eImpactIonization hImpactIonization

*--Driving forces
   eGradQuasiFermi/Vector hGradQuasiFermi/Vector
   eEparallel hEparallel eENormal hENormal

*--Band structure/Composition
   BandGap BandGapNarrowing Affinity
   ConductionBand ValenceBand
   eQuantumPotential
}

Math {
   Extrapolate
   Avalderivatives
   Iterations= 20
   Notdamped= 100
   Method= Blocked
   SubMethod= Pardiso
   RelErrControl
   Digits=5                  * (default)
   ErrRef(electron)=1.e10    * (default)
   ErrRef(hole)=1.e10        * (default)
   Transient= BE
   RefDens_eGradQuasiFermi_ElectricField= 1e16
   RefDens_hGradQuasiFermi_ElectricField= 1e16
   BreakCriteria{ Current(Contact="drain" AbsVal=100e-3) } 
   -PlotLoadable 
   RefDens_QuantumPotential= 1e12
   DirectQuantumCorrection
 * Please uncomment if you have 8 CPUs or more
   Number_of_Threads= 12
}


File {
  Output    = "@log@"
}

System { *contains the netlist
  *-Physical devices:
  MOS nmos1 ( "source"=0  "drain"=dr "gate"=ga "substrate"=subs )
  
  *-Lumped elements:
  Vsource_pset vgate (ga 0) { 
    pulse = (0.0       # dc
      0.35       # amplitude
      0    # td
      0.1    # tr
      0.1    # tf
      70    # ton
      80)   # period 
 }
  Vsource_pset vdrain (out 0) { 
    pulse = (0.0       # dc
      6       # amplitude
      0.1    # td
      30    # tr
      30    # tf
      0.001    # ton
      80)   # period 
  }
  Resistor_pset Rdrain ( out dr ){ resistance = 1000 }
  Resistor_pset Rbulk ( subs 0 ){ resistance = @Rsub@ }
  Capacitor_pset cout ( subs 0 ) { capacitance = @Cbulk@ }

  *-Plot:
  Plot "n@node@_sys_des.plt" (time() v(ga) v(dr) v(out) v(subs)
  i(nmos1,dr))
}


Solve {
   *- Build-up of initial solution:
   NewCurrentPrefix="init_"
   Coupled(Iterations=100){ Poisson _QC_ }
   Plugin(Iterations=10 Digits=3) { _EQUATIONSET_ }
   Coupled{ _EQUATIONSET_ }

#-- simlations can be done in transient in a similar manner (commented out)  
   Transient (
      InitialTime=0 FinalTime=60.1
      InitialStep=1e-6 Increment=2 Decrement=3
      MaxStep=0.5 MinStep=1e-13
    ){ 
      Coupled { nmos1.poisson nmos1.electron nmos1.hole nmos1.contact circuit }
      *- Plot(FilePrefix= "n@node@" NoOverWrite Time = (Range = (0 60.1)  Intervals = 200)) 
  }
   #) { Coupled{ _EQUATIONSET_ _QC_} }

   System("rm init_n@node@_des.plt")  
}
