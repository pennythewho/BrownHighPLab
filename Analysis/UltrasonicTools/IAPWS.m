function [rho,H,S,Cv,Cp,alpha,vel,E,G,gamma]=IAPWS(P,T)
%function [rho,H,S,Cv,Cp,alpha,vel,E,G,gamma]=IAPWS(P,T)
% P in GPa, T in K
% output rho (gm/cc), Cv,Cp in J/kg/K  E, Gin kJ-kg units, vel in km/s
% E Abramson and J M Brown 2000

eos=IAPWSparms;

EOS=eos;
Ptrial=P;
Ttrial=T;
Tc=373+12.45*P*1000;
 if (T>Tc && P<.025),
     rho_guess=.005;
 elseif (T>640 && T<720 && P>.025 && P<.05)
     rho_guess=.2;
 elseif P>=.1,
     rho_guess=1.2;
 else
     rho_guess=1;
 end

rho=fzero(@(rho) (Ptrial-multparmEOS(EOS,rho,Ttrial)),rho_guess,optimset('disp','off'));

% failure if starting density is liquid for 'gas" regime - try again with
% "gas' density
if isnan(rho),
    rho_guess=.005;
    rho=fzero(@(rho) (Ptrial-multparmEOS(EOS,rho,Ttrial)),rho_guess,optimset('disp','off'));
end

[P,H,S,Cv,Cp,alpha,vel,E,G,gamma]=multparmEOS(eos,rho,T);

function eos=IAPWSparms()
% set up the parameters for IAPWS

n=[ 12533547935523e-1
	 78957634722828e1
	-87803203303561e1
	 31802509345418
	-26145533859358
	-78199751687981e-2
	 88089493102134e-2
	-66856572307965
	 20433810950965
	-66212605039687e-4
	-19232721156002
	-25709043003438
	 16074868486251
	-40092828925807e-1
	 39343422603254e-6
	-75941377088144e-5
	 56250979351888e-3
	-15608652257135e-4
	 11537996422951e-8
	 36582165144204e-6
	-13251180074668e-11
	-62639586912454e-9
	-10793600908932
	 17611491008752e-1
	 22132295167546
	-40247669763528
	 58083399985759
	 49969146990806e-2
	-31358700712549e-1
	-74315929710341
	 47807329915480
	 20527940895948e-1
	-13636435110343
	 14180634400617e-1
	 83326504880713e-2
	-29052336009585e-1
	 38615085574206e-1
	-20393486513704e-1
	-16554050063734e-2
	 19955571979541e-2
	 15870308324157e-3
	-16388568342530e-4
	 43613615723811e-1
	 34994005463765e-1
	-76788197844621e-1
	 22446277332006e-1
	-62689710414685e-4
	-55711118565645e-9
	-19905718354408
	 31777497330738
	-11841182425981];
n=n*1e-14;

c=zeros(51,1);
c(8:22)=1;
c(23:42)=2;
c(43:46)=3;
c(47)=4;
c(48:51)=6;

g=zeros(51,1);
g(8:51)=1;

d=[1 1 1 2 2 3 4 1 1 1 2 2 3 4 4 5 7 9 10 11 13 15 1 2 2 2 3 4 4 4 5 6 6 7 9 9 9 9 9 10 10 12 3 4 4 5 14 3 6 6 6 3 3 3]';
t=[-0.5 0.875 1 0.5 0.75 0.375 1 4 6 12 1 5 4 2 13 9 3 4 11 4 13 1 7 1 9 10 10 3 7 10 10 6 10 10 1 2 3 4 8 6 9 8 16 22 23 23 10 50 44 46 50 0 1 4]';

parms=[n(1:51) d(1:51) t(1:51) g c];

% ideal gas components:
n0=[-8.32044648201 6.6832105268 3.00632 0.012436 0.97315 1.27950 0.96956 0.24873]';
gamma0=[nan nan nan 1.28728967 3.53734222 7.74073708 9.24437796 27.5075105]';
p0=[n0 gamma0];

%R=0.46151805*1e3; %J/Kg/K
%R=8.314472;
CPvalues=[647.096 322];
MW=18.015;

