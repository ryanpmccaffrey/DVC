# Digital Volume Correlation
This Digital Volume Correlation (DVC) MATLAB code was developed as part of a research project I worked on in 2010-2011.  The underlying goal of the project was to investigate the three-dimensional mechanical behavior of periodically-porous microcellular solids. We wanted to understand how unit cell level deformations impacted the macroscopic material response of the system (e.g., changes material properties).  To this end, we used laser scanning confocal microscopy (LSCM) to image our samples under incrementally deformed sequential loading states, and then correlated these deformed states using DVC.  

Long story short, this DVC code can be used on numerous different types of volumetric image datasets, with the sole purpose of mapping vector displacements from one volumetric image to the next (i.e., answering the question: how are things moving in 3D?).  The program does not care how the images were acquired, just that they are high resolution TIFF images. In our case we used LSCM to acquire the images, but the DVC code could just as easily be applied to volumetric images acquired via X-ray or magnetic resonance imaging (MRI).  

DVC_Overview.pdf presents an overview of the theory of how the DVC algorithm works.  
DVC_File_Descriptions.pdf provides a more detailed description of the different functions used in the DVC code.  
DVC_Guide.pdf provides users with a practical guide to running the code, walking through the software and post-processing results.
