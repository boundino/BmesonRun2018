#include "varcomp.h"
#include "ntuple.h"

#include "xjjcuti.h"
#include <TFile.h>
#include <string>

int maxnevt = -1;
void varcomp_main(std::string treename, std::string outputdir, 
                  std::string inputname_b, std::string inputname_s_a, std::string inputname_s_b="")
{
  std::vector<TFile*> inf(1, TFile::Open(inputname_b.c_str()));
  inf.push_back(TFile::Open(inputname_s_a.c_str()));
  if(inputname_s_b != "")
    { inf.push_back(TFile::Open(inputname_s_b.c_str())); }

  std::vector<TTree*> ttr;
  std::vector<varcomp::ntuple*> nt;
  std::vector<varcomp::variable*> var;

  for(auto f : inf)
    {
      int idx = ttr.size();
      f->cd();
      ttr.push_back((TTree*)f->Get(treename.c_str())); 
      ttr[idx]->AddFriend("hiEvtAnalyzer/HiTree");
      nt.push_back(new varcomp::ntuple(ttr[idx]));
      var.push_back(new varcomp::variable(nt[idx], Form("nt%d", idx)));
    }
  std::cout<<std::endl;

  for(int k=0; k<nt.size(); k++)
    {
      inf[k]->cd();
      std::cout<<"--- "<<__FUNCTION__<<":  "<<"file:"<<inf[k]->GetName()<<" attached."<<std::endl;

      int nentries = (maxnevt<ttr[k]->GetEntries()&&maxnevt>0)?maxnevt:ttr[k]->GetEntries();
      for(int i=0; i<nentries; i++)
        {
          ttr[k]->GetEntry(i);
          if(i%100==0) { xjjc::progressbar(i, nentries); }

          for(int j=0; j<nt[k]->Bsize; j++)
            {
              if(nt[k]->Bpt[j] < 20) continue; // !
              if(!nt[k]->passedpre(j)) continue;
              if(!nt[k]->passedbkg(j) && !k) continue;
              if(!nt[k]->passedsig(j) && k) continue;

              var[k]->fillhist(j);
            }
        }
      xjjc::progressbar_summary(nentries);
      std::cout<<std::endl;

      var[k]->clearnt();
      delete nt[k];
      delete ttr[k];
    }

  TFile* outf = TFile::Open(Form("%s.root", outputdir.c_str()), "recreate");
  outf->cd();
  for(auto& v : var) { v->savehist(); }
  outf->Close();
}

int main(int argc, char* argv[])
{
  if(argc==6) { varcomp_main(argv[1], argv[2], argv[3], argv[4], argv[5]); return 0; }
  if(argc==5) { varcomp_main(argv[1], argv[2], argv[3], argv[4]); return 0; }
  std::cout<<"--- "<<__FUNCTION__<<":  invalid argument number."<<std::endl;
  return 1;
}
