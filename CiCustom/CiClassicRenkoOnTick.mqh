//+------------------------------------------------------------------+
//|                                         CiClassicRenkoOnTick.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|                                                                  |
//| Based on: https://www.mql5.com/en/forum/335975                   |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"

#define CLASSICRENKOONTICK_INDICATOR_NAME "ClassicRenkoOnTick-MT5-Ind"
#define CLASSICRENKOONTICK_INDICATOR_BUFFER_COUNT 10
#define LEVELS_INITIAL_BUFFER_SIZE 2048

enum ENUM_PRICE_SOURCE {
  PRICE_SOURCE_ASK = 0, // Ask
  PRICE_SOURCE_BID = 1, // Bid
};


enum ENUM_BAR_TYPE {
  BAR_TYPE_BEARISH = -1,
  BAR_TYPE_UNKNOWN = +0,
  BAR_TYPE_BULLISH = +1,  
};

//  Classic           Offset
//   ↑↓    ↑           ↑   ↑
//  ↑  ↓  ↑           ↑ ↓ ↑
// ↑    ↓↑           ↑   ↓
enum ENUM_RENKO_TYPE {
  RENKO_TYPE_CLASSIC = 0, // Classic
  RENKO_TYPE_OFFSET = 1, // Offset
};

class CiClassicRenkoOnTick : public CiCustom {
protected:
  virtual bool      Initialize(const string symbol, 
                               const ENUM_TIMEFRAMES period, 
                               const int num_params, 
                               const MqlParam &params[]
                    ) override;  
public:
  virtual bool      Create(string _symbol, 
                           ENUM_TIMEFRAMES _period,
                           uint _BrickSizePoints,
                           ENUM_RENKO_TYPE _SET_REN_TYP,
                           ENUM_PRICE_SOURCE _PriceSource,
                           uint _HistoryDepthSec,
                           uint _BarLimitCnt,
                           bool _ShowWarning
                           ); 
                            
  virtual double     Open(int index) { return this.GetData(0, index); }
  virtual double     Close(int index) { return this.GetData(3, index); }
  virtual ENUM_BAR_TYPE BarType(int index) { 
    if(Close(0) > Open(0)) return BAR_TYPE_BULLISH;
    if(Close(0) < Open(0)) return BAR_TYPE_BEARISH;
    return BAR_TYPE_UNKNOWN;
  }
  virtual int        Color(int index) { return (int)this.GetData(4, index); }
  virtual datetime   Time(int index) { return (datetime)this.GetData(5, index); }
  virtual long       TimeMS(int index) { return (long)this.GetData(5, index); }
  virtual int        DurationMS(int index) { return (int)this.GetData(6, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiClassicRenkoOnTick::Create(string _symbol, 
                                  ENUM_TIMEFRAMES _period, 
                                  uint _BrickSizePoints,
                                  ENUM_RENKO_TYPE _SET_REN_TYP,
                                  ENUM_PRICE_SOURCE _PriceSource,
                                  uint _HistoryDepthSec,                                  
                                  uint _BarLimitCnt,
                                  bool _ShowWarning) {
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(CLASSICRENKOONTICK_INDICATOR_NAME, TYPE_STRING)
         .Set(_BrickSizePoints, TYPE_UINT)
         .Set(_PriceSource, TYPE_UINT)
         .Set(_SET_REN_TYP, TYPE_UINT)
         .Set(_HistoryDepthSec, TYPE_UINT)
         .Set(_BarLimitCnt, TYPE_UINT)
         .Set(_ShowWarning, TYPE_BOOL);
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
bool CiClassicRenkoOnTick::Initialize(const string symbol, 
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