# Improved_3DRT_Speech
 
 Code and data for generating reconstruction results for the original and proposed 3D methods in this paper: *Ziwei Zhao, Yongwan Lim, Dani Byrd, Shrikanth Narayanan, Krishna S. Nayak. "Improved 3D Real-Time MRI of Speech Production"*.
 
 To run this code, successfully installation of BART reconstruction toolbox is required. This code uses BART version of 0.4.03.
 The installation guideline can be found here:  https://mrirecon.github.io/bart/.
 
 ## Code Structure
 
 ### Demo scripts: 
- **main_recon_3d.m** Reconstruction script to perform the proposed constrained reconstruction. The script generates reconstructed dynamic 3D volume imaging saved  as .mat file and corresponding movies (.avi file) in the ‘results’ folder. 
 
 ### Dataset: 
- **lac10132019_19_21_07.mat** Original sampling method using constant spiral angle in the kx-ky plane with linear temporal order alone kz.
- **lac10132019_19_06_16.mat** Proposed sampling method using rotated golden angle increment in the kx-ky with variable density random temporal order along kz.

### Functions: 
- **recon3dsos_3d.m** performs 3D stack-of-spirals sampling based on compressed sensing and parallel imaging with spatio-temporal Total Variation (TV) constraints.
- **f_generate_window.m** generates 2 or 3 dimensional Hanning window.
- **f_disp4D.m** generates reconstructed videos in parallel sagittal views. 
- **f_genV.m** generates .avi movie from image series. 
- **f_save_3d_dynamic_img.m** converts 3-dimensional image series to concatenated display of 2-dimensional image series. 
- **f_save_3d_static_img.m** converts 3-dimensional static images to concatenated display of 2-dimensional static images. 


If you have any questions, please contact ziweiz@usc.edu

 Ziwei Zhao, University of Southern California, MREL (Magnetic Resonance Engineering Laboratory, PI: Krishna S. Nayak, https://mrel.usc.edu/) June 2020.
