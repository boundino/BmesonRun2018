// https://root.cern.ch/doc/v610/TMVAGui_8cxx_source.html
// https://root.cern.ch/doc/v608/efficiencies_8cxx_source.html
#include <iostream>
#include <string>

#include <TKey.h>
#include <TList.h>
#include "TMVA/efficiencies.h"

#include "xjjcuti.h"

namespace mytmva
{
  void guiefficiencies(std::string outputname, float ptmin, float ptmax, std::string mymethod);
  void efficiencies(std::string outfname);
}

void mytmva::guiefficiencies(std::string outputname, float ptmin, float ptmax, std::string mymethod)
{
  mymethod = xjjc::str_replaceall(mymethod, " ", "");
  std::string outfname(Form("%s_%s_%s_%s.root", outputname.c_str(), xjjc::str_replaceallspecial(mymethod).c_str(), 
                            xjjc::number_to_string(ptmin).c_str(), (ptmax<0?"inf":xjjc::number_to_string(ptmax).c_str())));
  mytmva::efficiencies(outfname);
}

void mytmva::efficiencies(std::string outfname)
{
  TString dataset("");
  std::string outputstr = xjjc::str_replaceallspecial(outfname);

  // set up dataset
  TFile* file = TFile::Open( outfname.c_str() );
  if(!file)
    { std::cout << "==> Abort " << __FUNCTION__ << ", please verify filename." << std::endl; return; }
  if(file->GetListOfKeys()->GetEntries()<=0)
    { std::cout << "==> Abort " << __FUNCTION__ << ", please verify if dataset exist." << std::endl; return; }
  // --->>
  if( (dataset==""||dataset.IsWhitespace()) && (file->GetListOfKeys()->GetEntries()==1))
    { dataset = ((TKey*)file->GetListOfKeys()->At(0))->GetName(); }
  // <<---
  else if((dataset==""||dataset.IsWhitespace()) && (file->GetListOfKeys()->GetEntries()>=1))
    {
      std::cout << "==> Warning " << __FUNCTION__ << ", more than 1 dataset." << std::endl;
      for(int i=0;i<file->GetListOfKeys()->GetEntries();i++)
        {
          dataset = ((TKey*)file->GetListOfKeys()->At(i))->GetName();
          std::cout << "    " << dataset << std::endl;
        }
      return;
    }
  else { return; }

  // TMVA::efficiencies(dataset.Data(), outfname.c_str(), 1);
  TMVA::efficiencies(dataset.Data(), outfname.c_str(), 2);
  // TMVA::efficiencies(dataset.Data(), outfname.c_str(), 3);

  gSystem->Exec(Form("rm %s/plots/*.png", dataset.Data()));
  gSystem->Exec(Form("mkdir -p %s/plots/%s", dataset.Data(), outputstr.c_str()));
  gSystem->Exec(Form("mv %s/plots/*.eps %s/plots/%s/", dataset.Data(), dataset.Data(), outputstr.c_str()));
}

int main(int argc, char* argv[])
{
  if(argc==5)
    { mytmva::guiefficiencies(argv[1], atof(argv[2]), atof(argv[3]), argv[4]); return 0; }
  return 1;
}
