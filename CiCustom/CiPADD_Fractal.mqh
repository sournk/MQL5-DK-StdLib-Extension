//+------------------------------------------------------------------+
//|                                                CiPADDFractal.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|
//| ver. 2025-06-02:
//|  [+] Prev
//|  [+] Next
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"
#include "../Common/CDKBarTag.mqh"

#define CLASSICRENKOONTICK_INDICATOR_NAME "PADD-Fractal-Ind"
#define CLASSICRENKOONTICK_INDICATOR_BUFFER_COUNT 1
#define LEVELS_INITIAL_BUFFER_SIZE 2048

enum ENUM_FRACTAL_TYPE {
  FRACTAL_TYPE_UP   = 0, // Верх
  FRACTAL_TYPE_DOWN = 1, // Низ
};

class CiPADDFractal : public CiCustom {
protected:
  virtual bool      Initialize(const string symbol, 
                               const ENUM_TIMEFRAMES period, 
                               const int num_params, 
                               const MqlParam &params[]
                    ) override;  
public:
  virtual bool      Create(string _symbol, 
                           ENUM_TIMEFRAMES _period,
                           
                           ENUM_FRACTAL_TYPE  _InpFractalType,
                           uint               _InpArrowCode, //                      = 234;                              // B.ACD: Код символа стрелки
                           color              _InpArrowColor, //                     = clrRed;                           // B.ACL: Цвет стрелки
                           uint               _InpLeftBarCount, //                   = 3;                                // F.LBC: Свечей слева, шт
                           bool               _InpLeftHighSorted, //                 = true;                             // F.LHS: HIGH свечей слева упорядочены
                           bool               _InpLeftLowSorted, //                  = true;                             // F.LLS: LOW свечей слева упорядочены
                           uint               _InpRightBarCount, //                  = 3;                                // F.RBC: Свечей справа, шт
                           bool               _InpRightHighSorted, //                = true;                             // F.RHS: HIGH свечей справа упорядочены
                           bool               _InpRightLowSorted  //                 = true;                             // F.RLS: LOW свечей справа упорядочены                           
                           ); 
                            
  virtual double    Main(int index) { return this.GetData(0, index); }
  virtual bool      Last(CDKBarTag& _bar_tag);
  virtual bool      Prev(CDKBarTag& _bar_tag, const int _idx);
  virtual bool      Next(CDKBarTag& _bar_tag, const int _idx);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiPADDFractal::Create(string _symbol, 
                                  ENUM_TIMEFRAMES _period, 
                                  
                           ENUM_FRACTAL_TYPE  _InpFractalType,
                           uint               _InpArrowCode, //                      = 234;                              // B.ACD: Код символа стрелки
                           color              _InpArrowColor, //                     = clrRed;                           // B.ACL: Цвет стрелки
                           uint               _InpLeftBarCount, //                   = 3;                                // F.LBC: Свечей слева, шт
                           bool               _InpLeftHighSorted, //                 = true;                             // F.LHS: HIGH свечей слева упорядочены
                           bool               _InpLeftLowSorted, //                  = true;                             // F.LLS: LOW свечей слева упорядочены
                           uint               _InpRightBarCount, //                  = 3;                                // F.RBC: Свечей справа, шт
                           bool               _InpRightHighSorted, //                = true;                             // F.RHS: HIGH свечей справа упорядочены
                           bool               _InpRightLowSorted  //                 = true;                             // F.RLS: LOW свечей справа упорядочены                                                             
                           ) {
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(CLASSICRENKOONTICK_INDICATOR_NAME, TYPE_STRING)
         .Set("1. ОСНОВНЫЕ (B)", TYPE_STRING)
         .Set(_InpFractalType, TYPE_UINT)
         .Set(_InpArrowCode, TYPE_UINT)
         .Set(_InpArrowColor, TYPE_COLOR)
         
         .Set("2. ФИЛЬТРЫ (F)", TYPE_STRING)
         .Set(_InpLeftBarCount, TYPE_UINT)
         .Set(_InpLeftHighSorted, TYPE_BOOL)
         .Set(_InpLeftLowSorted, TYPE_BOOL)
         
         .Set(_InpRightBarCount, TYPE_UINT)
         .Set(_InpRightHighSorted, TYPE_BOOL)
         .Set(_InpRightLowSorted, TYPE_BOOL);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(LEVELS_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiPADDFractal::Initialize(const string symbol, 
                                      const ENUM_TIMEFRAMES period, 
                                      const int num_params, 
                                      const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(CLASSICRENKOONTICK_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}

bool CiPADDFractal::Last(CDKBarTag& _bar_tag) {
  for(int idx = 0; idx < LEVELS_INITIAL_BUFFER_SIZE; idx++) {
    double val = Main(idx);
    if(val > 0.0) {
      _bar_tag.Init(this.m_symbol, this.m_period);
      _bar_tag.SetIndexAndValue(idx, val);
      return true;
    }
  }
  return false;
}

bool CiPADDFractal::Prev(CDKBarTag& _bar_tag, const int _idx) {
  for(int idx = _idx; idx < LEVELS_INITIAL_BUFFER_SIZE; idx++) {
    double val = Main(idx);
    if(val > 0.0) {
      _bar_tag.Init(this.m_symbol, this.m_period);
      _bar_tag.SetIndexAndValue(idx, val);
      return true;
    }
  }
  return false;
}

bool CiPADDFractal::Next(CDKBarTag& _bar_tag, const int _idx) {
  for(int idx = _idx; idx >= 0; idx--) {
    double val = Main(idx);
    if(val > 0.0) {
      _bar_tag.Init(this.m_symbol, this.m_period);
      _bar_tag.SetIndexAndValue(idx, val);
      return true;
    }
  }
  return false;
}