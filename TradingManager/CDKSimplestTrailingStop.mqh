//+------------------------------------------------------------------+
//|                                      CDKSimplestTrailingStop.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

#include <DKStdLib\TradingManager\CDKSymbolInfo.mqh>

uint TRADE_RETCODE_CUSTOM_NOTHING_TO_CHANGE                = 20001;  // Didn't pass SL or TP to change
uint TRADE_RETCODE_CUSTOM_ACTIVATION_PRICE_NOT_REACHED     = 20002;  // Activastions price has not reached yet. SL or TP didn't change
uint TRADE_RETCODE_CUSTOM_PRICE_NOT_BETTER                 = 20003;  // Price didn't get better. Leave current SL and TP with no changes

class CDKSimplestTrailingStop : public CPositionInfo {

protected:
  CTrade                    m_trade;
  CDKSymbolInfo             m_symbol;
  double                    m_activation_price;
  double                    m_distance;
  int                       m_distance_point;
  
  double                    getMarketPriceToClosePos();                                // For BUY returns Ask and for SELL Bid
  bool                      isPriceBetter(const double aPriceToCheck,                  // Checks what aPriceToCheck is better than aPriceToCompareWith  
                                          const double aPriceToCompareWith);   
  bool                      isPriceBetterAskBid(const double aPriceToCompareWith);     // Check is aPriceToCheck greater or equal than Ask or Bid
  
public:
                            // Init Trailing Stop
  void                      Init(const double aActivationPrice,     // Price to activate Trailing Stop
                                 const double aDistance,            // Price distance to SL                          
                                 CTrade& aTrade);                   // Preconfigurated CTrade object to make SL/TP update
  void                      Init(const double aActivationPrice,     // Price to activate Trailing Stop
                                 const int aDistancePoint,          // Price distance to SL in points
                                 CTrade& aTrade);                   // Preconfigurated CTrade object to make SL/TP update
                                                    
  double                    getActivationPrice();                                      // Return current Activation Price
  double                    getDistance();                                             // Return current Distance
  int                       getDistancePoint();                                        // Return current Distance in points
                                                    
  uint                      updateTrailingStop(const bool aUpdateSL = true,            // Moves SL by Trailing conditions
                                               const bool aUpdateTP = true);           // You can Trail SL and/or TP. Return CTrade.ResultRetcode(). TRADE_RETCODE_DONE=10009=OK
};

void CDKSimplestTrailingStop::Init(const double aActivationPrice,     
                                   const double aDistance,
                                   CTrade& aTrade) {
  m_trade = aTrade;
  m_symbol.Name(this.Symbol());

  m_activation_price = aActivationPrice;
  m_distance         = aDistance;
  m_distance_point   = m_symbol.PriceToPoints(m_distance);
}

void CDKSimplestTrailingStop::Init(const double aActivationPrice,     
                                   const int aDistancePoint,
                                   CTrade& aTrade) {
  m_trade = aTrade;
  m_symbol.Name(this.Symbol());

  m_activation_price = aActivationPrice;
  m_distance_point   = aDistancePoint;
  m_distance         = m_symbol.PointsToPrice(m_distance_point);
  m_distance_point   = m_symbol.PriceToPoints(m_distance);
}

double CDKSimplestTrailingStop::getActivationPrice() {
  return m_activation_price;
}

double CDKSimplestTrailingStop::getDistance() {
  return m_distance;
}

int CDKSimplestTrailingStop::getDistancePoint() {
  return m_distance_point;
}

double CDKSimplestTrailingStop::getMarketPriceToClosePos() {
  if (!m_symbol.RefreshRates()) return 0;  // Rates is not refreshed  
  
  if (this.PositionType() == POSITION_TYPE_BUY)  return m_symbol.Bid(); // IMPORTANT! Use Bid for BUY pos,  becase we gonna close pos. To do that we must SELL
  if (this.PositionType() == POSITION_TYPE_SELL) return m_symbol.Ask(); // IMPORTANT! Use Ask for SELL pos, becase we gonna close pos. To do that we must BUY
  return 0;   
}

bool CDKSimplestTrailingStop::isPriceBetter(const double aPriceToCheck,
                                            const double aPriceToCompareWith) {
  if (this.PositionType() == POSITION_TYPE_BUY  && aPriceToCheck > aPriceToCompareWith) return true;
  if (this.PositionType() == POSITION_TYPE_SELL && aPriceToCheck < aPriceToCompareWith) return true;
   
  return false;
}

bool CDKSimplestTrailingStop::isPriceBetterAskBid(const double aPriceToCompareWith) {
  double currPrice = getMarketPriceToClosePos();
  if (currPrice <= 0) return false;  // Illegal market price
  
  return isPriceBetter(currPrice, aPriceToCompareWith);   
}
                             
uint CDKSimplestTrailingStop::updateTrailingStop(const bool aUpdateSL = true, 
                                                 const bool aUpdateTP = true) {
  if (!(aUpdateSL || aUpdateTP)) return TRADE_RETCODE_CUSTOM_NOTHING_TO_CHANGE; // Nothing to change

  // Activation price is disables (=0) or AskBid is better
  if (!(m_activation_price <= 0 || isPriceBetterAskBid(m_activation_price))) return TRADE_RETCODE_CUSTOM_ACTIVATION_PRICE_NOT_REACHED;
  
  double currMarketPrice = getMarketPriceToClosePos();
  
  double currSL = this.StopLoss();
  double newSL = currMarketPrice + ((this.PositionType() == POSITION_TYPE_BUY) ? -1 : +1) * m_distance;
  newSL = NormalizeDouble(newSL, m_symbol.Digits());
  
  double currTP = this.TakeProfit();
  double newTP = currMarketPrice + ((this.PositionType() == POSITION_TYPE_BUY) ? +1 : -1) * m_distance;
  newTP = NormalizeDouble(newTP, m_symbol.Digits());
  
  if (!(aUpdateSL && isPriceBetter(newSL, currSL))) newSL = currSL;
  if (!(aUpdateTP && isPriceBetter(newTP, currTP))) newTP = currTP;
  
  if (newSL == currSL && newTP == currTP) return TRADE_RETCODE_CUSTOM_PRICE_NOT_BETTER; // Not changes of TP and SL
  
  m_trade.PositionModify(this.Ticket(), newSL, newTP);
  return m_trade.ResultRetcode();
}

