//+------------------------------------------------------------------+
//|                                                         PasT.mq4 |
//|                            Copyright 2022, Dixie7 Software Corp. |
//|                                           https://www.dixie7.com |
//+------------------------------------------------------------------+
#property strict



//---- input parameters

//Apply to Price(0-Close;1-Open;2-High;3-Low;4-Median price;5-Typical price;6-Weighted Close) 
int Price = 0;

//Period of NonLagMA
int Length = 180;

//DispLace or Shift
int Displace = 0;

//Dynamic filter in decimal
double PctFilter = 0;

//Switch of Color mode (1-color)
int Color = 1;

//Bar back for color mode
int ColorBarBack = 1;

//Up/down deviation
double Deviation = 0;


//---- indicator buffers
double NonLagMABuffer[];
double NonLagMAUpBuffer[];
double NonLagMADownBuffer[];
double NonLagMATrend[];
double NonLagMADel[];
double NonLagMAAvgDel[];
double NonLagMAAlpha[];

double PI = 3.1415926535;
int NonLagMAPhase, NonLagMALen, NonLagMACycle=4;
double NonLagMACoeff, NonLagMABeta, NonLagMATVal, NonLagMASum, NonLagMAWeight, NonLagMAGVal;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
   InitNonLagMA();
   
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
   OnTickNonLagMA();
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

void InitNonLagMA(){
   NonLagMACoeff = 3 * PI;
   NonLagMAPhase = Length - 1;
   NonLagMALen = Length * 4 + NonLagMAPhase;
   ArrayResize(NonLagMAAlpha, NonLagMALen);
   NonLagMAWeight = 0;
   
   for (int i=0; i < NonLagMALen - 1; i++)
   {
      if (i <= NonLagMAPhase-1){
         NonLagMATVal = 1.0 * i / (NonLagMAPhase-1);
      }
      else{
         NonLagMATVal = 1.0 + (i - NonLagMAPhase+1) * (2.0 * NonLagMACycle - 1.0) / (NonLagMACycle * Length - 1.0);
      }
      
      NonLagMABeta = MathCos(PI*NonLagMATVal);
      NonLagMAGVal = 1.0 / (NonLagMACoeff * NonLagMATVal + 1);   
      if (NonLagMATVal <= 0.5 ){
         NonLagMAGVal = 1;
      }
      
      NonLagMAAlpha[i] = NonLagMAGVal * NonLagMABeta;
      NonLagMAWeight += NonLagMAAlpha[i];
   }
}

void OnTickNonLagMA(){
   int i, shift, limit;
   int counted_bars = IndicatorCounted();
   double price;
   
   if (counted_bars > 0)
      limit = Bars - counted_bars;
   if (counted_bars < 0)
      return;
   if (counted_bars ==0)
      limit=Bars-NonLagMALen-1;
      
   if (counted_bars < 1) 
   {
      for(i=1; i < Length * NonLagMACycle + Length; i++) 
      {
         NonLagMABuffer[Bars-i] = 0;
         NonLagMAUpBuffer[Bars-i] = 0;
         NonLagMADownBuffer[Bars-i] = 0;
      }
   }
   
   for(shift = limit; shift >= 0; i--)
   {
      NonLagMASum = 0;
   }
}