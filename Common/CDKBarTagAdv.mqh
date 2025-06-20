//+------------------------------------------------------------------+
//|                                                 CDKBarTagAdv.mqh |
//|                                                  Denis Kislitsyn |
//|                                 http:/kislitsyn.me/personal/algo |
//|
//| 2025-02-27: [+] Free()
//|             [+] GetSym()
//|             [+] GetTF()
//+------------------------------------------------------------------+

#include "DKStdLib.mqh" 

class CDKBarTagAdv : public CObject {
protected:
  string                _Sym;
  ENUM_TIMEFRAMES       _TF;
  int                   _Index;  
  datetime              _Time;  
  double                _Value;
 
public:
  void                  CDKBarTagAdv::CDKBarTagAdv(void);
  void                  CDKBarTagAdv::CDKBarTagAdv(const string aSymbol, const ENUM_TIMEFRAMES aTF);
  void                  CDKBarTagAdv::CDKBarTagAdv(const string aSymbol, const ENUM_TIMEFRAMES aTF, const int aIndex, const double aValue=0);
  void                  CDKBarTagAdv::CDKBarTagAdv(const string aSymbol, const ENUM_TIMEFRAMES aTF, const datetime aTime, const double aValue=0);
  void                  CDKBarTagAdv::Init(const string aSymbol, const ENUM_TIMEFRAMES aTF);
  void                  CDKBarTagAdv::Init(const string aSymbol, const ENUM_TIMEFRAMES aTF, const int aIndex, const double aValue=0);
  void                  CDKBarTagAdv::Init(const string aSymbol, const ENUM_TIMEFRAMES aTF, const datetime aTime, const double aValue=0);  
  
  string                CDKBarTagAdv::__repr__();
  string                CDKBarTagAdv::__repr__(const bool aShortFormat=false);
  
  int                   CDKBarTagAdv::SetTime(const datetime aTime, const bool aExact=false);
  int                   CDKBarTagAdv::SetTimeAndValue(const datetime aTime, const double aValue, const bool aExact=false);
  void                  CDKBarTagAdv::SetIndex(const int aIndex);  
  void                  CDKBarTagAdv::SetIndexAndValue(const int aIndex, const double aValue);  
  int                   CDKBarTagAdv::UpdateIndex(const bool aExact = false);
  void                  CDKBarTagAdv::SetValue(const double aValue);  
  void                  CDKBarTagAdv::Free();  
  
  string                CDKBarTagAdv::GetSym();
  ENUM_TIMEFRAMES       CDKBarTagAdv::GetTF();
  int                   CDKBarTagAdv::GetIndex(const bool aUpdate=false, const bool aExact = false);
  datetime              CDKBarTagAdv::GetTime();  
  double                CDKBarTagAdv::GetValue();
};

void CDKBarTagAdv::CDKBarTagAdv(void) {
  _Sym = "";
  _TF = PERIOD_CURRENT;
  Free();
}

void CDKBarTagAdv::CDKBarTagAdv(const string aSymbol, const ENUM_TIMEFRAMES aTF) {
  _Sym = aSymbol;
  _TF = aTF;
  Free();
}

void CDKBarTagAdv::CDKBarTagAdv(const string aSymbol, const ENUM_TIMEFRAMES aTF, const int aIndex, const double aValue=0) {
  _Sym = aSymbol;
  _TF = aTF;
  _Value = aValue;
  SetIndex(aIndex);
}

void CDKBarTagAdv::CDKBarTagAdv(const string aSymbol, const ENUM_TIMEFRAMES aTF, const datetime aTime, const double aValue=0) {
  _Sym = aSymbol;
  _TF = aTF;
  _Value = aValue;
  SetTime(aTime);
}

void CDKBarTagAdv::Init(const string aSymbol, const ENUM_TIMEFRAMES aTF) {
  _Sym = aSymbol;
  _TF = aTF;
  Free();
}

void CDKBarTagAdv::Init(const string aSymbol, const ENUM_TIMEFRAMES aTF, const int aIndex, const double aValue=0) {
  _Sym = aSymbol;
  _TF = aTF;
  _Value = aValue;
  SetIndex(aIndex);
}

void CDKBarTagAdv::Init(const string aSymbol, const ENUM_TIMEFRAMES aTF, const datetime aTime, const double aValue=0) {
  _Sym = aSymbol;
  _TF = aTF;
  _Value = aValue;
  SetTime(aTime);
}

string  CDKBarTagAdv::__repr__() {
  return StringFormat("BT(%s,%s,%s/%d,%f)",
                      _Sym,
                      TimeframeToString(_TF),
                      TimeToStringNA(_Time),
                      _Index,
                      _Value
                      );
}

string CDKBarTagAdv::__repr__(const bool aShortFormat=false) {
  return StringFormat("BT(%s;%d;%f)",
                      TimeToStringNA(_Time),
                      _Index,
                      _Value
                      );
}

void CDKBarTagAdv::SetIndex(const int aIndex) {
  _Index = aIndex;
  _Time = iTime(_Sym, _TF, _Index);
}

void CDKBarTagAdv::SetIndexAndValue(const int aIndex, const double aValue) {
  _Value = aValue;
  SetIndex(aIndex);
}

int CDKBarTagAdv::SetTime(const datetime aTime, const bool aExact = false) {
  _Time = aTime;
  _Index = iBarShift(_Sym, _TF, _Time, aExact);
  if (_Index < 0) _Time = 0;
  
  return _Index;
}

int CDKBarTagAdv::SetTimeAndValue(const datetime aTime, const double aValue, const bool aExact=false) {
  _Value = aValue;
  return SetTime(aTime, aExact);
}

int CDKBarTagAdv::UpdateIndex(const bool aExact = false) {
  return SetTime(_Time, aExact);  
}

void CDKBarTagAdv::SetValue(const double aValue) {
  _Value = aValue;
}

void CDKBarTagAdv::Free() {
  _Index = -1;
  _Time = 0;
  _Value = 0.0;
}

string CDKBarTagAdv::GetSym() {
  return _Sym;
}
ENUM_TIMEFRAMES CDKBarTagAdv::GetTF(){
  return _TF;
}

int CDKBarTagAdv::GetIndex(const bool aUpdate=false, const bool aExact = false){
  if (aUpdate) UpdateIndex(aExact);
  return _Index;
}

datetime CDKBarTagAdv::GetTime() {
  return _Time;
}

double CDKBarTagAdv::GetValue() {
  return _Value;
}