//+------------------------------------------------------------------+
//|                                               PortfolioStats.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Stats\Stats.mqh>
#include <Time\TimeSpan.mqh>
#include <Common\Strings.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PortfolioStats
  {
public:
   static int        LossTradesCount(string symbol="");
   static int        ProfitTradesCount(string symbol="");
   static int        TotalTrades(string symbol="");
   static TimeSpan   HistoryDuration(string symbol="");
   static void       PeriodicAveragesOfReturns(double &arr[],string symbol="",int samples=5);
   static datetime   OldestTrade(bool byCloseDate=false, string symbol="");
   static datetime   NewestTrade(bool byCloseDate=true, string symbol="");
   static double     WinRate(string symbol="");
   static double     LossRate(string symbol="");
   static double     NetProfit(string symbol="");
   static double     ProfitPerTrade(string symbol="");
   static double     TotalGain(string symbol="");
   static double     TotalLoss(string symbol="");
   static double     LargestGain(string symbol="");
   static double     LargestLoss(string symbol="");
   static double     MedianGain(string symbol="");
   static double     MedianLoss(string symbol="");
   static double     AverageGain(string symbol="");
   static double     AverageLoss(string symbol="");
   static double     SmallestGain(string symbol="");
   static double     SmallestLoss(string symbol="");
   static double     GainsStdDev(string symbol="");
   static double     LossesStdDev(string symbol="");
   static double     ReturnStdDev(string symbol="");
   static void       GetReturnsArray(double &array[],string symbol="");
   static void       GetGainsArray(double &array[],string symbol="");
   static void       GetLossesArray(double &array[],string symbol="");
   static void       GetDatesArray(datetime &array[],bool closingDates=false,string symbol="");
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioStats::PeriodicAveragesOfReturns(double &arr[],string symbol="",int samples=5)
  {
   double returns[];
   PortfolioStats::GetReturnsArray(returns,symbol);
   int returnsSize=Stats::Count(returns);
   if(returnsSize==0)
     {
      if(0<ArrayResize(arr,1,0))
        {
         arr[0]=0;
        }
      return;
     }
   if(samples<=1)
     {
      if(0<ArrayResize(arr,1,0))
        {
         arr[0]=Stats::Average(returns);
        }
      return;
     }
   int bucketSize=(int)MathFloor(returnsSize/samples);
   if(bucketSize==0)
     {
      if(0<ArrayResize(arr,1,0))
        {
         arr[0]=0;
        }
      return;
     }
   int bucketsRequired=(int)MathFloor(returnsSize/bucketSize);
   int lastBucketSize=(int)MathMod(returnsSize,bucketSize);
   if(lastBucketSize>0)
     {
      bucketsRequired+=1;
     }
   double bucket[];
   bool arraysSized=(0<ArrayResize(bucket,bucketSize,0))
                    && (0<ArrayResize(arr,bucketsRequired,0));
   if(!arraysSized)
     {
      // there was some error resizing the arrays.
      if(0<ArrayResize(arr,1,0))
        {
         arr[0]=0;
        }
      return;
     }

   int arrIndex;
   for(arrIndex=0;bucketsRequired>arrIndex;arrIndex++)
     {
      if(lastBucketSize>0 && (bucketsRequired==(arrIndex+1)))
        {
         bucketSize=lastBucketSize;
         if(0>=ArrayResize(bucket,bucketSize,0))
           {
            // there was some error in sizing the bucket.
            if(0<ArrayResize(arr,1,0))
              {
               arr[0]=0;
              }
            return;
           }
        }

      if(0>=ArrayCopy(bucket,returns,0,(bucketSize*arrIndex),bucketSize))
        {
         // there was some error in copying the range.
         if(0<ArrayResize(arr,1,0))
           {
            arr[0]=0;
           }
         return;
        }
      arr[arrIndex]=Stats::Average(bucket);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeSpan PortfolioStats::HistoryDuration(string symbol="")
  {
   datetime oldest = PortfolioStats::OldestTrade(false, symbol);
   datetime newest = PortfolioStats::NewestTrade(true, symbol);
   TimeSpan s;
   if(oldest==0 || newest==0)
   {
      return s;
   }
   return (s.FromDateTime(newest).Subtract(oldest));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime PortfolioStats::OldestTrade(bool byCloseDate=false,string symbol="")
  {
   datetime arr[];
   PortfolioStats::GetDatesArray(arr,byCloseDate,symbol);
   if(Stats::Count(arr)<=0)
     {
      return 0;
     }
   return Stats::Min(arr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime PortfolioStats::NewestTrade(bool byCloseDate=true,string symbol="")
  {
   datetime arr[];
   PortfolioStats::GetDatesArray(arr,byCloseDate,symbol);
   if(Stats::Count(arr)<=0)
     {
      return 0;
     }
   return Stats::Max(arr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioStats::GetDatesArray(datetime &array[],bool closingDates=false,string symbol="")
  {
   int total=OrdersHistoryTotal();
   int i=0;
   int found=0;
   for(i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if((OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==symbol || Strings::IsNullOrBlank(symbol)))
           {
            ArrayResize(array,found+1,0);
            if(closingDates)
              {
               array[found]=OrderCloseTime();
              }
            else
              {
               array[found]=OrderOpenTime();
              }
            found++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioStats::GetGainsArray(double &array[],string symbol="")
  {
   int total=OrdersHistoryTotal();
   int i=0;
   int found=0;
   for(i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderProfit()>0 && (OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==symbol || Strings::IsNullOrBlank(symbol)))
           {
            ArrayResize(array,found+1,0);
            array[found]=OrderProfit();
            found++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioStats::GetLossesArray(double &array[],string symbol="")
  {
   int total=OrdersHistoryTotal();
   int i=0;
   int found=0;
   for(i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderProfit()<0 && (OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==symbol || Strings::IsNullOrBlank(symbol)))
           {
            ArrayResize(array,found+1,0);
            array[found]=OrderProfit();
            found++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioStats::GetReturnsArray(double &array[],string symbol="")
  {
   int total=OrdersHistoryTotal();
   int i=0;
   int found=0;
   for(i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if((OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==symbol || Strings::IsNullOrBlank(symbol)))
           {
            ArrayResize(array,found+1,0);
            array[found]=OrderProfit();
            found++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::ReturnStdDev(string symbol="")
  {
   double returns[];
   PortfolioStats::GetReturnsArray(returns,symbol);
   if(Stats::Count(returns)<=0)
     {
      return 0;
     }
   double stdDev=Stats::StandardDeviation(returns);
   return stdDev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::GainsStdDev(string symbol="")
  {
   double returns[];
   PortfolioStats::GetGainsArray(returns,symbol);
   if(Stats::Count(returns)<=0)
     {
      return 0;
     }
   double stdDev=Stats::StandardDeviation(returns);
   return stdDev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::LossesStdDev(string symbol="")
  {
   double returns[];
   PortfolioStats::GetLossesArray(returns,symbol);
   if(Stats::Count(returns)<=0)
     {
      return 0;
     }
   double stdDev=Stats::StandardDeviation(returns);
   return stdDev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::LargestGain(string symbol="")
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Max(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::LargestLoss(string symbol="")
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Min(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::SmallestGain(string symbol="")
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Min(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::SmallestLoss(string symbol="")
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Max(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::MedianGain(string symbol="")
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Median(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::MedianLoss(string symbol="")
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Median(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::AverageGain(string symbol="")
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Average(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::AverageLoss(string symbol="")
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Average(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::ProfitPerTrade(string symbol="")
  {
   int trades=PortfolioStats::TotalTrades(symbol);
   if(trades<=0)
     {
      return 0;
     }
   double profit=PortfolioStats::NetProfit(symbol);
   return profit/trades;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::NetProfit(string symbol="")
  {
   double profits[];
   PortfolioStats::GetReturnsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Sum(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::TotalGain(string symbol="")
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Sum(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::TotalLoss(string symbol="")
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Sum(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PortfolioStats::LossTradesCount(string symbol="")
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Count(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PortfolioStats::ProfitTradesCount(string symbol="")
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Count(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PortfolioStats::TotalTrades(string symbol="")
  {
   double profits[];
   PortfolioStats::GetReturnsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Count(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::WinRate(string symbol="")
  {
   int wins=PortfolioStats::ProfitTradesCount(symbol);
   if(wins<=0)
     {
      return 0;
     }

   int total=PortfolioStats::TotalTrades(symbol);
   if(total<=0)
     {
      return 0;
     }

   return (wins/total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::LossRate(string symbol="")
  {
   int losses=PortfolioStats::LossTradesCount(symbol);
   if(losses<=0)
     {
      return 0;
     }

   int total=PortfolioStats::TotalTrades(symbol);
   if(total<=0)
     {
      return 0;
     }

   return (losses/total);
  }
//+------------------------------------------------------------------+