eos.parm_ideal=p0;
eos.parm_resid=parms;
eos.CPvalues=CPvalues;
eos.MW=MW;
eos.parms_extra=[];

eos.NAparm.n=[	-.31306260323435e2
	             .31546140237781e2
	            -.25213154341695e4
	            -.14874640856724
	             .31806110878444];
    
    eos.NAparm.d=[3 3 3 0 0]';
    eos.NAparm.t=[0 1 4 0 0]';
    eos.NAparm.alpha=[20 20 20 0 0]';
    eos.NAparm.beta=[150 150 250 0 0]';
    eos.NAparm.gamma=[1.21 1.21 1.25 0 0]';
    eos.NAparm.epsil=[1 1 1 0 0]';
    eos.NAparm.al=[3.5 3.5]';
    eos.NAparm.bl=[.85 .95]';
    eos.NAparm.Bl=[.2 .2]';
    eos.NAparm.Cl=[28 32]';
    eos.NAparm.Dl=[700 800]';
    eos.NAparm.Al=[.32 .32]';
    eos.NAparm.betal=[.3 .3]';
    
function [phi_0,phi0_d,phi0_dd,phi0_t, phi0_tt,phi0_dt]=ideal_phi(parms,del,tau)

n0=parms(:,1);
gamma0=parms(:,2);
id=4:8;

phi_0=log(del)+n0(1)+n0(2)*tau+n0(3)*log(tau)+sum(n0(id).*log(1-exp(-gamma0(id)*tau)));
phi0_t=n0(2) + n0(3)./tau + sum(n0(id).*gamma0(id).*( (1-exp(-gamma0(id)*tau)).^(-1) -1) );
phi0_tt=-n0(3)./tau.^2 - sum(n0(id).*gamma0(id).^2.*exp(-gamma0(id)*tau).*(1-exp(-gamma0(id)*tau)).^(-2));
phi0_d=del.^(-1);
phi0_dd=-del.^(-2);
phi0_dt=0;   

function [phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt]=NA_phi(parms,del,tau)
n=parms.n;
d=parms.d;
t=parms.t;
alpha=parms.alpha;
beta=parms.beta;
gamma=parms.gamma;
epsil=parms.epsil;
al=parms.al;
bl=parms.bl;
Bl=parms.Bl;
Cl=parms.Cl;
Dl=parms.Dl;
Al=parms.Al;
betal=parms.betal;

nd=length(del);
phi=zeros(nd,1);phi_d=phi;phi_dd=phi;phi_t=phi;phi_tt=phi;phi_dt=phi;

