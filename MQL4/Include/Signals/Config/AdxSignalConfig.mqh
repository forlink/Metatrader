//+------------------------------------------------------------------+
//|                                              AdxSignalConfig.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\Config\AdxBaseConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct AdxSignalConfig : public AdxBaseConfig
  {
public:

   void RsiConfig()
     {
      this.Period=14;
      this.Timeframe=PERIOD_CURRENT;
      this.Shift=0;
      this.AppliedPrice=PRICE_CLOSE;
      this.Threshold=25;
     };
  };
//+------------------------------------------------------------------+
