function Diff_Moisture_Heat
global ML MN ND NL nD DTheta_LLh Chh Khh Chg C J m n Gama_hh Theta_m
global Theta_L Theta_LL h hh T TT KL_h NN Delt_t RHS SAVE VGm VGn Ts_Min Ts_Max
global C1 C4 C7 DeltZ CTT KTT Lambda_eff c_unsat CHK Theta_r Theta_s Alpha C2 C5 
global KLhBAR KL_T KLTBAR DhDZ DTDZ DTDBAR D_Ta QL QLT QLH QMT QMB VQ KT TQL IBOT
global DLemdDZ DqLDZ DqVDZ DQaDZ SqVDZ LemdaBAR csBAR HC CTT_PH DTheta_LLhBAR LHS hOLD XElemnt C4_a hBOT BOTm HPUNIT
hd=-1e12;hm=-9899;

% IBOT=NN-5;
Q3DF=1;
INBT=NN-IBOT+1;
Thmrlefct=0;
%%%%%%%%%%%%%%%%%
%   Soil Moisture Part
%%%%%%%%%%%%%%%%%
run  Latent
run  CondT_coeff
VGm(J)=m(J);VGn(J)=n(J);
Cpcty_Eqn=1;

% for MN=1:NN
%     if hh(MN)<-1e5
%         hh(MN)=-1e5;
% %     elseif hh(MN)>-1e-6
% %         hh(MN)=-1e-6;
%     end
%     
%     if isnan(hh(MN))        
%         hh(MN)=-200;
%     end
% end         
if any(isnan(hh)) || any(hh(1:NN)<=-1E12)
    for MN=1:NN
        hh(MN)=h(MN);
    end
end
% hPARM_Sub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Cpcty_Eqn==1 
    MN=0;
    for ML=1:NL
        for ND=1:2        
            MN=ML+ND-1;
            if abs(hh(MN))>=abs(hd)
                Gama_hh(MN)=0;
            elseif abs(hh(MN))>=abs(hm)
                Gama_hh(MN)=log(abs(hd)/abs(hh(MN)))/log(abs(hd)/abs(hm));
            else
                Gama_hh(MN)=1;
            end            
%          Theta_m(ML)=Gama_hh(MN)*Theta_r(J)+(Theta_s(J)-Gama_hh(MN)*Theta_r(J))*(1+abs(Alpha(J)*(-2))^n(J))^m(J);  %Theta_UU==>Theta_LL   Theta_LL==>Theta_UU
%                 if Theta_m(ML)>=POR(J)
%                     Theta_m(ML)=POR(J);
%                 elseif Theta_m(ML)<=Theta_s(J)
%                     Theta_m(ML)=Theta_s(J);
%                 end
                 Theta_m(ML)=Theta_s(J);
            if ND==1
                Dth1=(hh(MN)-h(MN))/Delt_t;
            else
                Dth2=(hh(MN)-h(MN))/Delt_t; 
            end
            
            if abs(hh(MN)-h(MN))<1e-6
                if hh(MN)>=-1e-6
                    DTheta_LLh(ML,ND)=0;
                else
                    DTheta_LLh(ML,ND)=(-Theta_r(J))/(abs(hh(MN))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1))*(abs(Alpha(J)*hh(MN))^(n(J)-1));
                end
            elseif ND==2
                DtTheta1=(Theta_LL(ML,1)-Theta_L(ML,1))/Delt_t;
                DtTheta2=(Theta_LL(ML,2)-Theta_L(ML,2))/Delt_t;
                if Cpcty_Eqn==1
                    DTheta_LLh(ML,1)=(DtTheta1*(Dth1+5*Dth2)+DtTheta2*(Dth2-Dth1))*(Dth1^2+4*Dth1*Dth2+Dth2^2)^-1;
                    DTheta_LLh(ML,2)=(DtTheta1*(Dth1-Dth2)+DtTheta2*(5*Dth1+Dth2))*(Dth1^2+4*Dth1*Dth2+Dth2^2)^-1;
                else
                    DTheta_LLh(ML,1)=2*DtTheta1/Dth1-DtTheta2/Dth2;
                    DTheta_LLh(ML,2)=2*DtTheta2/Dth2-DtTheta1/Dth1;
                end
            end
        end
    end
