# FBNeuroSyn
This repository contains minimal working example of the floating bulk avalanche neural-mimicking device for modeling in TCAD Sentaurus and LTSPICE. 

TCAD directory:
This includes two separate projects for Sentaurus TCAD, which include project structure for SWB and command/parameter files for the tools therein.

FloatBulk_Rsub -> The mixed mode simulation includes a parameterized resistance in the bulk bias network, alongside a capacitance.
FloatBulk_Tsub -> The mixed mode simulation includes a generic BSIM modeled n-MOSFET in the bulk bias network, alongside a capacitance.

To work with this projects, simply downlad the repository and copy the folders previously mentioned into your SWB working directory. When running SWB, the projects should appear on your directory tree. 

TCAD version used for building the projects: V-2023.09


SPICE directory:
Language is LTSpice, but easily adaptable to other SPICE releases, as it only employs native device models.

The transistor model is extracted from Predictive Technology Models for a 130 nm node and reduced for compatibility with LTSpice. These are not unique to any process and only exemplary models for the general behaviour of a device in such technology.

To work with these models you may download the repository and copy it to your LTSpice working directory. Then simply open the working netlist or a copy thereof. This netlist will run a transient simulation under ramped voltage input to analyse Id-Vd curves of the floating bulk neuron. LTSpice version used in the latest working version: 17.0.37.0

Known issues: under certain bias and design parameter conditions, the simulation may present oscillations that make it fail or at least lag to a point where execution would not finish in acceptable time. It is up to the user to manage initial conditions, transient damping and RelError tolerances in the simulator to aid convergence.