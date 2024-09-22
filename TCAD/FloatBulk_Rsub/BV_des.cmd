#setdep @node|nMOS@

*-- @tmodel@

#if "@tmodel@" == "DD"
#define _Tmodel_     * DriftDiffusion
#define _DF_           GradQuasiFermi
#define _AvaDF_        GradQuasiFermi
#define _EQUATIONSET_  Poisson Electron Hole
#elif "@tmodel@" == "HD"
#define _Tmodel_       Hydrodynamic(eTemperature)
#define _DF_           CarrierTempDrive
#define _AvaDF_        CarrierTempDrive
#define _EQUATIONSET_  Poisson Electron Hole eTemperature Temperature
#elif "@tmodel@" == "Thermo"
#define _Tmodel_       Thermodynamic 
#define _DF_           GradQuasiFermi
#define _AvaDF_        GradQuasiFermi
#define _EQUATIONSET_  Poisson Electron Hole Temperature
#endif


#-- quantum correction
#if "@QC@" == "DG"
#define _QC_ eQuantumPotential
#define _QCmodel_ eQuantumPotential
#else
#define _QC_
#define _QCmodel_
#endif

#define _vdd_ 1e2

File {
   Grid      = "@tdr@"
   Plot      = "@tdrdat@"
   Parameter = "@parameter@"
   Current   = "@plot@"
   Output    = "@log@"
}

Electrode {
   { Name="source"    Voltage=0.0 }
   { Name="drain"     Voltage=0.0 Resistor= 1e6 }
   { Name="gate"      Voltage=0.0 }
   { Name="substrate" Voltage=0.0 Resistor= 1 }
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
      Band2Band(Model=NonlocalPath)
      eAvalanche( _AvaDF_)
      hAvalanche( GradQuasiFermi )
   )           
}

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
   AvalDerivatives
   ErrRef(Electron)=1.e10
   ErrRef(Hole)=1.e10
   Transient= BE
   RefDens_eGradQuasiFermi_ElectricField= 1e16
   RefDens_hGradQuasiFermi_ElectricField= 1e16
   BreakCriteria{ Current(Contact="drain" AbsVal=1e-3) } 
   -PlotLoadable 
   RefDens_QuantumPotential= 1e12
   DirectQuantumCorrection
 * Please uncomment if you have 8 CPUs or more
   Number_of_Threads= 12
}

Solve {
   *- Build-up of initial solution:
   NewCurrentPrefix="init_"
   Coupled(Iterations=100){ Poisson _QC_ }
   Plugin(Iterations=10 Digits=3) { _EQUATIONSET_ _QC_ }
   Coupled{ _EQUATIONSET_ _QC_ }

   NewCurrentPrefix="VG_"
   Quasistationary(
      InitialStep=@<0.05/_vdd_>@ Increment=1.4
      MinStep=1e-8 MaxStep=0.025
      Goal{ Name="gate" Voltage=@VG@ }
   ) { Coupled{ _EQUATIONSET_ _QC_} }

   NewCurrentPrefix="BV_"
#   Quasistationary(
#      InitialStep=@<0.05/_vdd_>@ Increment=1.4
#      MinStep=1e-10 MaxStep=0.01
#      Goal{ Name="drain" Voltage=_vdd_ }
#   ) { Coupled{ _EQUATIONSET_ _QC_}
#   Plot(Fileprefix="n@node@_inter" NoOverWrite Time=(Range=(0 1) Intervals=100)) 
#   }

    #Continuation(
#	    Name="drain"                     * Curve is traced at this electrode
#	    InitialVStep=0.1                 * Initial voltage step
#	    Increment=1.41 Decrement=2
#	    MaxVstep=0.25                    * Limits voltage step along curve trace
#	    NewArc
#	    MinVoltage=-0.001 MaxVoltage=6 * Define the I-V window where
#	    MinCurrent=0 MaxCurrent=1e-3  * IV curve is traced
#	    Vadapt=2.0                       * Up to this voltage, a Quasistationary
#		                             * with voltage ramping is used instead
#		                             * of continuation
#	    Iadapt=1e-7                      * Up to this current, a Quasistationary
#		                             * with voltage ramping is used instead
#		                             * of continuation
#   ) { Coupled { _EQUATIONSET_ } }

#-- simlations can be done in transient in a similar manner (commented out)  
   Transient (
      InitialStep=@<0.05/_vdd_>@ Increment=1.4
      MinStep=1e-9 MaxStep=0.025
      Goal{ Name="drain" Voltage=_vdd_  }
   ) { Coupled{ _EQUATIONSET_ _QC_} }

#   System("rm init_n@node@_des.plt")  
}