else
    MN=0;
    for ML=1:NL
        for ND=1:2
            MN=ML+ND-1;
            if abs(hh(MN)-h(MN))<1e-3
                DTheta_LLh(ML,ND)=(-Theta_r(J))/(abs(hh(MN))*log(abs(hd/hm)))*(1-(1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)))-Alpha(J)*n(J)*m(J)*(Theta_m(ML)-Gama_hh(MN)*Theta_r(J))*((1+abs(Alpha(J)*hh(MN))^n(J))^(-m(J)-1))*(abs(Alpha(J)*hh(MN))^(n(J)-1));  
%                 DTheta_LLh(ML,ND)=(Theta_s(J)-Theta_r(J))*Alpha(J)*VGn(J)*abs(Alpha(J)*hh(MN))^(VGn(J)-1)*(-VGm(J))*(1+abs(Alpha(J)*hh(MN))^VGn(J))^(-VGm(J)-1);
            else
                DTheta_LLh(ML,ND)=(Theta_LL(ML,ND)-Theta_L(ML,ND))/(hh(MN)-h(MN));
            end
        end
    end
    
    if any(isnan(DTheta_LLh))
       keyboard 
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ML=1:NL              % Clean the space in C1-7 every iteration,otherwise, in *.PARM files, 
    for ND=1:2           % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
        Chh(ML,ND)=0; 
        Khh(ML,ND)=0;
        Chg(ML,ND)=0; 
    end
end

for ML=INBT:NL
    for ND=1:nD        
        Chh(ML,ND)=DTheta_LLh(ML,ND);
        Khh(ML,ND)=KL_h(ML,ND); %
        Chg(ML,ND)=KL_h(ML,ND);
    end   
end     

% hMAT_Sub
for MN=1:NN              % Clean the space in C1-7 every iteration,otherwise, in *.PARM files, 
    for ND=1:2           % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
        C1(MN,ND)=0; 
        C7(MN)=0;
        C4(MN,ND)=0; 
    end
end

for ML=INBT:NL
    C1(ML,1)=C1(ML,1)+Chh(ML,1)*DeltZ(ML)/2;
    C1(ML+1,1)=C1(ML+1,1)+Chh(ML,2)*DeltZ(ML)/2;%

    C4ARG1=(Khh(ML,1)+Khh(ML,2))/(2*DeltZ(ML));%sqrt(Khh(ML,1)*Khh(ML,2))/(DeltZ(ML));%
    C4(ML,1)=C4(ML,1)+C4ARG1;
    C4(ML,2)=C4(ML,2)-C4ARG1;
    C4(ML+1,1)=C4(ML+1,1)+C4ARG1;
    
    C7ARG=(Chg(ML,1)+Chg(ML,2))/2;%sqrt(Chg(ML,1)*Chg(ML,2));%
    C7(ML)=C7(ML)-C7ARG;
    C7(ML+1)=C7(ML+1)+C7ARG;
end

% hEQ_Sub
RHS(INBT)=-C7(INBT)+(C1(INBT,1)*h(INBT)+C1(INBT,2)*h(INBT+1))/Delt_t;
for ML=INBT+1:NL 
    RHS(ML)=-C7(ML)+(C1(ML-1,2)*h(ML-1)+C1(ML,1)*h(ML)+C1(ML,2)*h(ML+1))/Delt_t;
end
RHS(NN)=-C7(NN)+(C1(NN-1,2)*h(NN-1)+C1(NN,1)*h(NN))/Delt_t;
    
for MN=INBT:NN
    for ND=1:2
        C4(MN,ND)=C1(MN,ND)/Delt_t+C4(MN,ND);
    end        
end

SAVE(1,1,1)=RHS(INBT);
SAVE(1,2,1)=C4(INBT,1);
SAVE(1,3,1)=C4(INBT,2);
SAVE(2,1,1)=RHS(NN);
SAVE(2,2,1)=C4(NN-1,2);
SAVE(2,3,1)=C4(NN,1);

