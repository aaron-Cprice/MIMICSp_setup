library(rootSolve)
library(boot)

#Model Function
RXEQ <- function(t, y, pars) {
  with (as.list(c(y, pars)),{
    
    #Flows to and from MIC_1
    LITmin[1] = MIC_1 * VMAX[1] * LIT_1 / (KM[1] + MIC_1)   #MIC_1 decomp of MET lit
    LITmin[2] = MIC_1 * VMAX[2] * LIT_2 / (KM[2] + MIC_1)   #MIC_1 decomp of STRUC lit
    MICtrn[1] = MIC_1 * tau[1]  * fPHYS[1]                  #MIC_1 turnover to PHYSICAL SOM 
    MICtrn[2] = MIC_1 * tau[1]  * fCHEM[1]                  #MIC_1 turnover to CHEMICAL SOM  
    MICtrn[3] = MIC_1 * tau[1]  * fAVAI[1]                  #MIC_1 turnover to AVAILABLE SOM  
    SOMmin[1] = MIC_1 * VMAX[3] * SOM_3 / (KM[3] + MIC_1)   #decomp of SOMa by MIC_1
    
    #Flows to and from MIC_2
    LITmin[3] = MIC_2 * VMAX[4] * LIT_1 / (KM[4] + MIC_2)   #decomp of MET litter
    LITmin[4] = MIC_2 * VMAX[5] * LIT_2 / (KM[5] + MIC_2)   #decomp of SRUCTURAL litter
    MICtrn[4] = MIC_2 * tau[2]  * fPHYS[2]                  #MIC_2 turnover to PHYSICAL  SOM 
    MICtrn[5] = MIC_2 * tau[2]  * fCHEM[2]                  #MIC_2 turnover to CHEMICAL  SOM  
    MICtrn[6] = MIC_2 * tau[2]  * fAVAI[2]                  #MIC_2 turnover to AVAILABLE SOM  
    SOMmin[2] = MIC_2 * VMAX[6] * SOM_3 / (KM[6] + MIC_2)   #decomp of SOMa by MIC_2
    
    MICtrn[7] = MIC_A * tau[3] * fPHYS[3]                   #MIC_A turnover to PHYSCIAL SOM
    MICtrn[8] = MIC_A * tau[3] * fCHEM[3]                   #MIC_A turnober to CHEMICAL SOM
    MICtrn[9] = MIC_A * tau[3] * fAVAI[3]                   #MIC_A turnover to AVAILABLE SOM
    SOMmin[3] = MIC_A * VMAX[7] * SOM_3 / (KM[7] + MIC_A)   #decomp of SOMa by MIC_A         
    
    DEsorb    = SOM_1 * desorb  #* (MIC_1 + MIC_2)  	#desorbtion of PHYS to AVAIL (function of fCLAY)
    OXIDAT    = ((MIC_1 * VMAX[2] * SOM_2 / (KO[1]*KM[2] + MIC_1)) +
                   (MIC_2 * VMAX[5] * SOM_2 / (KO[2]*KM[5] + MIC_2)) +
                   (MIC_A * VMAX[7] * SOM_2 / (KO[3]*KM[7] + MIC_A)))  #oxidation of C to A
    
    dLIT_1 = I[1]*(1-FI[1]) - LITmin[1] - LITmin[3]
    
    dMIC_1 = CUE[1]*(LITmin[1]+ SOMmin[1]) + CUE[2]*(LITmin[2]) - (MICtrn[[1]] + MICtrn[[2]] + MICtrn[[3]])#sum(MICtrn[1:3])
    dSOM_1 = I[1]*FI[1] + MICtrn[1] + MICtrn[4] + MICtrn[7] - DEsorb 
    
    dLIT_2 = I[2] * (1-FI[2]) - LITmin[2] - LITmin[4]
    dMIC_2 = CUE[3]*(LITmin[3]+ SOMmin[2]) + CUE[4]*(LITmin[4]) - (MICtrn[[4]] + MICtrn[[5]] + MICtrn[[6]])#sum(MICtrn[4:6])
    dSOM_2 = I[2]*FI[2] + MICtrn[2] + MICtrn[5] + MICtrn[8] - OXIDAT
    
    dSOM_3 = MICtrn[3] + MICtrn[6] + DEsorb + OXIDAT - SOMmin[1] - SOMmin[2] - SOMmin[3]
    
    dMIC_A = CUE[5] * SOMmin[3] - (MICtrn[[7]] + MICtrn[[8]] + MICtrn[9]) 
    
    list(c(dLIT_1, dLIT_2, dMIC_1, dMIC_2, dMIC_A, dSOM_1, dSOM_2, dSOM_3))
  })
}


#Remove STODE warning "diagonal element is 0"
quiet <- function(x) { 
  sink(tempfile()) 
  on.exit(sink()) 
  invisible(force(x)) 
} 