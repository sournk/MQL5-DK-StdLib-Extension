//+------------------------------------------------------------------+
//|                                                CDKSymbolInfo.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Trade\SymbolInfo.mqh>

class CDKSymbolInfo : public CSymbolInfo {
public:
  int                 PriceToPoints(const double aPrice);           // Convert aPrice to price value for current Symbol
  double              PointsToPrice(const int aPoint);              // Convert aPoint to points for current Symbol
};


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Price Operations
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Convert aPrice to price value for current Symbol                 |
//+------------------------------------------------------------------+
int CDKSymbolInfo::PriceToPoints(const double aPrice) {
  return((int)(aPrice * MathPow(10, this.Digits())));
}

//+------------------------------------------------------------------+
//| Convert aPoint to points for current Symbol                      |
//+------------------------------------------------------------------+
double CDKSymbolInfo::PointsToPrice(const int aPoint) {
  return(NormalizeDouble(aPoint * this.Point(), this.Digits()));
}