run h_BC
Q3DF=1;
INBT=NN-IBOT+1;
BOTMm=BOTm(1,1)*HPUNIT;%BOTm=XElemnt(NN);
if Q3DF
%     if NBChB==1            %-----> Specify matric head at bottom to be ---BChB;
        RHS(INBT)=(hBOT(KT)-BOTMm+XElemnt(IBOT));
        C4(INBT,1)=1;
        RHS(INBT+1)=RHS(INBT+1)-C4(INBT,2)*RHS(INBT);
        C4(INBT,2)=0;
        C4_a(INBT)=0;
end   
RHS(INBT)=RHS(INBT)/C4(INBT,1);

for ML=INBT+1:NN
    C4(ML,1)=C4(ML,1)-C4(ML-1,2)*C4(ML-1,2)/C4(ML-1,1);
    RHS(ML)=(RHS(ML)-C4(ML-1,2)*RHS(ML-1))/C4(ML,1);
end

for ML=NL:-1:INBT
    RHS(ML)=RHS(ML)-C4(ML,2)*RHS(ML+1)/C4(ML,1);
end

if(INBT>1)
    for I=INBT:-1:2
%         hh(I-1)=hh(I)+XElemnt(I)-XElemnt(I-1);
        RHS(I-1)=RHS(I)+XElemnt(NN-I+2)-XElemnt(NN-I+1);
%         M=MATNUM(I);
%         THN(I)=THS(M);
    end
end

for MN=1:NN
    CHK(MN)=0;
end
for MN=INBT:NN
    CHK(MN)=abs(RHS(MN)-hh(MN));
end

for MN=INBT:NN
    hh(MN)=RHS(MN);
end


% % 
% % for MN=1:NN
% %     if hh(MN)<-1e5
% %         hh(MN)=-1e5;
% % %     elseif hh(MN)>-1e-6
% % %         hh(MN)=-1e-6;
% %     end
% %     
% %     if isnan(hh(MN))        
% %         hh(MN)=-200;
% %     end
% % end            
if any(isnan(hh)) || any(hh(1:NN)<=-1E12)
    for MN=1:NN
        hh(MN)=h(MN);
    end
end
run h_Bndry_Flux;
%% calculate QL
for ML=INBT:NL
    KLhBAR(ML)=(KL_h(ML,1)+KL_h(ML,2))/2;
    KLTBAR(ML)=(KL_T(ML,1)+KL_T(ML,2))/2;
    DhDZ(ML)=(hh(ML+1)-hh(ML))/DeltZ(ML);
    %             DhDZ(ML)=(hh(ML+1)+hh_frez(ML+1)-hh(ML)-h_frez(ML))/DeltZ(ML);
    DTDZ(ML)=(TT(ML+1)-TT(ML))/DeltZ(ML);
    DTDBAR(ML)=0;%(D_Ta(ML,1)+D_Ta(ML,2))/2;
    DTheta_LLhBAR(ML)=(DTheta_LLh(ML,1)+DTheta_LLh(ML,2))/2;
end

%%%%%% NOTE: The soil air gas in soil-pore is considered with Xah and XaT terms.(0.0003,volumetric heat capacity)%%%%%%
MN=0;
for ML=INBT:NL
    %             for ND=1:2
    %                 MN=ML+ND-1;
    QL(ML)=-(KLhBAR(ML)*DhDZ(ML)+(KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML)+KLhBAR(ML));
    QLT(ML)=-((KLTBAR(ML)+DTDBAR(ML))*DTDZ(ML));
    QLH(ML)=-(KLhBAR(ML)*DhDZ(ML)+KLhBAR(ML));
    %             end
end
QL(NN)=QMT(KT);
TQL=flip(QL(:,1))*(-86400);
%%
%  %% Modified QL
%  dV=0;
%  SSQ=0;
%  Srt=zeros(NN,1);
%  QL(1)=QMT;
%  TTheta_LL=flip(Theta_LL(:,1));TTheta_LL(1)=Theta_LL(NL,2);
%  TTheta_L=flip(Theta_L(:,1));TTheta_L(1)=Theta_L(NL,2);
%  TDeltZ=flip(DeltZ);
%  for ML=2:NN
%      
% dV=dV+TDeltZ(ML)*(TTheta_LL(ML-1)+TTheta_LL(ML)-TTheta_LL(ML-1)-TTheta_LL(ML))/2; 
% SSQ=SSQ+TDeltZ(ML)*(Srt(ML-1)+Srt(ML))/2;
% VQ(ML)= QMT(KT)-dV/Delt_t-SS;
% 
%  end
 %%
