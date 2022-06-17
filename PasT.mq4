//+------------------------------------------------------------------+
//|                                                         PasT.mq4 |
//|                            Copyright 2022, Dixie7 Software Corp. |
//|                                           https://www.dixie7.com |
//+------------------------------------------------------------------+
#property strict


int RequiredClosingBarsAfterCross = 1;
int NonLagMAPeriod = 180;
int ADXPeriod = 14;
int ADXCrossLevel = 20;

int orderType = -1;
bool isFirstOrderExecuted = false;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
   Print("OrderType: " + OrderType());
   Print("OP_BUY " + OP_BUY );
   Print("OP_SELL " + OP_SELL );
   Print("OP_BUYLIMIT " + OP_BUYLIMIT );
   Print("OP_BUYSTOP " + OP_BUYSTOP );
   Print("OP_SELLLIMIT " + OP_SELLLIMIT );
   Print("OP_SELLSTOP " + OP_SELLSTOP );
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   static datetime tmp;
   if(tmp != Time[0])
   {
      tmp = Time[0];
      
      if(OrdersTotal() == 0)
      {
         //controlSignal();
      }
      else
      {
         //closeOrder();
      }
   }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+

bool controlSignal(){
   bool control_NonLagMA = nonLagMAControl();
   
   
   return false;
}

// ADX
bool controlADX(){
   double adxVal_0 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_MAIN, 0);
   double adxVal_1 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_MAIN, 1);
   
   // Tolerance difference may be calculated in the future.
   if(adxVal_0 > adxVal_1 && adxVal_0 > ADXCrossLevel){
      return true;
   }
   
   return false;
}

// NonLagMA
int nonLagMAControl()
{
   double nlmaVal_0 = getNonLagMAValue(0);
   double nlmaVal_1 = getNonLagMAValue(1);
   double nlmaVal_2 = getNonLagMAValue(2);
   
   if(nlmaVal_0 == 0 || nlmaVal_1 == 0){
      return -1;
   }
   
   // Buy Check
   if(nonLagMABuyControl(nlmaVal_0, nlmaVal_1, nlmaVal_2)){
      return OP_BUY;
   }
   
   // Sell Check
   else if(nonLagMASellControl(nlmaVal_0, nlmaVal_1, nlmaVal_2)){
      return OP_SELL;
   }
   
   // Signal Not Found
   return -1;
}

double getNonLagMAValue(int barIndex){
   return iCustom(Symbol(), 0, "NonLagMA", 0, NonLagMAPeriod, barIndex, 0, 1, 2, 0, 0);
}

bool nonLagMABuyControl(double val0, double val1, double val2){
   return Open[1] < val1 && Close[1] > val1 && Open[0] > val0;
}

bool nonLagMASellControl(double val0, double val1, double val2){
   return Open[1] > val1 && Close[1] < val1 && Open[0] < val0;
}