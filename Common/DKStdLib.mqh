//+------------------------------------------------------------------+
//|                                                     DKStdLib.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>


enum ENUM_MM_TYPE {
  ENUM_MM_TYPE_FIXED_LOT,                 // Fixed lot
  ENUM_MM_TYPE_BALANCE_PERCENT,           // % of balance
  ENUM_MM_TYPE_FREE_MARGIN_PERCENT,       // % of free margin
  ENUM_MM_TYPE_AUTO_LIMIT_RISK            // Auto (limit % of risk)
};

// Copyrignt to https://www.mql5.com/en/forum/150265/page4#comment_14444426
const string _uniqueSeedVarName = "c1b2effa-9855-4bc8-a29d-7546faefde8b";
string GetUniqueInstanceName(const string baseName) {
  uint seed = 1;

  // See if our last stored unique seed value exists
  if (GlobalVariableCheck(_uniqueSeedVarName)) {
    // It does, so get it
    seed = (uint)GlobalVariableGet(_uniqueSeedVarName);

    // Do some boundary checking and ensure the user didn't muck with the value
    // If we're okay, increment the seed by one
    if (seed > 0 && seed < UINT_MAX)
      seed = seed + 1;
    else
      // The seed has been corrupted by the user or is too large; reset to current tick count
      seed = GetTickCount();
  } else
    // First time in; initialize the seed to the current tick count
    seed = GetTickCount();

  // Store the value in global terminal variables
  // The user DOES have access to this value, so the handling above should account for any changes the user might make
  GlobalVariableSet(_uniqueSeedVarName, seed);

  // Initialize the random generator
  MathSrand(seed);

  // Create a unique instance name in the format of "[BaseName][Random1][Random2]"
  return StringFormat("%s%s%s", baseName, IntegerToString(MathRand()), IntegerToString(MathRand()));
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLot(string aSymbol, double lot) {
  CSymbolInfo symbol;
  if (symbol.Name(aSymbol)) {
    lot =  NormalizeDouble(lot, symbol.Digits());
    double lotStep = symbol.LotsStep();
    return floor(lot / lotStep) * lotStep;
  }
  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLotFilterMinMax(string aSymbol, double lot) {
  CSymbolInfo symbol;

  double useLot = 0;
  if (symbol.Name(aSymbol)) {
    double maxLot  = symbol.LotsMax();
    double minLot  = symbol.LotsMin();
    double lotStep = symbol.LotsStep();

    useLot  = minLot;
    if(lot > useLot) {
      if(lot > maxLot) useLot = maxLot;
      else useLot = floor(lot / lotStep) * lotStep;
    }

  }
  return useLot;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Money Managment and Lot size calculation
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Calculates Lots by MM type                                       |
//+------------------------------------------------------------------+
double CalculateLots(const string aSymbol,
                     const ENUM_MM_TYPE aMMType,
                     const double aMMValue,
                     const double aStopLoss = 0,
                     const double aPrice = 0) {

  double result = 0.0;

  CSymbolInfo symbol;
  if (!symbol.Name(aSymbol)) return result;

  double lotStep = symbol.LotsStep();
  double minLot = symbol.LotsMin();
  double maxLot = symbol.LotsMax();

  CAccountInfo account;
  if(aMMType == ENUM_MM_TYPE_FIXED_LOT) result = NormalizeDouble(aMMValue, 2);
  if(aMMType == ENUM_MM_TYPE_BALANCE_PERCENT) result = MathFloor(account.Balance() * aMMValue / 100 / aPrice);
  if(aMMType == ENUM_MM_TYPE_FREE_MARGIN_PERCENT) result = MathFloor(account.FreeMargin() * aMMValue / 100 / aPrice);
  if(aMMType == ENUM_MM_TYPE_AUTO_LIMIT_RISK) { 
    double base = MathMin(account.Equity(), account.Balance());
    //result = ((base - account.Credit()) * (aMMValue / 100)) / PointsToPrice(aSymbol, aStopLoss) / symbol.ContractSize(); 
    result = ((base - account.Credit()) * (aMMValue / 100)) / aStopLoss; 
   }  

  if (lotStep != 0) result = MathFloor(result / lotStep) * lotStep; 
  result = NormalizeDouble(MathMin(MathMax(result, minLot), maxLot), 2);
  return(result);
}   

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Money Managment and Lot size calculation
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceToPoints(string aSymbol, double aValue) {
  CSymbolInfo symbol;
  if(symbol.Name(aSymbol)) return((int)(aValue * MathPow(10, symbol.Digits())));
  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PointsToPrice(string aSymbol, int aValue) {
  CSymbolInfo symbol;
  if(symbol.Name(aSymbol)) return(NormalizeDouble(aValue * symbol.Point(), symbol.Digits()));
  return 0;
}

bool CompareDouble(double a, double b)
{       
  return (fabs(a-b)<=DBL_MIN+8*DBL_EPSILON*fmax(fabs(a),fabs(b)));
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| EA EVENTS
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Checks autotrading is avaliable                                  |
//+------------------------------------------------------------------+
bool IsAutoTradingEnabled() {
  // https://www.mql5.com/en/docs/runtime/tradepermission

  if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return(false);
  if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) return(false);
  if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) return(false);

  return(true);
}

//+------------------------------------------------------------------+
//| Refreshes rates                                                  |
//+------------------------------------------------------------------+
bool RefreshRates(string aName) {
  CSymbolInfo symbol;
  
  if(!symbol.Name(aName)) return false;
  if(!symbol.RefreshRates()) return false;
  if((0 == symbol.Ask()) || (0 == symbol.Bid())) return false;

  return true;
}