%%%%%%%%%%%%%%%%%%
% Heat Transport Part
%%%%%%%%%%%%%%%%%%
if Thmrlefct==1
for MN=1:NN
    if TT(MN)<=Ts_Min  %0  %
        TT(MN)=Ts_Min; %  0; %    
    elseif TT(MN)>=Ts_Max
        TT(MN)=Ts_Max;
    end
end
% EnrgyPARM Sub

MN=0;
for ML=1:NL
    for ND=1:2
        MN=ML+ND-1;
        CTT(ML,ND)=c_unsat(ML,ND);                      
        KTT(ML,ND)=Lambda_eff(ML,ND);             
    end
end

if any(imag(TT))
    keyboard
end


% EnrgyMAT Sub
for MN=1:NN              % Clean the space in C1-7 every iteration,otherwise, in *.PARM files, 
    for ND=1:2           % C1-7 will be mixed up with pre-storaged data, which will cause extremly crazy for computation, which exactly results in NAN.
        C2(MN,ND)=0;          
        C5(MN,ND)=0;       
    end
end

for ML=1:NL   
    C2(ML,1)=C2(ML,1)+CTT(ML,1)*DeltZ(ML)/2;
    C2(ML+1,1)=C2(ML+1,1)+CTT(ML,2)*DeltZ(ML)/2;
    
    C5ARG1=(KTT(ML,1)+KTT(ML,2))/(2*DeltZ(ML)); %sqrt(KTT(ML,1)*KTT(ML,2))/(DeltZ(ML));%
    C5(ML,1)=C5(ML,1)+C5ARG1;
    C5(ML,2)=C5(ML,2)-C5ARG1;
    C5(ML+1,1)=C5(ML+1,1)+C5ARG1;   
end

% EnrgyEQ_Sub
RHS(1)=(C2(1,1)*T(1)+C2(1,2)*T(2))/Delt_t;
for ML=2:NL
    RHS(ML)=(C2(ML-1,2)*T(ML-1)+C2(ML,1)*T(ML)+C2(ML,2)*T(ML+1))/Delt_t;
end   
RHS(NN)=(C2(NN-1,2)*T(NN-1)+C2(NN,1)*T(NN))/Delt_t;

for MN=1:NN
    for ND=1:2
        C5(MN,ND)=C2(MN,ND)/Delt_t+C5(MN,ND);
    end
end

SAVE(1,1,2)=RHS(1);
SAVE(1,2,2)=C5(1,1);
SAVE(1,3,2)=C5(1,2);
SAVE(2,1,2)=RHS(NN);
SAVE(2,2,2)=C5(NN-1,2);
SAVE(2,3,2)=C5(NN,1);

run Enrgy_BC;

RHS(1)=RHS(1)/C5(1,1);
for ML=2:NN
    C5(ML,1)=C5(ML,1)-C5(ML-1,2)*C5(ML-1,2)/C5(ML-1,1);
    RHS(ML)=(RHS(ML)-C5(ML-1,2)*RHS(ML-1))/C5(ML,1);
end
for ML=NL:-1:1
    RHS(ML)=RHS(ML)-C5(ML,2)*RHS(ML+1)/C5(ML,1);
end


for MN=1:NN
    CHK(MN)=abs(RHS(MN)-TT(MN));
    TT(MN)=RHS(MN);
end

if any(imag(TT)) || any(isnan(TT))
    keyboard
end

for MN=1:NN
    if TT(MN)<=Ts_Min  %0 %
        TT(MN)=Ts_Min;  %0; %        
    elseif TT(MN)>=Ts_Max
        TT(MN)=Ts_Max;
    end
end
run Enrgy_Bndry_Flux;
end
end