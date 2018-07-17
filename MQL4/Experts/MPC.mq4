//+------------------------------------------------------------------+
//|                                                              MPC |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Does Magic."
#property strict

#include <PLManager\PLManager.mqh>
#include <Signals\ExtremeBreak.mqh>

input int ExtremeBreakPeriod=24;
input int ExtremeBreakShift=2;
input double Lots=0.4;
input double ProfitTarget=60; // Profit target in account currency
input double MaxLoss=60; // Maximum allowed loss in account currency
input int Slippage=10; // Allowed slippage
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MPC
  {
private:
   bool              deleteLogger;
public:
   OrderManager      orderManager;
   PLManager        *plmanager;
   AbstractSignal   *signal;
   BaseLogger       *logger;
   datetime          time;
                     MPC(PLManager *aPlmanager,AbstractSignal *aSignal,BaseLogger *aLogger);
                    ~MPC();
   bool              Validate(ValidationResult *validationResult);
   bool              Validate();
   void              ExpertOnInit();
   void              ExpertOnTick();
   bool              CanTrade();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MPC::MPC(PLManager *aPlmanager,AbstractSignal *aSignal,BaseLogger *aLogger=NULL)
  {
   this.plmanager=aPlmanager;
   this.signal=aSignal;
   if(aLogger==NULL)
     {
      this.logger=new BaseLogger();
      this.deleteLogger=true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MPC::~MPC()
  {
   if(this.deleteLogger==true)
     {
      delete this.logger;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MPC::Validate()
  {
   ValidationResult *validationResult=new ValidationResult();
   return this.Validate(validationResult);
   delete validationResult;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MPC::Validate(ValidationResult *validationResult)
  {
   bool plv=this.plmanager.Validate(validationResult);
   bool sigv=this.signal.Validate(validationResult);
   validationResult.Result=(plv && sigv);
   return validationResult.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MPC::ExpertOnInit()
  {
   string border[]=
     {
      "",
      "!~ !~ !~ !~ !~ User Settings validation failed ~! ~! ~! ~! ~!",
      ""
     };
   ValidationResult *v=new ValidationResult();
   if(mpc.Validate(v)==false)
     {
      this.logger.Log(border);
      this.logger.Warn(v.Messages);
      delete v;
      this.logger.Log(border);
      ExpertRemove();
     }
   else
     {
      delete v;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MPC::ExpertOnTick()
  {
   if(!this.CanTrade())
     {
      return;
     }
   if(Time[0]!=this.time)
     {
      this.time=Time[0];
      this.signal.Analyze();
      if(this.signal.Signal<0)
        {
         if(false==OrderSend(this.signal.Symbol,OP_SELL,Lots,Bid,this.plmanager.Slippage,0,0))
           {
            this.logger.Error("OrderSend : "+(string)GetLastError());
           }
        }
      if(this.signal.Signal>0)
        {
         if(false==OrderSend(this.signal.Symbol,OP_BUY,Lots,Ask,this.plmanager.Slippage,0,0))
           {
            this.logger.Error("OrderSend : "+(string)GetLastError());
           }
        }
     }
   this.plmanager.Execute();
  }
//+------------------------------------------------------------------+
//|Rules to stop the bot from even trying to trade                   |
//+------------------------------------------------------------------+
bool MPC::CanTrade()
  {
   return this.plmanager.CanTrade();
  }

MPC *mpc;
PLManager *plman;
ExtremeBreak *signal;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   delete mpc;
   delete plman;
   delete signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   string symbols=Symbol();
   plman=new PLManager();

   plman.WatchedPairs=symbols;
   plman.ProfitTarget=ProfitTarget;
   plman.MaxLoss=MaxLoss;
   plman.Slippage=Slippage;

   signal=new ExtremeBreak(ExtremeBreakPeriod,symbols,(ENUM_TIMEFRAMES)Period(),ExtremeBreakShift);

   mpc=new MPC(plman,(AbstractSignal *)signal);

   mpc.ExpertOnInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   mpc.ExpertOnTick();
  }
//+------------------------------------------------------------------+
