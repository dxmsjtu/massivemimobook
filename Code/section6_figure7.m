%This Matlab script can be used to reproduce Figure 6.7 in the monograph:
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


%Number of BSs
L = 16;

%Number of UEs per BS
K = 10;

%Number of BS antennas
M = 100;

%Define the range of pilot reuse factors
fRange = [1 2];

%Select the number of setups with random UE locations
nbrOfSetups = 20;

%Select the number of channel realizations per setup
nbrOfRealizations = 200;

%Select the range of hardware qualities. The values at the same position in
%the different vectors are considered simultaneously.
kappatUE = [0.99 0.99 0.99 0.99 0.99 0.95 0.97 0.98 0.99 0.995 1];
kapparUE = [0.95 0.97 0.98 0.995 1 0.99 0.99 0.99 0.99 0.99 0.99];
kappatBS = kapparUE;
kapparBS = kappatUE;


%% Propagation parameters

%Communication bandwidth
B = 20e6;

%Total uplink transmit power per UE (mW)
p = 100;

%Total downlink transmit power per UE (mW)
rho = 100;

%Noise figure at the BS (in dB)
noiseFigure = 7;

%Compute noise power
noiseVariancedBm = -174 + 10*log10(B) + noiseFigure;

%Select length of coherence block
tau_c = 200;

%Use the approximation of the Gaussian local scattering model
accuracy = 2;

%Angular standard deviation in the local scattering model (in degrees)
ASDdeg = 10;


%Prepare to save simulation results
sumSE_MR = zeros(length(kappatUE),length(fRange),nbrOfSetups);
sumSE_RZF = zeros(length(kappatUE),length(fRange),nbrOfSetups);
sumSE_MMMSE = zeros(length(kappatUE),length(fRange),nbrOfSetups);


%% Go through all setups
for n = 1:nbrOfSetups
    
    %Output simulation progress
    disp([num2str(n) ' setups out of ' num2str(nbrOfSetups)]);
    
    %Compute channel statistics for one setup
    [R,channelGaindB] = functionExampleSetup(L,K,M,accuracy,ASDdeg);
    
    %Compute the normalized average channel gain, where the normalization
    %is based on the noise power
    channelGainOverNoise = channelGaindB - noiseVariancedBm;
    
    
    %Go through all pilot reuse factors
    for s = 1:length(fRange)
        
        %Extract pilot reuse factor
        f = fRange(s);
        
        %Output simulation progress
        disp([num2str(f) ' reuse factor out of ' num2str(length(fRange))]);
        
        
        %Go through all hardware qualities
        for r = 1:length(kappatUE)
            
            %Generate channel realizations with estimates and estimation
            %error correlation matrices, using LMMSE estimation
            [Hhat,C,tau_p,~,H] = functionChannelEstimates_impairments(R,channelGainOverNoise,nbrOfRealizations,M,K,L,p,f,kappatUE(r),kapparBS(r));
            
            %Compute SE using Monte-Carlo realizations
            [SE_MR,SE_RZF,SE_MMMSE] = functionComputeSE_DL_impairments(H,Hhat,C,tau_c,tau_p,nbrOfRealizations,M,K,L,p,rho,kappatBS(r),kapparUE(r));
            
            %Save results
            sumSE_MR(r,s,n) = mean(sum(SE_MR,1));
            sumSE_RZF(r,s,n) = mean(sum(SE_RZF,1));
            sumSE_MMMSE(r,s,n) = mean(sum(SE_MMMSE,1));
            
            %Delete large matrices
            clear Hhat C H;
            
        end
        
    end
    
    %Delete large matrices
    clear R;
    
end




%Plot the simulation results
figure;
hold on; box on;

plot(kapparUE([1 2 3 9 4 5]),max(mean(sumSE_MMMSE([1 2 3 9 4 5],:,:),3),[],2),'rd-','LineWidth',1);
plot(kapparUE([1 2 3 9 4 5]),max(mean(sumSE_RZF([1 2 3 9 4 5],:,:),3),[],2),'r-.','LineWidth',1);
plot(kapparUE([1 2 3 9 4 5]),max(mean(sumSE_MR([1 2 3 9 4 5],:,:),3),[],2),'bs-','LineWidth',1);

xlabel('DL hardware quality');
ylabel('Average sum SE [bit/s/Hz/cell]');
legend('M-MMSE','RZF','MR','Location','SouthEast');
xlim([0.95 1]);
ylim([0 40]);



%Plot the simulation results
figure;
hold on; box on;

plot(kappatUE(6:11),max(mean(sumSE_MMMSE(6:11,:,:),3),[],2),'rd-','LineWidth',1);
plot(kappatUE(6:11),max(mean(sumSE_RZF(6:11,:,:),3),[],2),'r-.','LineWidth',1);
plot(kappatUE(6:11),max(mean(sumSE_MR(6:11,:,:),3),[],2),'bs-','LineWidth',1);

xlabel('UL hardware quality');
ylabel('Average sum SE [bit/s/Hz/cell]');
legend('M-MMSE','RZF','MR','Location','SouthEast');
xlim([0.95 1]);
ylim([0 40]);
