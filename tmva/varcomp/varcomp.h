#ifndef _VARCOMP_H_
#define _VARCOMP_H_

#include "ntuple.h"
#include <TMath.h>
#include <TString.h>
#include <TH1F.h>
#include <TFile.h>

#include <vector>
#include <map>
#include <string>
#include <iostream>

#ifndef MASS_JPSI
#define MASS_JPSI  3.096916
#endif

namespace varcomp
{
  struct varele
  {
    std::string varname;
    std::string vartex;
    float varmin;
    float varmax;
    varele(const std::string& varname_, const std::string& vartex_, const float& varmin_, const float& varmax_) 
      : varname(varname_), vartex(vartex_), varmin(varmin_), varmax(varmax_) { ; }
  };

  class variable
  {
  public:
    int nvar;
    std::vector<varele> varlist = {
      //varele(name       , texformat                                                      , min, max
      varele("mass"       , "m_{#mu#mu#pi#pi} (GeV/c^{2})"                                 , 3.6, 4.0),
      varele("dRtrk1"     , "#DeltaR(#pi_{1},J/#psi)"                                      , 0  , 0.5),
      varele("dRtrk2"     , "#DeltaR(#pi_{2},J/#psi)"                                      , 0  , 0.5),
      varele("Qvalue"     , "Q (GeV/c^{2})"                                                , 0  , 0.5),
      varele("costheta"   , "cos(#theta)"                                                  , -1 , 1),
      varele("alpha"      , "#alpha"                                                       , 0  , 3.2),
      varele("dls3D"      , "l_{xyz}/#sigma(l_{xyz})"                                      , 0  , 10),
      varele("dls2D"      , "l_{xy}/#sigma(l_{xy})"                                        , 0  , 10),
      varele("chi2cl"     , "vertex #chi^{2} prob"                                         , 0  , 1),
      varele("ptimbalance", "p_{T}(#pi_{1})-p_{T}(#pi_{2}) / p_{T}(#pi_{1})+p_{T}(#pi_{2})", 0  , 1),
      varele("trk1pt"     , "#pi_{1} p_{T} (GeV/c)"                                        , 0  , 10),
      varele("trk2pt"     , "#pi_{2} p_{T} (GeV/c)"                                        , 0  , 10),
      varele("trk1dca"    , "trk1Dxy/trk1D0Err"                                            , 0  , 10),
      varele("trk2dca"    , "trk2Dxy/trk2D0Err"                                            , 0  , 10),
    };
    std::vector<float> varval;
    std::vector<TH1F*> hist;
    const int nbin = 50;

    variable(varcomp::ntuple* nt_, std::string name_);
    variable(TFile* histfile, std::string name_);
    ~variable() { for(auto& h : hist) { delete h; } } 
    void fillhist(int j);
    void savehist() { for(auto& h : hist) { std::cout<<"--- "<<__FUNCTION__<<":  \e[2mTH1F\e[0m "<<h->GetName()<<" \e[2m("<<h->GetEntries()<<")\e[0m"<<" Write."<<std::endl; h->Write(); } }
    void sethist(int k);
    void clearnt() { fnt = 0; }
    bool isvalid() { return fvalid; }

