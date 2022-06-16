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
int NonLagMAIndex, NonLagMAPhase, NonLagMALen, NonLagMACycle=4;
double NonLagMACoeff, NonLagMABeta, NonLagMATVal, NonLagMASum, NonLagMAWeight, NonLagMAGVal;


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
}