for i=1:nd,
    S=exp( -Cl*(del(i)-1).^2-Dl*(tau(i)-1).^2 ) ; %phi  S
    T=(1-tau(i))+Al'.*((del(i)-1)^2).^(0.5/betal);
    T=T';      %theta   T
    D=T.^2 + Bl.*((del(i)-1).^2).^al;	%Delta (upper case)  D

    %derivatives of phi
    Sd=-2*Cl*(del(i)-1).*S;
    Sdd=(2*Cl*(del(i)-1).^2-1)*2.*Cl.*S;  
    St=-2*Dl*(tau(i)-1).*S;
    Stt=(2*Dl*(tau(i)-1)^2-1)*2.*Dl.*S;
    Sdt=4*Cl.*Dl*(del(i)-1)*(tau(i)-1).*S;

    %derivatives of Delta
    Dd=(del(i)-1)*( Al.*T*2./betal.*((del(i)-1)^2).^(0.5/betal-1)' + 2*Bl.*al.*((del(i)-1)^2).^(al-1) );
    Ddd=Dd/(del(i)-1) + (del(i)-1)^2*( 4*Bl.*al.*(al-1).*((del(i)-1)^2).^(al-2) + 2*Al.^2./betal.^2.*(((del(i)-1)^2).^(.5/betal-1)'.^2 + Al.*T./betal*4.*(1./betal/2-1).*((del(i)-1)^2).^(.5/betal-2)') );

    %derivatives of Delta^bi
    Dbd=bl.*D.^(bl-1).*Dd;
    Dbdd=bl.*(D.^(bl-1).*Ddd + (bl-1).*D.^(bl-2).*Dd.^2);
    Dbt=-2*T.*bl.*D.^(bl-1);
    Dbtt=2*bl.*D.^(bl-1) + 4*T.^2.*bl.*(bl-1).*D.^(bl-2);
    Dbdt=-Al.*bl*2./betal.*D.^(bl-1).*(del(i)-1).*((del(i)-1)^2).^(.5/betal-1)' - 2*T.*bl.*(bl-1).*D.^(bl-2).*Dd;

    % phi
    id=1:3;
    phi(i)=sum( n(id).*del.^d(id).*tau.^t(id).*exp(-alpha(id).*(del-epsil(id)).^2-beta(id).*(tau-gamma(id)).^2) );
    id=4:5;   
    phi(i)=phi(i)+sum( n(id).*D.^bl*del.*S );

    % phi_d
    id=1:3;
    phi_d(i)=sum( n(id).*del(i).^d(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 -beta(id).*(tau(i)-gamma(id)).^2).*(d(id)/del(i)-2*alpha(id).*(del(i)-epsil(id))) );
    id=4:5;
    phi_d(i)=phi_d(i)+sum(n(id).*(D.^bl.*(S+del(i)*Sd)+Dbd*del(i).*S));

    % phi_dd
    id=1:3;
    phi_dd(i)=sum(n(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 -beta(id).*(tau(i)-gamma(id)).^2).* ...
                (-2*alpha(id).*del(i).^d(id) + 4*alpha(id).^2.*del(i).^d(id).*(del(i)-epsil(id)).^2 - 4*d(id).*alpha(id).*del(i).^(d(id)-1).*(del(i)-epsil(id)) + d(id).*(d(id)-1).*del(i).^(d(id)-2)));
    id=4:5;
    phi_dd(i)=phi_dd(i)+sum(n(id).*( D.^bl.*(2*Sd+del(i)*Sdd) + 2*Dbd.*(S+del(i)*Sd)+Dbdd*del(i).*S));

    %phi_t
    id=1:3;
    phi_t(i)=sum(n(id).*del(i).^d(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 - beta(id).*(tau(i)-gamma(id)).^2)   .*( t(id)/tau(i)-2*beta(id).*(tau(i)-gamma(id)) ) );
    id=4:5;
    phi_t(i)=phi_t(i)+sum(n(id).*del(i).*( Dbt.*S +D.^bl.*St));

    %phi_tt
    id=1:3;
    phi_tt(i)=sum(n(id).*del(i).^d(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 - beta(id).*(tau(i)-gamma(id)).^2).*( (t(id)/tau(i)-2*beta(id).*(tau(i)-gamma(id))).^2 - t(id)/tau(i)^2 -2*beta(id)) );
    id=4:5;
    phi_tt(i)=phi_tt(i)+sum(n(id).*del(i).*( Dbtt.*S + 2*Dbt.*St +D.^bl.*Stt));

    % phi_dt
    id=1:3;
    phi_dt(i)=sum( n(id).*del(i).^d(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 - beta(id).*(tau(i)-gamma(id)).^2).*(d(id)/del(i)-2*alpha(id).*(del(i)-epsil(id))).*(t(id)/tau(i)-2*beta(id).*(tau(i)-gamma(id))) );
    id=4:5;
    phi_dt(i)=phi_dt(i)+sum( n(id).*( D.^bl.*(St+del(i)*Sdt) + del(i)*Dbd.*St + Dbt.*(S+del(i)*Sd) + Dbdt*del(i).*S));
end

function [phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt,phi_dtt]=resid_phi(parms,del,tau)
%calculate residual function and derivatives
% [phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt,phi_dtt]=resid_phi(parms,del,tau)
% where phi*RT is the residual helmholtz energy, del and tau are rho and
% temperature scaled by critical point values
%  phi_d etc are derivatives of phi etc
% parms = [coef d t gamma p] for each term
n=parms(:,1);
d=parms(:,2);
t=parms(:,3);
gamma=parms(:,4);
p=parms(:,5);

% vector of contributions to phi
    fac=del.^p;
    phi=n.*del.^d.*tau.^t.*exp(-gamma.*fac);
% vector for first density derivatives
    a=(d-gamma.*p.*fac);
%vector for second density derivative
    b=(a.*(a-1)-gamma.^2.*p.^2.*fac);
% vector for first temperature derivative
    c=t/tau;
%vector for second temperature derivative
    tt=c.*(t-1)/tau;
%add up contributions
    phi_d=sum(a.*phi/del);
    phi_dd=sum(b.*phi/del^2);
    phi_t=sum(c.*phi);
    phi_tt=sum(tt.*phi);
    phi_dt=sum(a.*c.*phi/del);
    phi_dtt=sum(a.*tt.*phi/del);
    phi=sum(phi);
    
function [P,H,S,Cv,Cp,alpha,vel,E,G,gamma]=multparmEOS(eos,rho,T)
% [H,P,S,Cv,Cp,alpha,vel,G,E]=multparmEOS(EOS,rho,T)
% T in K rho in gm/cc  = both in vectors of same length
%CPvalues=[Tc rhoc]
% parms_ideal = [n0 gamma0]
%parms_resid =[n d t gamma p]
% output:  P - GPa  vel km/s

parm_ideal=eos.parm_ideal;
parm_resid=eos.parm_resid;
parm_NA=eos.NAparm;
CPvalues=eos.CPvalues;
MW=eos.MW;

R=8.314472/MW*1000;  %J/Kg/K
rho=rho*1000;
del=rho/CPvalues(2);
tau=CPvalues(1)*T.^(-1);

nt=length(T);
np=length(rho);
if(nt~=np),error('input T and rho need to be same length'),end


P=zeros(nt,1);vel=P;Cp=P;Cv=P;E=P;G=P;H=P;alpha=P;S=P;
for i=1:np,
    [phi_0,phi0_d,phi0_dd,phi0_t, phi0_tt,phi0_dt]=ideal_phi(parm_ideal,del,tau);
    [phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt,phi_dtt]=resid_phi(parm_resid,del(i),tau(i));

    % code for the "non-analytic" terms - only interesting in critical region
 if (isempty(parm_NA)~=1)
       [phi2,phi_d2,phi_dd2,phi_t2,phi_tt2,phi_dt2]=NA_phi(parm_NA,del(i),tau(i));
       phi=phi+phi2;
       phi_d=phi_d+phi_d2;
       phi_dd=phi_dd+phi_dd2;
       phi_t=phi_t+phi_t2;
       phi_tt=phi_tt+phi_tt2;
       phi_dt=phi_dt+phi_dt2;
 end
    
    P(i)=rho(i)*R*T(i)*(1+(del(i)*phi_d))/1e9;  % GPa units
    vel(i)=1 + 2*del(i)*phi_d + del(i)^2*phi_dd - (1+del(i)*phi_d-del(i)*tau(i)*phi_dt)^2/tau(i)^2/(phi0_tt+phi_tt);
    vel(i)=sqrt(R*T(i)*vel(i))/1e3;  %km/s units  
    Cp(i)=R/1e3*(-tau(i)^2*(phi0_tt+phi_tt) + (1+del(i)*phi_d-del(i)*tau(i)*phi_dt)^2/(1+2*del(i)*phi_d+del(i)^2*phi_dd)); %J/g/K  
    Cv(i)=-R*tau(i)^2*(phi0_tt+phi_tt);
    E(i)=R*T(i)*tau(i)*(phi0_t + phi_t);
    %H(i)=R*T(i)*(1 + tau(i)*(phi0_t + phi_t) + del(i)*phi_d);
    H(i)=R*T(i)*(phi_0+phi);
    S(i)=(E(i)/T(i) - R*(phi_0+phi))/1e3;
    G(i)=R*T(i)*(1+phi_0+phi+del(i)*phi_d);
    PR=R*T(i)*(1+2*del(i)*phi_d+del(i)^2*phi_dd);
    PT=R*rho(i)*(1+del(i)*phi_d - del(i)*tau(i)*phi_dt);
    alpha(i)=PT/PR/rho(i);
end

Ks=rho.*vel.^2/1000;
gamma=alpha.*Ks./rho./Cp*1000*1000;
Cv=Cp./(1+alpha.*gamma.*T);
E=E/1000;  % kJ/kg
G=G/1000;
H=H/1000;


    
