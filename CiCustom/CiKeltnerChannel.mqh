//+------------------------------------------------------------------+
//|                                             CiKeltnerChannel.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"
#include "../Common/CDKBarTag.mqh"

#define CLASSICRENKOONTICK_INDICATOR_NAME "Free Indicators/Keltner Channel"
#define CLASSICRENKOONTICK_INDICATOR_BUFFER_COUNT 3
#define LEVELS_INITIAL_BUFFER_SIZE 2048

class CiKeltnerChannel : public CiCustom {
protected:
  virtual bool      Initialize(const string symbol, 
                               const ENUM_TIMEFRAMES period, 
                               const int num_params, 
                               const MqlParam &params[]
                    ) override;  
public:
  virtual bool      Create(string _symbol, 
                           ENUM_TIMEFRAMES _period,
                           
                           uint               _period_ema,
                           uint               _period_atr,
                           double             _atr_mult,
                           bool               _show_price
                           ); 
                            
  virtual double    Upper(int index)  { return this.GetData(0, index); }
  virtual double    Middle(int index) { return this.GetData(1, index); }
  virtual double    Lower(int index)  { return this.GetData(2, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiKeltnerChannel::Create(string             _symbol, 
                              ENUM_TIMEFRAMES    _period, 
                                    
                              uint               _period_ema,
                              uint               _period_atr,
                              double             _atr_mult,
                              bool               _show_price
                              ) {
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(CLASSICRENKOONTICK_INDICATOR_NAME, TYPE_STRING)
         .Set(_period_ema, TYPE_UINT)
         .Set(_period_atr, TYPE_UINT)
         .Set(_atr_mult, TYPE_DOUBLE)
         .Set(_show_price, TYPE_BOOL);
         
   // #2 Call the parent Create method with the params
   if(!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
     return false;
   // #3 Resize the buffer to the desired initial size
   if(!this.BufferResize(LEVELS_INITIAL_BUFFER_SIZE))
     return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiKeltnerChannel::Initialize(const string symbol, 
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