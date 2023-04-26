%This Matlab script can be used to reproduce Figure 4.10 in the monograph:
%
%Emil Bjornson, Jakob Hoydis and Luca Sanguinetti (2017), 
%"Massive MIMO Networks: Spectral, Energy, and Hardware Efficiency", 
%Foundations and Trends in Signal Processing: Vol. 11, No. 3-4, 
%pp. 154-655. DOI: 10.1561/2000000093.
%
%For further information, visit: https://www.massivemimobook.com
%
%This is version 1.0 (Last edited: 2017-11-04)
%
%License: This code is licensed under the GPLv2 license. If you in any way
%use this code for research that results in publications, please cite our
%monograph as described above.


%Empty workspace and close figures
close all;
clear;


%Define the range of BS antennas
Mvalues = [1 10 100];

%Angular standard deviation in the local scattering model (in degrees)
ASDdeg = 10;

%Nominal angle of the desired UE
thetaDesired = pi/6;

%Range of nominal angles of the interfering UE
varphiInterfererDegrees = -180:1:180;
varphiInterfererRadians = varphiInterfererDegrees*(pi/180);

%Define the antenna spacing (in number of wavelengths)
antennaSpacing = 1/2; %Half wavelength distance

%Define the range of the effective SNR in (3.13) for the desired UE
SNR1dB = 10;
SNR1 = 10.^(SNR1dB/10);

%Define the range of the effective SNR in (3.13) for the interfering UE
SNR2dB = SNR1dB-10;
SNR2 = 10.^(SNR2dB/10);


%Preallocate matrices for storing the simulation results
relativeInterferenceCoherent = zeros(length(varphiInterfererRadians),length(thetaDesired),length(Mvalues));


%Compute correlation matrix of the desired UE
R1 = functionRlocalscattering(max(Mvalues),thetaDesired,ASDdeg,antennaSpacing);


%% Go through all angles of the interfering UE
for n = 1:length(varphiInterfererRadians)
    
    %Compute correlation matrix of the interfering UE
    R2 = functionRlocalscattering(max(Mvalues),varphiInterfererRadians(n),ASDdeg,antennaSpacing);
    
    %Go through all numbers of antennas
    for m = 1:length(Mvalues)
        
        R1m = R1(1:Mvalues(m),1:Mvalues(m));
        R2m = R2(1:Mvalues(m),1:Mvalues(m));
        
        %Compute numerator and denominator of the ratio between desired
        %signal term and coherent interference term in (4.17)
        numerator = SNR2^2*abs(trace(R1m*((SNR1*R1m+SNR2*R2m+eye(Mvalues(m)))\R2m)))^2;
        denominator = SNR1^2*abs(trace(R1m*((SNR1*R1m+SNR2*R2m+eye(Mvalues(m)))\R1m)))^2;
        
        relativeInterferenceCoherent(n,m) = numerator/denominator;
        
    end
    
end


%% Plot the simulation results
figure;
hold on; box on;

plot(varphiInterfererDegrees,10*log10(relativeInterferenceCoherent(:,1)),'k-','LineWidth',1);
plot(varphiInterfererDegrees,10*log10(relativeInterferenceCoherent(:,2)),'r--','LineWidth',1);
plot(varphiInterfererDegrees,10*log10(relativeInterferenceCoherent(:,3)),'b-.','LineWidth',1);

xlabel('Angle of interfering UE [degree]');
ylabel('Coherent interf. power over signal power [dB]');
xlim([-180 180]);
ylim([-40 -10]);

legend('M=1','M=10','M=100','Location','NorthWest');
