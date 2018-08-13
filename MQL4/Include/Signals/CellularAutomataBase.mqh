//+------------------------------------------------------------------+
//|                                         CellularAutomataBase.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\OrderManager.mqh>
#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CellularAutomataBase : public AbstractSignal
  {
private:
   double            _skew;
protected:
   virtual PriceRange CalculateRange(string symbol,int shift,double midPrice,int period=0);
   virtual void      SetBuySignal(string symbol,int shift,MqlTick &tick);
   virtual void      SetSellSignal(string symbol,int shift,MqlTick &tick);
   virtual void      SetSellExits(string symbol,int shift,MqlTick &tick);
   virtual void      SetBuyExits(string symbol,int shift,MqlTick &tick);
   virtual void      SetExits(string symbol,int shift,MqlTick &tick);
   virtual PriceRange CalculateRangingRange(string symbol,int shift,int period,MqlTick &tick);
   virtual bool      IsRangeMode(string symbol,int shift,int period,MqlTick &tick);
   bool IsTrendMode(string symbol,int shift,int period,MqlTick &tick) { return !this.IsRangeMode(symbol,shift,period,tick); }
   int               GetLastClosedTicketNumber(string symbol);

public:
                     CellularAutomataBase(int period,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,double skew=0.0,AbstractSignal *aSubSignal=NULL);
   virtual bool      DoesSignalMeetRequirements();
   virtual bool      Validate(ValidationResult *v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CellularAutomataBase::CellularAutomataBase(int period,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,double skew=0.0,AbstractSignal *aSubSignal=NULL):AbstractSignal(period,timeframe,shift,clrNONE,minimumSpreadsTpSl,aSubSignal)
  {
   this._skew=skew;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CellularAutomataBase::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);

   if(this._compare.IsNotBetween(this._skew,-0.49,0.49))
     {
      v.Result=false;
      v.AddMessage("Atr skew is out of range Min : - 0.49 max 0.49");
     }

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CellularAutomataBase::DoesSignalMeetRequirements()
  {
   if(!(AbstractSignal::DoesSignalMeetRequirements()))
     {
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceRange CellularAutomataBase::CalculateRange(string symbol,int shift,double midPrice,int period=0)
  {
   PriceRange pr;
   pr.mid=midPrice;
   double atr=0;
   if(period==0)
     {
      atr=(this.GetAtr(symbol,shift)/2);
     }
   else
     {
      atr=(this.GetAtr(symbol,shift,period)/2);
     }
   pr.low=(pr.mid-atr);
   pr.high=(pr.mid+atr);
   return pr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CellularAutomataBase::GetLastClosedTicketNumber(string symbol)
  {
   return OrderManager::GetLastClosedOrderTicket(symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CellularAutomataBase::SetBuySignal(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.ask);
   pr.mid=pr.mid-((pr.high-pr.low)*this._skew);
   pr.high=tick.ask+(pr.high-pr.mid);
   pr.low=tick.ask-(pr.mid-pr.low);

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_BUY;
   this.Signal.price=tick.ask;
   this.Signal.stopLoss=pr.low;
   this.Signal.takeProfit=0;//pr.high;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CellularAutomataBase::SetSellSignal(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.bid);
   pr.mid=pr.mid+((pr.high-pr.low)*this._skew);
   pr.high=tick.bid+(pr.high-pr.mid);
   pr.low=tick.bid-(pr.mid-pr.low);

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_SELL;
   this.Signal.price=tick.bid;
   this.Signal.stopLoss=pr.high;
   this.Signal.takeProfit=0;//pr.low;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CellularAutomataBase::SetBuyExits(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.ask);
   pr.mid=pr.mid-((pr.high-pr.low)*this._skew);
   pr.high=tick.ask+(pr.high-pr.mid);
   pr.low=tick.ask-(pr.mid-pr.low);

   double ap=OrderManager::PairAveragePrice(symbol,OP_BUY);
   double sl=pr.low;
   if(sl>0 && sl>ap)
     {
      //sl=ap+((tick.bid-ap)/2);
     }

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_BUY;
   this.Signal.price=tick.ask;
   this.Signal.stopLoss=sl;
   this.Signal.takeProfit=OrderManager::PairHighestTakeProfit(symbol,OP_BUY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CellularAutomataBase::SetSellExits(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.bid);
   pr.mid=pr.mid+((pr.high-pr.low)*this._skew);
   pr.high=tick.bid+(pr.high-pr.mid);
   pr.low=tick.bid-(pr.mid-pr.low);

   double ap=OrderManager::PairAveragePrice(symbol,OP_SELL);
   double sl=pr.high;
   if(sl>0 && sl<ap)
     {
      //sl=ap-((ap-tick.ask)/2);
     }

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_SELL;
   this.Signal.price=tick.bid;
   this.Signal.stopLoss=sl;
   this.Signal.takeProfit=OrderManager::PairLowestTakeProfit(symbol,OP_SELL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CellularAutomataBase::SetExits(string symbol,int shift,MqlTick &tick)
  {
   if(0<OrderManager::PairProfit(symbol))
     {
      if(0<OrderManager::PairOpenPositionCount(OP_BUY,symbol,TimeCurrent()))
        {
         this.SetBuyExits(symbol,shift,tick);
        }
      if(0<OrderManager::PairOpenPositionCount(OP_SELL,symbol,TimeCurrent()))
        {
         this.SetSellExits(symbol,shift,tick);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CellularAutomataBase::IsRangeMode(string symbol,int shift,int period,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRangingRange(symbol,shift,period,tick);
   return (pr.high>tick.ask && pr.low<tick.bid);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceRange CellularAutomataBase::CalculateRangingRange(string symbol,int shift,int period,MqlTick &tick)
  {
   double atr=this.GetAtr(symbol,shift,period)/4;
   PriceRange pr=this.CalculateRangeByPriceLowHigh(symbol,shift+1,period);
   pr.high= pr.high-atr;
   pr.low = pr.low+atr;
   return pr;
  }
//+------------------------------------------------------------------+
