DISCLAIMER: This repository is provided "as-is", merely for academic purposes.

This public repository contains source data and code related to the manuscript:	

"Synaptic and neural behaviours in a standard silicon transistor", S. Pazos et al.

In this repository you will find:

1) Source data for all figures of the main manuscript, necessary to draw the main conclusions from the work.

2) Model files and netlists for the simulation of the general parametric compact model for the floating bulk device operating as a neuron.

3) Full projects for TCAD simulation of the floating bulk devices used in the Supplementary Information of the manuscript to validate the dynamics and origin of the neural behaviour in floating bulk devices. Projects include command files for parametric structure construction and meshing as well as simulation files under different parametric conditons and experiments covered in the Supplementary Information file. For details on how the simulation projects are organised, please refer to the Supplementary Information file provided by the publisher within the manuscript URL.

# /SimulationFiles
This repository contains minimal working example of the floating bulk avalanche neural-mimicking device for modeling in TCAD Sentaurus and LTSPICE. 

TCAD directory:
This includes two separate projects for Sentaurus TCAD, which include project structure for SWB (Sentaurus Workbench) and command/parameter files for the tools therein.

FloatBulk_Rsub -> The mixed mode simulation includes a parameterized resistance in the bulk bias network, alongside a capacitance.
FloatBulk_Tsub -> The mixed mode simulation includes a generic BSIM modeled n-MOSFET in the bulk bias network, alongside a capacitance.

To work with this projects, simply downlad the repository and copy the folders previously mentioned into your SWB working directory. When running SWB, the projects should appear on your directory tree. 

TCAD version used for building the projects: V-2023.09


SPICE directory:
Language is LTSpice, but easily adaptable to other SPICE releases, as it only employs native device models.

To work with these models you may download the repository and copy it to your LTSpice working directory. Then simply open the working netlist or a copy thereof. This netlist will run a transient simulation under ramped voltage input to analyse Id-Vd curves of the floating bulk neuron. LTSpice version used in the latest working version: 17.0.37.0

Known issues: under certain bias and design parameter conditions, the simulation may present oscillations that make it fail or at least lag to a point where execution would not finish in acceptable time. It is up to the user to manage initial conditions, transient damping and RelError tolerances in the simulator to aid convergence.

PTM130bulk_lite.txt
-------------------
MOSFET model file. The transistor model is extracted from Predictive Technology Models for a 130 nm node and reduced for compatibility with LTSpice. These are not unique to any process and only exemplary models for the general behaviour of a device in such technology.

Davalanche.txt
-------------------
Avalanche diode model. The avalanche diode adds an independet degree of control to the reverse B-C voltage that drives the bipolar parasitic device to the ON state upon avalanching. A separate schematic file ("Davalanche_debug.asc") is available for specific model parameter tuning and debugging.

BJTavalanche.txt
-------------------
Basic model of the bipolar parasitic device that drives the neural behaviour. A separate file contains the low level parameters of the model for ease of configuration and debugging.

BJTparams.txt
-------------------
A detailed list of BJT model parameters for ease of edition, including a basic description of each parameter's effect on the avalanche response.

/subcircuit
-------------------
This directory includes symbol and schematic of a floating bulk neuron device (with bulk control transistor) for ease of instantiation into higher level netists. An individual minimal working netlist example that uses an instance of this subcircuit is also given ("SubC_SimpleTest.asc").