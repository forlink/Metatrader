//+------------------------------------------------------------------+
//|                                KeltnerPullbackTraderSettings.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

sinput string KeltnerPullbackTraderSettings1; // ####
sinput string KeltnerPullbackTraderSettings2; // #### Signal Settings
sinput string KeltnerPullbackTraderSettings3; // ####

input int KeltnerPullbackMaPeriod=30; // MA Period
input int KeltnerPullbackMaShift=0; // MA Shift
input ENUM_MA_METHOD KeltnerPullbackMaMethod=MODE_EMA; // MA Mode
input ENUM_APPLIED_PRICE KeltnerPullbackMaAppliedPrice=PRICE_TYPICAL; // MA Applied Price
input color KeltnerPullbackMaColor=clrHotPink; // MA Indicator Color

input int KeltnerPullbackAtrPeriod=30; // ATR Period
input double AtrSkew=0; // ATR Vertical Skew
input double KeltnerPullbackAtrMultiplier=3; // ATR Multiplier
input color KeltnerPullbackAtrColor=clrAquamarine; // ATR Indicator Color

input int KeltnerPullbackShift=0; // Keltner Channel Shift
input double KeltnerPullbackMinimumTpSlDistance=5; // Tp/Sl minimum distance, in spreads.
input int KeltnerPullbackParallelSignals=2; // Quantity of parallel signals to use.

#include <EA\PortfolioManagerBasedBot\BasicSettings.mqh>
