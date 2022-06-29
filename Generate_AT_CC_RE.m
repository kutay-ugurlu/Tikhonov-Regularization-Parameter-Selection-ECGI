function [CCs, REs] = Generate_AT_CC_RE(X_test, X_reconstructed, L)

Test_AT = ActivationTimeST(X_test,L);
Reconstructed_AT = ActivationTimeST(X_reconstructed, L);
CCs = calculate_cc(Test_AT,Reconstructed_AT);
REs = calculate_re(Test_AT,Reconstructed_AT);

end
