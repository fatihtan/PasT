//+------------------------------------------------------------------+
//|                                                         PasT.mq4 |
//|                            Copyright 2022, Dixie7 Software Corp. |
//|                                           https://www.dixie7.com |
//+------------------------------------------------------------------+
#property strict


extern int NonLagMAPeriodMEDIUM = 180;
extern double LotSize = 0.1;

extern bool EnableTakeProfit = true;
extern double TakeProfit1 = 3.6;
extern double StopLossCoeff = 1.6;
extern double TrailingStopTrigger = 1;
extern double TrailingStopPips = 100;


int RequiredClosingBarsAfterCross = 1;
int NonLagMAPeriodSMALL = 90;
int NonLagMAPeriodLARGE = 270;
int ADXPeriod = 14;
int ADXMainCrossLevel = 20;
int ADXDIPlusCrossLevel = 20;
int ADXDIMinusCrossLevel = 20;

int MinPrice = 2137000000;
int MaxPrice = -2137000000;
bool TriggerTrailingStop = false;

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
         int orderType = controlSignal();
         
         if(orderType != -1){
            openOrder(orderType);
            resetValues();
         }
      }
      else
      {
         if(orderCrossCheck()){
            int orderType = controlSignal();
            Print("OrderType: " + orderType);
            
            if(orderType != -1){
               openOrder(orderType);
               resetValues();
            }
         }
      }
   }
   
   if(OrdersTotal() == 1)
      traceOrder();
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
bool orderCrossCheck(){
   bool isOrderClosed = false;
   if(OrderType() == OP_BUY){
      double nlmaVal_0 = GetNonLagMAValue(NonLagMAPeriodMEDIUM, 0);
      double nlmaVal_1 = GetNonLagMAValue(NonLagMAPeriodMEDIUM, 1);
      bool readyToOut = NonLagMASellControl(nlmaVal_0, nlmaVal_1, 0);
      if(readyToOut){
         isOrderClosed = OrderClose(OrderTicket(), OrderLots(), Bid, 100, clrRed);
      }
   }
   else if(OrderType() == OP_SELL)
   {
      double nlmaVal_0 = GetNonLagMAValue(NonLagMAPeriodMEDIUM, 0);
      double nlmaVal_1 = GetNonLagMAValue(NonLagMAPeriodMEDIUM, 1);
      bool readyToOut = NonLagMABuyControl(nlmaVal_0, nlmaVal_1, 0);
      if(readyToOut){
         isOrderClosed = OrderClose(OrderTicket(), OrderLots(), Ask, 100, clrRed);
      }
   }
   
   return isOrderClosed;
}

void traceOrder(){
   OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
   if(OrderType() == OP_BUY) // Tracing Buy Order
   {
      if(Bid > MaxPrice){
         MaxPrice = Bid;
         
         if(!TriggerTrailingStop){
            double trailingStopTriggerLevel = calculatePricePoint(OrderOpenPrice(), TrailingStopTrigger);
            if(MaxPrice >= trailingStopTriggerLevel)
            {
               double trailingStopLevel = OrderOpenPrice() + (TrailingStopPips * Point * 100);
               
               //Print("SELL:(TrailingStopPips * Point * 10): " + (TrailingStopPips * Point * 010));
               //Print("SELL:Point: " + Point);
               //Print("SELL:trailingStopLevel: " + trailingStopLevel);
               //Print("SELL:OrderOpenPrice(): " + OrderOpenPrice());
               OrderModify(OrderTicket(), OrderOpenPrice(), trailingStopLevel, OrderTakeProfit(), 0, clrRed);
               TriggerTrailingStop = true;
            }
         }
      }
   }
   else if(OrderType() == OP_SELL)
   {
      //Print("Ask: " + Ask + "; MinPrice: " + MinPrice);
      if(Ask < MinPrice){
         MinPrice = Ask;
         
         if(!TriggerTrailingStop){
            double trailingStopTriggerLevel = calculatePricePoint(OrderOpenPrice(), TrailingStopTrigger * -1);
            if(MinPrice <= trailingStopTriggerLevel)
            {
               double trailingStopLevel = OrderOpenPrice() - (TrailingStopPips * Point * 100);
               
               //Print("SELL:(TrailingStopPips * Point * 10): " + (TrailingStopPips * Point * 010));
               //Print("SELL:Point: " + Point);
               //Print("SELL:trailingStopLevel: " + trailingStopLevel);
               //Print("SELL:OrderOpenPrice(): " + OrderOpenPrice());
               OrderModify(OrderTicket(), OrderOpenPrice(), trailingStopLevel, OrderTakeProfit(), 0, clrRed);
               TriggerTrailingStop = true;
            }
         }
      }
   }
}

