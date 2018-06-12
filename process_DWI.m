function [  ] = process_DWI( tmp_dir, sz_dwi, DWI_tmp, full_vol_dwi, aal_val, DWI_WM_roi  )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% for DWI

cd (tmp_dir);
im_vec=reshape(DWI_tmp,1,sz_dwi(1)*sz_dwi(2)*sz_dwi(3));

%% Crea carpeta para guardar GRAY MATTER ROI
Groi_dir=strcat(tmp_dir, '/ROI_GRAYMATTER_DWI');
mkdir(Groi_dir);
cd(Groi_dir);

%% find region & create & save GRAY MATTER ROI

for q=1: length(aal_val)
    mask=zeros(1,length(im_vec));
    ind=find(im_vec==aal_val(q));
    
    for l=1:1:length(ind)
        mask(ind(l))=1;
    end
    
    % saving mask
    
    name_roi=strcat('roi_', num2str(q));
    save(name_roi,'mask');
    mask=reshape(mask,sz_dwi(1),sz_dwi(2),sz_dwi(3));
    
    %% TO get ROI on anat (anat * ROI)
    ind=1;
    
    for l=1:sz_dwi(2):length(full_vol_dwi)
        mask_ra=full_vol_dwi(l:l+255,:,:).*mask;
        tmp_mask=reshape(mask_ra,1,sz_dwi(1)*sz_dwi(2)*sz_dwi(3));
        [x,y]=find(tmp_mask>0);
        Int_val(q,ind)=sum(tmp_mask)/length(x);
        ind=ind+1;
    end
    
end


%Int_val=Int_val(:,2:end);
cd (Groi_dir);
save ('bval_GMROI.mat','Int_val')

cd (tmp_dir);

%% TAKING ROIS FROM WHITE MATTER INFO


Wroi_dir=strcat(tmp_dir, '/ROI_WHITEMATTER_DWI');
mkdir(Wroi_dir);
cd(Wroi_dir);

bw_maskLeft=zeros(sz_dwi(1),sz_dwi(2),sz_dwi(3));
bw_maskRight=zeros(sz_dwi(1),sz_dwi(2),sz_dwi(3));

%% left matter mask
for q=1:1:(sz_dwi(2)/2)
    bw_maskLeft(q,:,:)=1;
    bw_maskRight(256-q,:,:)=1;
end

%% find region & create & save WHITE MATTER ROI

bw_maskLeft=bw_maskLeft.*DWI_WM_roi;
bw_maskRight=bw_maskRight.*DWI_WM_roi;


%% To get ROI on anat (DWI * WHITE MATTER ROI)

ind=1;

for q=1:sz_dwi(2):length(full_vol_dwi)
    mask_ra=full_vol_dwi(q:q+255,:,:).*bw_maskLeft;
    wLefttmp_mask=reshape(mask_ra,1,sz_dwi(1)*sz_dwi(2)*sz_dwi(3));
    [x,y]=find(wLefttmp_mask>0);
    Int_LeWMval(1,ind)=sum(wLefttmp_mask)/length(x);
    ind=ind+1;
end

ind=1;

for q=1:sz_dwi(2):length(full_vol_dwi)
    mask_ra=full_vol_dwi(q:q+255,:,:).*bw_maskRight;
    wRighttmp_mask=reshape(mask_ra,1,sz_dwi(1)*sz_dwi(2)*sz_dwi(3));
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
result_dir=strcat(tmp_dir, '/RESULTS_DWI');
mkdir(result_dir);
cd(result_dir);

%%getting ADC for WM

ADC_WMLe=get_ADC(Int_LeWMval);
ADC_WMRi=get_ADC(Int_RiWMval);

save ('ADC_WMLe','ADC_WMLe');
xlswrite('ADC_WMLe.xlsx', ADC_WMLe);
save ('ADC_WMRi', 'ADC_WMRi');
xlswrite('ADC_WMRi.xlsx', ADC_WMRi);

%%getting ADC for GM

ADC_GM=get_ADC(Int_val);

save('ADC_GM','ADC_GM');
xlswrite('ADC_GM.xlsx', ADC_GM)
cd (tmp_dir);



end

