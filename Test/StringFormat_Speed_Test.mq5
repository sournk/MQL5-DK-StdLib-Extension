//+------------------------------------------------------------------+
//|                                      StringFormat_Speed_Test.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "1.00"



string TestStringFormat(const int _cnt) {
  string str = "";
  for(int i=1;i<=_cnt;i++)    {
    str = StringFormat("%s/%d: String: %d", 
                       __FUNCTION__, __LINE__,
                       i);
  }
  
  return str;
}

string TestStringConcatFuncCasting(const int _cnt) {
  string str = "";
  for(int i=1;i<=_cnt;i++)    {
    str = __FUNCTION__ + "/" + IntegerToString(__LINE__) + ": String: " + IntegerToString(i);
  }
  
  return str;
}

string TestStringConcatTypeCasting(const int _cnt) {
  string str = "";
  for(int i=1;i<=_cnt;i++)    {
    str = __FUNCTION__ + "/" + string(__LINE__) + ": String: " + string(i);
  }
  
  return str;
}


string TestStringConcat(const int _cnt) {
  string str = "";
  for(int i=1;i<=_cnt;i++){
    str = __FUNCTION__ + "/" + __LINE__ + ": String: " + i;
  }
  
  return str;
}


string DKStringFormat(string _fmt, string& val[]) {
  int size = ArraySize(val);
  for(int i=0;i<size;i++) {
    StringReplace(_fmt, "{"+(i+1)+"}", val[i]);
  }
  return _fmt;
}

string TestDKStringFormat(const int _cnt) {
  string str = "";
  
  for(int i=1;i<=_cnt;i++)    {
    string param[] = {__FUNCTION__, __LINE__, i}; 
    str = DKStringFormat("{1}/{2}: String: {3}", param);
  }
  
  return str;
}


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  ulong tick_start = 0;
  
  string str = "";
  int cnt = 5000000;
  
  tick_start = GetTickCount64();
  str = TestStringFormat(cnt);
  Print("TestStringFormat: ", str, " ", GetTickCount64()-tick_start);
  
  tick_start = GetTickCount64();
  str = TestStringConcat(cnt);
  Print("TestStringConcat: ", str, " ", GetTickCount64()-tick_start);
  
  tick_start = GetTickCount64();
  str = TestStringConcatFuncCasting(cnt);
  Print("TestStringConcatFuncCasting: ", str, " ", GetTickCount64()-tick_start);
  
  tick_start = GetTickCount64();
  str = TestStringConcatTypeCasting(cnt);
  Print("TestStringConcatTypeCasting: ", str, " ", GetTickCount64()-tick_start);  
  
  tick_start = GetTickCount64();
  str = TestDKStringFormat(cnt);
  Print("TestDKStringFormat: ", str, " ", GetTickCount64()-tick_start);  
  
}

