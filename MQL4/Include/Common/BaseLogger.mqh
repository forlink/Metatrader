//+------------------------------------------------------------------+
//|                                                   BaseLogger.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BaseLogger
  {
private:
   void              Write(string prefix,string message,string suffix="");
   void              Write(string prefix,string &message[],string suffix="");
public:
   virtual void      Log(string message);
   virtual void      Log(string &message[]);
   virtual void      Warn(string message);
   virtual void      Warn(string &message[]);
   virtual void      Error(string message);
   virtual void      Error(string &message[]);
   virtual void      Comment(string message);
   virtual void      Print(string message);
   virtual void      Print(string &message[]);
   virtual void      Alert(string message);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Write(string prefix,string message,string suffix="")
  {
   this.Print(StringConcatenate(prefix,message,suffix));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Write(string prefix,string &message[],string suffix="")
  {
   int sz=ArraySize(message);
   for(int i=0;i<sz;i++)
     {
      this.Print(StringConcatenate(prefix,message[i],suffix));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Log(string message)
  {
   this.Write("LOG : ",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Log(string &message[])
  {
   this.Write("LOG : ",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Warn(string message)
  {
   this.Write("WARN : ",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Warn(string &message[])
  {
   this.Write("WARN : ",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Error(string message)
  {
   this.Write("ERROR : ",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Error(string &message[])
  {
   this.Write("ERROR : ",message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Comment(string message)
  {
   ::Comment(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Print(string message)
  {
   ::Print(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Print(string &message[])
  {
   int sz=ArraySize(message);
   for(int i=0;i<sz;i++)
     {
      this.Print(message[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Alert(string message)
  {
   ::Alert(message);
  }
//+------------------------------------------------------------------+