void openOrder(int orderType){
   RefreshRates();
   if(orderType == OP_BUY){
      double tp = 0;
      if(EnableTakeProfit){
         tp = calculatePricePoint(Bid, TakeProfit1);
      }
      
      OrderSend(Symbol(), OP_BUY, LotSize, Ask, 100, 0, tp, NULL, 0, 0, clrGreen);
   }
   else if(orderType == OP_SELL){
      double tp = 0;
      if(EnableTakeProfit){
         tp = calculatePricePoint(Ask, TakeProfit1 * -1);
      }
      OrderSend(Symbol(), OP_SELL, LotSize, Ask, 100, 0, tp, NULL, 0, 0, clrGreen);
   }
}

double calculatePricePoint(double price, double coeff){
   return ((price * coeff) / 100) + price;
}

int controlSignal(){
   int control_NonLagMA = NonLagMAControl();
   bool control_ADX = true || ADXControl();
   
   if(control_NonLagMA != -1 && control_ADX){
      return control_NonLagMA;
   }
   
   return -1;
}

bool ADXControl(){
   return ADXMainAngleControl();
}

// ADX
bool ADXMainAngleControl(){
   double adxVal_0 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_MAIN, 0);
   double adxVal_1 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_MAIN, 1);
   
   // Tolerance difference may be calculated in the future.
   if(adxVal_0 > adxVal_1 && adxVal_0 > ADXMainCrossLevel){
      return true;
   }
   
   return false;
}

int ADXDIPlusControl(){
   double adxDIPlusVal_0 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_PLUSDI, 0);
   double adxDIPlusVal_1 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_PLUSDI, 1);
   
   // Tolerance difference may be calculated in the future.
   if(adxDIPlusVal_0 > adxDIPlusVal_1 && adxDIPlusVal_0 > ADXDIPlusCrossLevel){
      return true;
   }
   
   return false;
}

int ADXDIMinusControl(){
   double adxDIMinusVal_0 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_MINUSDI, 0);
   double adxDIMinusVal_1 = iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, MODE_MINUSDI, 1);
   
   // Tolerance difference may be calculated in the future.
   if(adxDIMinusVal_0 > adxDIMinusVal_1 && adxDIMinusVal_0 > ADXDIMinusCrossLevel){
      return true;
   }
   
   return false;
}

// NonLagMA
int NonLagMAControl()
{
   double nlmaVal_0 = GetNonLagMAValue(NonLagMAPeriodMEDIUM, 0);
   double nlmaVal_1 = GetNonLagMAValue(NonLagMAPeriodMEDIUM, 1);
   //double nlmaVal_2 = GetNonLagMAValue(NonLagMAPeriodMEDIUM, 2);
   
   if(nlmaVal_0 == 0 || nlmaVal_1 == 0){
      return -1;
   }
   
   // Buy Check
   if(NonLagMABuyControl(nlmaVal_0, nlmaVal_1, 0)){
      return OP_BUY;
   }
   
   // Sell Check
   else if(NonLagMASellControl(nlmaVal_0, nlmaVal_1, 0)){
      return OP_SELL;
   }
   
   // Signal Not Found
   return -1;
}

double GetNonLagMAValue(int period, int barIndex){
   return iCustom(Symbol(), 0, "NonLagMA", 
      0,          // Price
      period,     // Period
      0,          // Displace
      0,          // PctFilter
      0,          // Color
      2,          // ColorBarBack
      0,          // Deviation
      0,          // Buffer
      barIndex    // BarIndex & Shifting
      );
}

bool NonLagMABuyControl(double val0, double val1, double val2){
   return (Open[1] < val1 && Close[1] > val1 && Open[0] > val0) || (Open[1] < val1 && Close[1] < val1 && Open[0] > val0);
}

bool NonLagMASellControl(double val0, double val1, double val2){
   return (Open[1] > val1 && Close[1] < val1 && Open[0] < val0) || (Open[1] > val1 && Close[1] > val1 && Open[0] < val0);
}

void resetValues(){
   MinPrice = 2137000000;
   TriggerTrailingStop = false;
}