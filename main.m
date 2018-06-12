%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Autor: Gamaliel Huerta
%main: 
%* Se debe ejecutar sobre la carpeta m?s superficial de la estructura
%* Realiza los bucles necesarios para navegar sobre la estructura de carpeta
%* carga los archivos en formato *.nii: DWI, IVIM, WM ROI y atlas (GM ROI)
% inicia la ejecuci?n de las funciones para obtenci?n de valores IVIM y ADC



clc, clear
% getting main directories

root= pwd;
tmp=dir();
load ('aal_val.mat');



for i=4: (length(tmp)-1) % loop de sujetos
    tmp_dir= [root, '/', tmp(i).name];
    %
    cd (tmp_dir); % go down one directory level
    tmp2=dir;
    
    for j=4: length(tmp2)
        tmp_subdir= [tmp_dir, '/', tmp2(j).name];
        
        %% LOADING IMAGES
        %% for DWI images
        
        if j==6
            cd(tmp_subdir);
            tmp3= dir('*.nii');
            dwi_dir= nifti(tmp3(1).name);
            dwi_dir=double(dwi_dir.dat);
            
            % Mascara de zeros
            sz_dwi=size(dwi_dir);
            full_vol_dwi=zeros(sz_dwi(1),sz_dwi(2),sz_dwi(3));
            
            for k=1: length(tmp3)
                dwi_dir= nifti(tmp3(k).name);
                dwi_dir=double(dwi_dir.dat);
                if k==1
                    full_vol_dwi=dwi_dir;
                else 
                    full_vol_dwi=cat(1,full_vol_dwi,dwi_dir);
                end
                
            end
            
        end
        
        %% for IVIM images
        
        if j==7
            cd(tmp_subdir);
            tmp3= dir('*.nii');
            ivim_dir= nifti(tmp3(1).name);
            ivim_dir=double(ivim_dir.dat);
            
            % Mascara de zeros
            sz_ivim=size(ivim_dir);
            full_vol_ivim=zeros(sz_ivim(1),sz_ivim(2),sz_ivim(3));
            
            for k=1: length(tmp3)
                ivim_dir= nifti(tmp3(k).name);
                ivim_dir=double(ivim_dir.dat);
                if k==1
                    full_vol_ivim=ivim_dir;
                else
                    full_vol_ivim=cat(1,full_vol_ivim,ivim_dir);
                end
            end
            
        end
        
        %% loading corregister Difussion values for DWI  & IVIM
        
        if j==8
            cd(tmp_subdir);
            tmp3= dir('*.nii');
            % dwi
            DWI_tmp=nifti(tmp3(1).name);
            DWI_tmp=double(DWI_tmp.dat);
            % ivim
            IVIM_tmp=nifti(tmp3(2).name);
            IVIM_tmp=double(IVIM_tmp.dat);
            
        end
        
                %% loading WM ROI files (c2....nii)
        if j== 9
            cd(tmp_subdir);
            tmp3= dir('*.nii');
            %dwi
            DWI_WM_roi=nifti(tmp3(1).name);
            DWI_WM_roi=double(DWI_WM_roi.dat);
            %ivim
            IVIM_WM_roi=nifti(tmp3(2).name);
            IVIM_WM_roi=double(IVIM_WM_roi.dat);
            
        end
        
    end
    
    process_DWI( tmp_dir, sz_dwi, DWI_tmp, full_vol_dwi, aal_val, DWI_WM_roi );
    process_IVIM(tmp_dir, sz_ivim, IVIM_tmp, full_vol_ivim, aal_val, IVIM_WM_roi);

    clear full_vol_dwi, clear full_vol_ivim, clear DWI_WM_ROI, clear IVIM_WM_roi;
    
    
end