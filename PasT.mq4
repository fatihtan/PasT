//+------------------------------------------------------------------+
//|                                                         PasT.mq4 |
//|                            Copyright 2022, Dixie7 Software Corp. |
//|                                           https://www.dixie7.com |
//+------------------------------------------------------------------+
#property strict


int RequiredClosingBarsAfterCross = 1;
int NonLagMAPeriod = 180;

int orderType = -1;
bool isFirstOrderExecuted = false;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
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
         nonLagMAControl();
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

void nonLagMAControl()
{
   double nlmaVal_0 = getNonLagMAValue(0);
   double nlmaVal_1 = getNonLagMAValue(1);
   
   if(non_lag_ma == 0){
      return;
   }
   
   Print("NonLagMA: ", non_lag_ma, "High: ", High[ix]);
   int order_type;
   if(Bid > non_lag_ma) // Open Buy Order
   {
      order_type=0;
   }
   if(Bid < non_lag_ma)  // Open Sell Order
   {
      order_type=1;
   }
   
   Print(order_type);
}

double getNonLagMAValue(int barIndex){
   return iCustom(Symbol(), 0, "NonLagMA", 0, NonLagMAPeriod, barIndex, 0, 1, 2, 0, 0);
}