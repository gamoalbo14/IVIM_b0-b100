function curve_adjust( Int_val, Int_LeWMval, Int_RiWMval,ind )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% procIVIM.m
% process IVIM data in DICOM format
%
% calls:
%       . workononeslice.m  : para seleccionar solo un corte sobre el cual
%       trabajar
%       . difffitmonoexp.m
%       . difffitbiexp.m
%
% created by: Steren Chabert, Jorge Verdu
% october 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load images

%% initiate parameters

    if ind==1
        values=Int_val;
    end
    
    if ind==2
        values=Int_LeWMval;
    end
    
    if ind==3
        values=Int_RiWMval;
    end
    
    %este parametro es especifico del trabajo de Jorge Verdu: comparacion entre
    %dos tipos de distribuciones de valores de b
    %optimum distr
    
    b=[0, 10, 40, 50, 60, 150, 160, 170, 190, 200, 260, 440, 560, 600, 700, 980, 1000];
    
    w=waitbar(0,'Espere, por favor');
    
    for i=1: size(values,1)
        %% fit
        % Primer paso del ajuste: solo D, para b > 200
        dataADC=zeros(2,9);
        dataADC(1,:)=values(i,9:end);
        dataADC(2,:)=b(9:end);
        %Inicializaci?n de valores y l?mites
        x=[0 0 0 0];
        X0(1)= values(i,1);
        X0(2)=0.8e-3;
        Xmin(1)=0; Xmin(2)=0;
        Xmax(1)=1000; Xmax(2)=100;
        
        %  ajuste de curva
        options.Algorithm='levenberg-marquardt';
        options.TolX = 1e-6;
        options.Display='final';
        options.MaxIter=300;
        options=optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt','MaxFunEvals',1500,'Display','Off');
        [d, resnorm1, residual1, exitflag1, output1]=lsqnonlin('difffitmonoexp', X0, Xmin, Xmax, options, dataADC);
        
        % funcion
        adj = d(1)*exp( -dataADC(2,:).*d(2) );
        
        % segundo paso: D conocido por el paso anterior, ahora ajusta D*, f
        % y un factor de escala
        %Inicializaci?n de valors y l?mites
        datadiff=zeros(2,17);
        datadiff(1,:)=values(i,:);
        datadiff(2,:)=b;
        x0(1) = d(1);
        x0(2) = 0.1;
        x0(3)= 8e-3;    %mm2/s
        xmin(1) = 0; xmin(2)=0; xmin(3)=0;
        xmax(1) = 2000; xmax(2) = 1; xmax(3)=x0(3)*20;
        
        %  nonlinear least-squares curve fitting
        options.Algorithm='levenberg-marquardt';
        options.TolX = 1e-6;
        options.Display='final';
        options.MaxIter=300;
        options=optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt','MaxFunEvals',1500);
        [x, resnorm2, residual2, exitflag2, output2]=lsqnonlin('difffitbiexp', x0, xmin, xmax, options, datadiff,d);
        
        
        x(4)=d(2);
        % Multiplicamos las variables
        x(2)=x(2)*100;%f
        x(3)=x(3)*1000;%D*
        x(4)=x(4)*1000;%D o ADC
        
        % funcion
        adjustedcurve =  x(1) * ( ...
            x(2)*exp( -datadiff(2,:).*x(3) )  + ...
            (1-x(2))*exp( -datadiff(2,:).*d(2) )) ;
        
        DATA(i,:)=x;
        
        % Calulo ADC
        
        ADC(i,:)=log(values(i,1)/values(i,end))/(b(end)-b(1));
        
        
        if ind==1
            save ('IVIM_GM','DATA');
            xlswrite('IVIM_GM.xlsx', DATA)
            save ('IVIMB0B1000_GM','ADC')
            xlswrite('IVIMB0B1000_GM.xlsx', ADC)
            
        end
        
        if ind==2
            save ('IVIM_WMLe', 'DATA');
            xlswrite('IVIM_WMLe.xlsx', DATA)
            save ('IVIMB0B1000_WMLe','ADC')
            xlswrite('IVIM0B1000_WMLe.xlsx', ADC)
            clear DATA
        end
        
        if ind==3
            save ('IVIM_WMRi', 'DATA');
            xlswrite('IVIM_WMRi.xlsx', DATA)
            save ('IVIMB0B1000_WMRi','ADC')
            xlswrite('IVIMB0B1000_WMRi.xlsx', ADC)
            clear DATA
        end
        
        
        
    end
    
    close(w);
end


