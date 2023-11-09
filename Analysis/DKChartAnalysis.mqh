//+------------------------------------------------------------------+
//|                                              DKChartAnalysis.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Trade\SymbolInfo.mqh>
#include <DKStdLib\Common\DKStdLib.mqh>

enum ENUM_PRICETAG_COMPARE_MODE {
  ENUM_PRICETAG_COMPARE_MODE_PRICE_LT = 10,
  ENUM_PRICETAG_COMPARE_MODE_PRICE_LE = 11,
  ENUM_PRICETAG_COMPARE_MODE_PRICE_GT = 12,
  ENUM_PRICETAG_COMPARE_MODE_PRICE_GE = 13,
  ENUM_PRICETAG_COMPARE_MODE_PRICE_EQ = 14,
  ENUM_PRICETAG_COMPARE_MODE_PRICE_NE = 15
};

//+------------------------------------------------------------------+
//| Price tag structure to use with CArrayObj                        |
//+------------------------------------------------------------------+
class CPriceTag : public CObject {
 public:
  string                    symbol;          // Whick symbol has a price tag
  ENUM_TIMEFRAMES           period;          // Which period price tag belongs to
  long                      barIndex;        // Bar index of price tag
  datetime                  dt;              // Datetime of price tag

  double                    price;           // Price of a tag

  CPriceTag(void) {};
  CPriceTag(string aSymbol, ENUM_TIMEFRAMES aPeriod, ulong aBarIndex, datetime aDT, double aPrice) {
    symbol = aSymbol;
    period = aPeriod;
    barIndex = aBarIndex;
    dt = aDT;
    price = aPrice;
  };

  int                Compare(const CObject *node, const int mode = 0) const {
    const CPriceTag *t = node;
    if(mode == ENUM_PRICETAG_COMPARE_MODE_PRICE_LT && this.price < t.price)  return(1);
    if(mode == ENUM_PRICETAG_COMPARE_MODE_PRICE_LE && this.price <= t.price) return(1);
    if(mode == ENUM_PRICETAG_COMPARE_MODE_PRICE_GT && this.price > t.price)  return(1);
    if(mode == ENUM_PRICETAG_COMPARE_MODE_PRICE_GE && this.price >= t.price) return(1);
    if(mode == ENUM_PRICETAG_COMPARE_MODE_PRICE_EQ && this.price == t.price) return(1);
    if(mode == ENUM_PRICETAG_COMPARE_MODE_PRICE_NE && this.price != t.price) return(1);
    return(-1);
  }
};

//+------------------------------------------------------------------+
//| Get value of buffers                                             |
//+------------------------------------------------------------------+
double iGetArray(const int handle, const int buffer, const int start_pos, const int count, double &arr_buffer[]) {
  bool result = true;
  if(!ArrayIsDynamic(arr_buffer)) {
    Print("This a no dynamic array!");
    return(false);
  }
  ArrayFree(arr_buffer);
//--- reset error code
  ResetLastError();
//--- fill a part of the iBands array with values from the indicator buffer
  int copied = CopyBuffer(handle, buffer, start_pos, count, arr_buffer);
  if(copied != count) {
    //--- if the copying fails, tell the error code
    PrintFormat("Failed to copy data from the indicator, error code %d", GetLastError());
    //--- quit with zero result - it means that the indicator is considered as not calculated
    return(false);
  }
  return(result);
}

//+------------------------------------------------------------------+
//| Get ZigZag prices as CArrayObj of CPriceTag                      |
//+------------------------------------------------------------------+
int GetExteremsByZigZag(string aSymbol,
                        ENUM_TIMEFRAMES aPeriod,
                        int aZigZagDepth,
                        int aZigZagDeviation,
                        int aZigZagBackstep,
                        int aBarStart,
                        int aBarShiftToDetectEtremes,
                        CArrayObj &priceTagArray,
                        string anIndicatorPath = "Examples\\ZigZag") {
  priceTagArray.Clear();
  int handle_iCustom = iCustom(aSymbol, aPeriod, anIndicatorPath, aZigZagDepth, aZigZagDeviation, aZigZagBackstep);
  double ZigzagBuffer[];
  ArraySetAsSeries(ZigzagBuffer, true);
  int start_pos = aBarStart;
  int count = aBarShiftToDetectEtremes + 1;
  if(!iGetArray(handle_iCustom, 0, start_pos, count, ZigzagBuffer))
    return 0;
  for(int i = 0; i < count; i++) {
    if(ZigzagBuffer[i] != PLOT_EMPTY_VALUE && ZigzagBuffer[i] != 0.0) {
      CPriceTag *priceTag = new CPriceTag(aSymbol, aPeriod,
                                          i + start_pos,
                                          iTime(aSymbol, aPeriod, i + start_pos),
                                          NormalizeDouble(ZigzagBuffer[i], Digits()));
      priceTagArray.Add(priceTag);
    }
  }
  return priceTagArray.Total();
}

//+------------------------------------------------------------------+
//| Sort out ZigZag prices list to                                   |
//| lowPriceTagList and highPriceTagList                             |
//+------------------------------------------------------------------+
void SortOutZigZagExtremes(CArrayObj &priceTagList,
                           CArrayObj &highPriceTagList,
                           CArrayObj &lowPriceTagList) {
  highPriceTagList.Clear();
  lowPriceTagList.Clear();
  bool isCurrentExtremeHigh = false;
  if(priceTagList.Total() >= 2) {
    CPriceTag *priceTag0 = priceTagList.At(0);
    CPriceTag *priceTag1 = priceTagList.At(1);
    if(priceTag0.Compare(priceTag1, ENUM_PRICETAG_COMPARE_MODE_PRICE_GT) > 0)
      isCurrentExtremeHigh = true;
  }
  for(int i = 0; i < priceTagList.Total(); i++) {
    CPriceTag *currentPriceTag = priceTagList.At(i);
    if(isCurrentExtremeHigh)
      highPriceTagList.Add(currentPriceTag);
    else
      lowPriceTagList.Add(currentPriceTag);
    isCurrentExtremeHigh = !isCurrentExtremeHigh;
  }
}

//+------------------------------------------------------------------+
