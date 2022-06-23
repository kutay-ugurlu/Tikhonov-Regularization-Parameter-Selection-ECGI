function [noisydata, std_noise, noise] = add_noise(data, noi_param, flag)

% ADD_NOISE   Add noise to data in matrix form.
% 
% Usage: 
%    [noisydata, std_noise, noise] = add_noise(data, noi_param, flag);
% 
% Inputs: 
%
%   data        Original data of size (nLeads x nFrames)
%   noi_param   Noise parameter. Depending on the flag value, it could be
%               SNR value (flag = 'SNR') or standard deviation of the noise
%               (flag = 'stdn')
%   flag        See noi_param explanation above. If it is not provided,
%               'SNR' is the default value. 
%
% Outputs:
%
%   noisydata   Noise added data
%   std_noise   Standard deviation of the added noise.
%   noise       Gaussian noise (zero mean, iid, at the specified standard
%               deviation)added to the original data.   
%
%
rng(101)

if nargin < 3 
    flag = 'SNR';
end
rng(1)
[nLeads, nFrames] = size(data);

switch flag
    case 'SNR' % If SNR is given, calculate std of the noise
        SNR = noi_param;
        avg_pow_data = norm(data(:))/sqrt(nFrames*nLeads);
        std_noise = avg_pow_data / 10^(SNR/20); %% std of each lead
    case 'stdn' 
        std_noise = noi_param;
end

noise = randn(nLeads, nFrames); % N(0, I) noise generated
% Obtain noise ~ N(0, std_noise*I):
noise = ( ( noise - mean(noise(:)) ) ) / ( norm(noise(:))/sqrt(nFrames*nLeads) ) * std_noise; 

% Add noise to data
noisydata = data + noise;
