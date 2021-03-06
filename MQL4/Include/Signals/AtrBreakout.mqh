//+------------------------------------------------------------------+
//|                                                  AtrBreakout.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\AtrBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AtrBreakout : public AtrBase
  {
private:
   bool              _invertedSignal;
public:
                     AtrBreakout(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,double skew,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine);
   SignalResult     *Analyzer(string symbol,int shift);
   void InvertedSignal(bool invertSignal) { this._invertedSignal=invertSignal; }
   bool InvertedSignal() { return this._invertedSignal; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AtrBreakout::AtrBreakout(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,double skew,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine):AtrBase(period,atrMultiplier,timeframe,skew,shift,minimumSpreadsTpSl,indicatorColor)
  {
   this._invertedSignal=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *AtrBreakout::Analyzer(string symbol,int shift)
  {
   PriceRange pr=this.CalculateRangeByPriceLowHighMidpoint(symbol,shift);
   
   PriceRange t1 = this.CalculateRangeByPriceLowHigh(symbol,shift);
   PriceRange t2 = this.CalculateRangeByPriceLowHigh(symbol,shift+(this.Period()*2));
   if((t1.high < t2.low) || (t2.high < t1.low))
   {
      this.InvertedSignal(false);
   }
   else
   {
      this.InvertedSignal(true);
   }

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   double height=pr.high-pr.low;
   double ctr=pr.mid;
   double top=pr.high;
   double bottom=pr.low;
   
   bool sell=(tick.ask<=pr.mid);
   bool buy=(tick.bid>=pr.mid);
   bool sellSignal=(_compare.Ternary(this.InvertedSignal(),buy,sell));
   bool buySignal=(_compare.Ternary(this.InvertedSignal(),sell,buy));

   if(gotTick)
     {
      if(sellSignal)
        {
         ctr=ctr+((height)*this._skew);
         top=tick.ask+(pr.high-ctr);
         bottom=tick.ask-(ctr-pr.low);

         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=top;
         this.Signal.takeProfit=bottom;
        }
      if(buySignal)
        {
         ctr=ctr-((height)*this._skew);
         top=tick.bid+(pr.high-ctr);
         bottom=tick.bid-(ctr-pr.low);
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.stopLoss=bottom;
         this.Signal.takeProfit=top;
        }
     }

   this.DrawIndicatorRectangle(symbol,shift,t1.high,t1.low,"_t1");
   this.DrawIndicatorRectangle(symbol,shift+(this.Period()*2),t2.high,t2.low,"_t2");
   this.DrawIndicatorRectangle(symbol,shift,top,bottom);

   return this.Signal;
  }
//+------------------------------------------------------------------+
