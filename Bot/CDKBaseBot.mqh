//+------------------------------------------------------------------+
//|                                                   CDKBaseBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Object.mqh>
#include <Arrays\ArrayLong.mqh>

#include "..\Logger\CDKLogger.mqh"
#include "..\TradingManager\CDKTrade.mqh"
#include "..\TradingManager\CDKPositionInfo.mqh"
#include "..\NewBarDetector\DKNewBarDetector.mqh"

class CDKBaseBot : public CObject {
 protected:
  CDKSymbolInfo            Sym;
  ENUM_TIMEFRAMES          TF;
  ulong                    Magic;
  CDKLogger                Logger;
  CDKTrade                 Trade;

  CDKNewBarDetector        NewBarDetector;

  CArrayLong               Poses;
  CArrayLong               Orders;

 public:
  bool                     CommentEnable;
  uint                     CommentIntervalSec;
  datetime                 CommentLastUpdate;
  string                   CommentText;

  void                     CDKBaseBot::Init(const string _sym,
                                            const ENUM_TIMEFRAMES _tf,
                                            const ulong _magic,
                                            CDKTrade& _trade,
                                            CDKLogger* _logger = NULL);
  virtual void             CDKBaseBot::InitChild()=NULL;
                                        
  bool                     CDKBaseBot::Check(void);



  // Get all market poses and orders
  void                     CDKBaseBot::LoadMarketPos();
  void                     CDKBaseBot::LoadMarketOrd();
  void                     CDKBaseBot::LoadMarket();
  
  // Comment
  void                     CDKBaseBot::SetComment(const string _comment);
  void                     CDKBaseBot::ShowComment();

  // Event Handlers
  void                     CDKBaseBot::OnTick(void);
  virtual void             CDKBaseBot::OnBar(void)=NULL;
  void                     CDKBaseBot::OnTrade(void);
  void                     CDKBaseBot::OnTimer(void);

  void                     CDKBaseBot::CDKBaseBot(void);
};


//+------------------------------------------------------------------+
//| Set comment text
//| To show comment is using ShowComment func
//+------------------------------------------------------------------+
void CDKBaseBot::SetComment(const string _comment) {
  CommentText = _comment;
}

//+------------------------------------------------------------------+
//| Update current grid status
//+------------------------------------------------------------------+
void CDKBaseBot::ShowComment() {
  if (!CommentEnable) return;
  if (CommentText == "") return;
  if (TimeCurrent() < CommentLastUpdate+CommentIntervalSec) return; // Wait comment update interval

  Comment(CommentText);
  CommentLastUpdate = TimeCurrent();
}


//+------------------------------------------------------------------+
//| Constructor                                                                  |
//+------------------------------------------------------------------+
void CDKBaseBot::CDKBaseBot(void) {
  Logger.Init("CDKBaseBot", NO);
}

//+------------------------------------------------------------------+
//| Init Bot
//+------------------------------------------------------------------+
void CDKBaseBot::Init(const string _sym,
                      const ENUM_TIMEFRAMES _tf,
                      const ulong _magic,
                      CDKTrade& _trade,
                      CDKLogger* _logger = NULL) {
  MathSrand(GetTickCount());

  if (_logger != NULL) Logger = _logger; // Set custom logger

  Sym.Name(_sym);
  TF = _tf;
  Magic = _magic;
  Trade = _trade;
  Trade.SetExpertMagicNumber(Magic);

  CommentText = "";
  CommentIntervalSec = 1*60; // 1 min
  CommentLastUpdate = 0;
  CommentEnable = true;
  if ((MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) || MQLInfoInteger(MQL_OPTIMIZATION)) CommentEnable = false;

  InitChild();
  
  // Bar detector init
  NewBarDetector.AddTimeFrame(TF);
  NewBarDetector.ResetAllLastBarTime();
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CDKBaseBot::Check(void) {
  bool res = true;
  // Проверим режим счета. Нужeн ОБЯЗАТЕЛЬНО ХЕДЖИНГОВЫЙ счет
  CAccountInfo acc;
  if(acc.MarginMode() != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
    logger.Error("Only hedging mode allowed", true);
    res = false;
  }

  if(!Sym.Name(Symbol())) {
    logger.Error(StringFormat("Symbol %s is not available", Symbol()), true);
    res = false;
  }

  return res;
}

//+------------------------------------------------------------------+
//| Loads pos from market
//+------------------------------------------------------------------+
void CDKBaseBot::LoadMarketPos() {
  Poses.Clear();

  CDKPositionInfo pos;
  for (int i=0; i<PositionsTotal(); i++) {
    if (!pos.SelectByIndex(i)) continue;
    if (pos.Magic() != Magic) continue;
    if (pos.Symbol() != Sym.Name()) continue;

    Poses.Add(pos.Ticket());
  }
}

//+------------------------------------------------------------------+
//| Loads orders from market
//+------------------------------------------------------------------+
void CDKBaseBot::LoadMarketOrd() {
  Orders.Clear();

  COrderInfo order;
  for (int i=0; i<OrdersTotal(); i++) {
    if (!order.SelectByIndex(i)) continue;
    if (order.Magic() != Magic) continue;
    if (order.Symbol() != Sym.Name()) continue;

    Orders.Add(order.Ticket());
  }
}

//+------------------------------------------------------------------+
//| Loads market poses and orders
//+------------------------------------------------------------------+
void CDKBaseBot::LoadMarket() {
  LoadMarketPos();
  LoadMarketOrd();
}


//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CDKBaseBot::OnTick(void) {
  if (NewBarDetector.CheckNewBarAvaliable(TF)) {
    if (DEBUG >= Logger.Level) Logger.Debug(StringFormat("%s/%d: New bar detected: TF=%s",
                                              __FUNCTION__, __LINE__,
                                              TimeframeToString(TF)));
    OnBar();
  }

  ShowComment();
}


//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CDKBaseBot::OnTrade(void) {
  LoadMarket();
  ShowComment();
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CDKBaseBot::OnTimer(void) {
  ShowComment();
}
//+------------------------------------------------------------------+
