function [  ] = process_IVIM( tmp_dir, sz_ivim, IVIM_tmp, full_vol_ivim, aal_val, IVIM_WM_roi  )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% for DWI

cd (tmp_dir);
im_vec=reshape(IVIM_tmp,1,sz_ivim(1)*sz_ivim(2)*sz_ivim(3));

%% Crea carpeta para guardar GRAY MATTER ROI
Groi_dir=strcat(tmp_dir, '/ROI_GRAYMATTER_IVIM');
mkdir(Groi_dir);
cd(Groi_dir);

%% from atlas to GRAY MATTER ROI 

for q=1: length(aal_val)
    mask=zeros(1,length(im_vec));
    ind=find(im_vec==aal_val(q));% using atlas index
    
    for l=1:1:length(ind)
        mask(ind(l))=1;
    end
    
    % saving mask
    
    name_roi=strcat('roi_', num2str(q));
    save(name_roi,'mask');
    mask=reshape(mask,sz_ivim(1),sz_ivim(2),sz_ivim(3));
    
    %TO get ROI on anat (anat * ROI)
    ind=1;
    
    for l=1:sz_ivim(2):length(full_vol_ivim)
        mask_ra=full_vol_ivim(l:l+(sz_ivim(2)-1),:,:).*mask;
        tmp_mask=reshape(mask_ra,1,sz_ivim(1)*sz_ivim(2)*sz_ivim(3));
        [x,y]=find(tmp_mask>0);
        Int_val(q,ind)=sum(tmp_mask)/length(x);
        ind=ind+1;
    end
    
end

% Gray matter input for IVIM adjust

%Int_val=Int_val(:,2:end);% primera columna b=0 se omite
cd (Groi_dir);
save ('bval_GMROI.mat','Int_val')

cd (tmp_dir);

%% TAKING ROIS FROM WHITE MATTER INFO


Wroi_dir=strcat(tmp_dir, '/ROI_WHITEMATTER_IVIM');
mkdir(Wroi_dir);
cd(Wroi_dir);

bw_maskLeft=zeros(sz_ivim(1),sz_ivim(2),sz_ivim(3));
bw_maskRight=zeros(sz_ivim(1),sz_ivim(2),sz_ivim(3));

%% left matter mask
for q=1:1:(sz_ivim(2)/2)
    bw_maskLeft(q,:,:)=1;
    bw_maskRight(256-q,:,:)=1;
end

%% find region & create & save WHITE MATTER ROI

bw_maskLeft=bw_maskLeft.*IVIM_WM_roi;
bw_maskRight=bw_maskRight.*IVIM_WM_roi;


%% To get ROI on anat (DWI * WHITE MATTER ROI)

ind=1;

for q=1:sz_ivim(2):length(full_vol_ivim)
    mask_ra=full_vol_ivim(q:q+(sz_ivim(2)-1),:,:).*bw_maskLeft;
    wLefttmp_mask=reshape(mask_ra,1,sz_ivim(1)*sz_ivim(2)*sz_ivim(3));
    [x,y]=find(wLefttmp_mask>0);
    Int_LeWMval(1,ind)=sum(wLefttmp_mask)/length(x);
    ind=ind+1;
end

ind=1;

for q=1:sz_ivim(2):length(full_vol_ivim)
    mask_ra=full_vol_ivim(q:q+(sz_ivim(2)-1),:,:).*bw_maskRight;
    wRighttmp_mask=reshape(mask_ra,1,sz_ivim(1)*sz_ivim(2)*sz_ivim(3));
    [x,y]=find(wRighttmp_mask>0);
    Int_RiWMval(1,ind)=sum(wRighttmp_mask)/length(x);
    ind=ind+1;
end

%Int_LeWMval=Int_LeWMval(:,2:end);
%Int_RiWMval=Int_RiWMval(:,2:end);

cd(Wroi_dir)

save( 'roi_wmLeft.mat','bw_maskLeft');
save( 'roi_wmRight.mat','bw_maskRight');
save ('bval_WMleftROI.mat','Int_LeWMval');
save ('bval_WMrightROI.mat','Int_RiWMval');

cd(tmp_dir);
result_dir=strcat(tmp_dir, '/RESULTS_IVIM');
mkdir(result_dir);
cd(result_dir);

%% getting IVIM

for i=1:3
    
    curve_adjust(Int_val,Int_LeWMval, Int_RiWMval, i);
    
end

end