  private:
    std::string name;
    varcomp::ntuple* fnt; //~
    TFile* finf; //~
    bool fvalid;
    void refreshval(int j)
    {
      std::map<std::string, float> varnow = {
        std::pair<std::string, float>("mass", (float)fnt->Bmass[j]), 
        std::pair<std::string, float>("dRtrk1", (float)TMath::Sqrt(pow(TMath::ACos(TMath::Cos(fnt->Bujphi[j] - fnt->Btrk1Phi[j])), 2) + pow(fnt->Bujeta[j] - fnt->Btrk1Eta[j], 2))), 
        std::pair<std::string, float>("dRtrk2", (float)TMath::Sqrt(pow(TMath::ACos(TMath::Cos(fnt->Bujphi[j] - fnt->Btrk2Phi[j])), 2) + pow(fnt->Bujeta[j] - fnt->Btrk2Eta[j], 2))), 
        std::pair<std::string, float>("Qvalue", (float)(fnt->Bmass[j]-MASS_JPSI-fnt->Btktkmass[j])), 
        std::pair<std::string, float>("costheta", (float)TMath::Cos(fnt->Bdtheta[j])), 
        std::pair<std::string, float>("dls3D", (float)TMath::Abs(fnt->BsvpvDistance[j]/fnt->BsvpvDisErr[j])), 
        std::pair<std::string, float>("chi2cl", (float)fnt->Bchi2cl[j]), 
        std::pair<std::string, float>("trk1pt", (float)fnt->Btrk1Pt[j]), 
        std::pair<std::string, float>("trk2pt", (float)fnt->Btrk2Pt[j]), 
        std::pair<std::string, float>("alpha", (float)fnt->Balpha[j]), 
        std::pair<std::string, float>("trk1dca", (float)TMath::Abs(fnt->Btrk1Dxy[j]/fnt->Btrk1D0Err[j])), 
        std::pair<std::string, float>("trk2dca", (float)TMath::Abs(fnt->Btrk2Dxy[j]/fnt->Btrk2D0Err[j])), 
        std::pair<std::string, float>("dls2D", (float)TMath::Abs(fnt->BsvpvDistance_2D[j]/fnt->BsvpvDisErr_2D[j])), 
        std::pair<std::string, float>("ptimbalance", (float)TMath::Abs((fnt->Btrk1Pt[j]-fnt->Btrk2Pt[j]) / (fnt->Btrk1Pt[j]+fnt->Btrk2Pt[j]))), 
      };
      for(int i=0; i<nvar; i++) { varval[i] = varnow[varlist[i].varname]; }
    }
  };

  std::vector<Color_t> lcolor = {kBlue+1, kRed, kGreen+2};
  std::vector<Color_t> fcolor = {kBlue-9, kRed, kGreen+2};
  std::vector<Style_t> fstyle = {1001, 3004, 3005};

  variable::variable(varcomp::ntuple* nt_, std::string name_) : fnt(nt_), name(name_), finf(0), fvalid(true)
  { 
    nvar = varlist.size();
    varval.resize(nvar, 0); 
    hist.resize(nvar, 0);
    for(int i=0; i<nvar; i++)
      {
        hist[i] = new TH1F(Form("h_%s_%s_%d", name.c_str(), varlist[i].varname.c_str(), i), Form(";%s;", varlist[i].vartex.c_str()), nbin, varlist[i].varmin, varlist[i].varmax); 
        hist[i]->Sumw2();
      }
    std::cout<<"--- "<<__FUNCTION__<<":  \e[1m"<<name<<"\e[0m ("<<nvar<<") created. => pthatweight "<<(fnt->isweight()?"applied.":"\e[31;1mnot\e[0m applied.")<<std::endl;
  }
  variable::variable(TFile* histfile, std::string name_) : fnt(0), name(name_), finf(histfile), fvalid(true)
  {
    nvar = varlist.size();
    varval.resize(nvar, 0); 
    hist.resize(nvar, 0);
    for(int i=0; i<nvar; i++)
      {
        hist[i] = (TH1F*)finf->Get(Form("h_%s_%s_%d", name.c_str(), varlist[i].varname.c_str(), i));
        if(hist[i]==0) { fvalid = false; break; }
        std::cout<<"--- "<<__FUNCTION__<<":  \e[2mTH1F\e[0m "<<hist[i]->GetName()<<" \e[2m("<<hist[i]->GetEntries()<<")\e[0m"<<" attached."<<std::endl;
      }
    if(fvalid) std::cout<<"--- "<<__FUNCTION__<<":  \e[1m"<<name<<"\e[0m created ("<<nvar<<")."<<std::endl;    
    else std::cout<<"--- "<<__FUNCTION__<<":  \e[1m"<<name<<"\e[0m fails."<<std::endl;    
  }

  void variable::fillhist(int j)
  {
    refreshval(j);
    float weight = fnt->isweight()?fnt->pthatweight:1.;
    for(int i=0; i<nvar; i++) { hist[i]->Fill(varval[i], weight); }
  }
  void variable::sethist(int k)
  {
    for(auto& h : hist)
      {
        h->Scale(1./h->Integral());
        h->SetLineColor(lcolor[k]);
        h->SetFillStyle(fstyle[k]);
        h->SetFillColor(fcolor[k]);
        h->SetLineWidth(2);
      }
  }

  //
  

}

#endif
