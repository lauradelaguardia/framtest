
% preapre the matrix to use for clustering analysis. 

% climatorlgy of 5-daily integrated npp (z integral full depth) 
% 
%for k-cluster matrix must be row = pixel column = drivers
% drivers will be the sesaonl cycle of npp 

CF='ANHA4'; 
EXP = 'EPM017';
YS=1979; YE=2012;

nLev=1:50;subNZ=length(nLev);

saveP='/project/6007519/castrode/matscripts/NORWAY/matdata/';
dataP = '/project/6007519/pmyers/ANHA4/ANHA4-EPM017-S/';
CFEXP=[CF,'-',EXP];

meshzgr = '/project/6007519/castrode/matscripts/ANHA4_mesh_zgr.nc';
addpath(['/project/6007519/castrode/matscripts/'])
% load polygon and find ij within polygon 
load([saveP,'BSpolygon_fromtopazbio.mat'])


depth=GetNcVar(meshzgr,'gdept_0');

% mesh and mask files [z x and y cell-dimiensions]
ttmask=GetNcVar(meshzgr,'tmask'); % [50,800,544]

% load z- disntance - height of cells
e3t=getE3t(meshzgr); % [50,800,544]
e3t=e3t.*ttmask;
% load x-distance - length of cells
e1t=squeeze(GetNcVar(meshzgr,'e1t'));% [800,544]
% load y-distance - width of cells
e2t=squeeze(GetNcVar(meshzgr,'e2t'));% [800,544]
% reshape e1t and e3t to have a z level
e1t3D=reshape(e1t,[1,size(e1t)]);
e2t3D=reshape(e2t,[1,size(e2t)]);
for zd=1:size(e3t,1)
    e1t3D(zd,:,:)=e1t;
    e2t3D(zd,:,:)=e2t;
end
clear e1t e2t
e1t=e1t3D.*ttmask;
e2t=e2t3D.*ttmask;
clear e1t3D e2t3D

cellVOLUME=e1t.*e2t.*e3t;


for ny=YS:YE
        time=0;
        count=0;
        if ny==YS
            m0=MS;
        else
            m0=1;
        end
        if ny==YE
            m1=ME;
        else
            m1=12;
        end
        yystr=num2str(ny,'%04d');
        %yystr=num2str(1974,'%04d');
        for nmon=m0:m1
            [mmstr,ddstr]=getyymmdd(nmon);

          for nd=1:size(mmstr,1)
                time=1+time;
                timeTag=['_y',yystr,'m',mmstr(nd,:),'d',ddstr(nd,:)];
                tfile=[dataP,CFEXP,timeTag,'_gridT.nc'];
                bfile=[dataP,CFEXP,timeTag,'_gridB.nc'];

                %load variables
                   tempvar=GetNcVar(bfile,'jp_uptatke',[xi,yi,zi,ti],[xcount,ycount,zcount,tcount]);
                % integral 100m 
		jpuptake(time,:,:) = squeeze(nansum(jpuptake,1).*e3t);% molC/m2
                

            end % end loop days
        end % end loop month

        ny
         save([saveP,CFEXP,'_',varname,'_5daymeans_y',num2str(ny),'_',savename],'maskfilename' ,'basinNames','Basins_wmeanZ_jpuptake','Basins_integralZ_jpuptake')
    end %end loop year

% do nco for the climatology
