#ifndef _TMVACLASSIFICATION_H_
#define _TMVACLASSIFICATION_H_

#include <string>
#include <vector>
#include <TString.h>

#include "xjjcuti.h"

namespace mytmva
{
  struct tmvavar
  {
    std::string varname;
    std::string var;
    std::string cutsign;
    tmvavar(const std::string& varname_, const std::string& var_, const std::string& cutsign_) 
      : varname(varname_), var(var_), cutsign(cutsign_) { ; }
  };

  std::vector<mytmva::tmvavar> varlist = {
    mytmva::tmvavar("chi2cl"     , "Bchi2cl"                                                                                        , "FMax"), // 0
    mytmva::tmvavar("dRtrk1"     , "dRtrk1 := TMath::Sqrt(pow(TMath::ACos(TMath::Cos(Bujphi-Btrk1Phi)),2) + pow(Bujeta-Btrk1Eta,2))", "FMin"), // 1
    mytmva::tmvavar("dRtrk2"     , "dRtrk2 := TMath::Sqrt(pow(TMath::ACos(TMath::Cos(Bujphi-Btrk2Phi)),2) + pow(Bujeta-Btrk2Eta,2))", "FMin"), // 2
    mytmva::tmvavar("Qvalue"     , "Qvalue := (Bmass-3.096916-Btktkmass)"                                                           , "FMin"), // 3
    mytmva::tmvavar("alpha"      , "Balpha"                                                                                         , "FMin"), // 4
    mytmva::tmvavar("costheta"   , "costheta := TMath::Cos(Bdtheta)"                                                                , "FMax"), // 5
    mytmva::tmvavar("dls3D"      , "dls3D := TMath::Abs(BsvpvDistance/BsvpvDisErr)"                                                 , "FMax"), // 6
    mytmva::tmvavar("dls2D"      , "dls2D := TMath::Abs(BsvpvDistance_2D/BsvpvDisErr_2D)"                                           , "FMax"), // 7
    mytmva::tmvavar("trk1pt"     , "Btrk1Pt"                                                                                        , "FMax"), // 8
    mytmva::tmvavar("trk2pt"     , "Btrk2Pt"                                                                                        , "FMax"), // 9
    mytmva::tmvavar("ptimbalance", "trkptimba := TMath::Abs((Btrk1Pt-Btrk2Pt) / (Btrk1Pt+Btrk2Pt))"                                 , "FMax"), // 10
  };

}

#endif
