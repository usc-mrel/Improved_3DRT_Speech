# Improved_3DRT_Speech
 
 Code and data for generating reconstruction results for the original and proposed 3D methods in this paper: *Ziwei Zhao, Yongwan Lim, Dani Byrd, Shrikanth Narayanan, Krishna S. Nayak. "Improved 3D Real-Time MRI of Speech Production"*. Submitted to Mag. Reson. Med.
 
 ## Set up
 
 ### BART Installation
 
 To run this code, successfully installation of BART reconstruction toolbox is required. This code uses BART version of 0.4.03. 
 - You can download the specific version here:  https://github.com/mrirecon/bart/releases/tag/v0.4.03.
 - The installation details can be found here:  https://github.com/mrirecon/bart-workshop/blob/master/doc/quick-install.md.
 - For more information about BART, please visit: https://mrirecon.github.io/bart/.
 
 ### Initialization
 
 - Please edit the path of this package in **main_recon_3d.m** line 19-20.
 - Please change the local path of BART in **recon_sos_3d.m** line 45.
 
 
 ## Code Structure
 
 ### Demo script: 
- **main_recon_3d.m** Reconstruction script to perform the proposed constrained reconstruction. The script generates reconstructed dynamic 3D volumes and saves reconstructions in a .mat file and an .avi file in the ‘results’ folder. 
 
 ### Datasets: 
- **lac10132019_19_21_07.mat** Original sampling method using spiral arms with constant increments in the kx-ky plane with a linear temporal order along kz.
- **lac10132019_19_06_16.mat** Proposed sampling method using rotated spiral arms with a golden angle increment in the kx-ky with a variable density randomized temporal order along kz.

### Functions: 
- **recon_sos_3d.m** performs reconstruction for 3D stack-of-spirals sampling based on compressed sensing and parallel imaging with spatio-temporal Total Variation (TV) constraints.
- **display4Dimages.m** generates reconstructed videos in parallel sagittal views. 
- **generatewindows.m** generates a 2D or 3D Hanning window.
- **generatevideos.m** generates an avi movie from image series. 
- **save3Ddynamicimages.m** converts 3D image series to concatenated display of 2D image series. 
- **save3Dstaticimages.m** converts 3D static images to concatenated display of 2D static images. 

 ## Citing
 Zhao Z, Lim Y, Byrd D, Narayanan S, Nayak KS. Improved 3D real-time MRI of speech production. Magn Reson Med. 2020;00:1–15. https://doi.org/10.1002/mrm.28651
 
 ## License
 The Improved_3DRT_Speech packaged code is licensed under a 3-Clause BSD License.

 ## Contact
If you have any questions, please contact ziweiz@usc.edu

 Ziwei Zhao, University of Southern California, MREL (Magnetic Resonance Engineering Laboratory, PI: Krishna S. Nayak, https://mrel.usc.edu/) June 2020.
