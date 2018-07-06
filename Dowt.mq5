//+------------------------------------------------------------------+
//|                                                         Dowt.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade _trade;


   struct OHLC {

   double open[];
   double high[];
   double low[];
   double close[];
   datetime time[];
   
   void initAsSeries(){
      ArraySetAsSeries(open,true);
      ArraySetAsSeries(high,true);
      ArraySetAsSeries(low,true);
      ArraySetAsSeries(close,true);
      ArraySetAsSeries(time,true);
   }
   
   void fill(ENUM_TIMEFRAMES TIMEFRAME = PERIOD_CURRENT, int STARTPOS = 0, int COUNT = 5){
      CopyOpen(_Symbol,TIMEFRAME,STARTPOS,COUNT,open);
      CopyHigh(_Symbol,TIMEFRAME,STARTPOS,COUNT,high);
      CopyLow(_Symbol,TIMEFRAME,STARTPOS,COUNT,low);
      CopyClose(_Symbol,TIMEFRAME,STARTPOS,COUNT,close);
   }
   
   void fill(ENUM_TIMEFRAMES TIMEFRAME = PERIOD_CURRENT, datetime STARTDATE = __DATE__, int COUNT = 1){
      CopyOpen(_Symbol,TIMEFRAME,STARTDATE,COUNT,open);
      CopyHigh(_Symbol,TIMEFRAME,STARTDATE,COUNT,high);
      CopyLow(_Symbol,TIMEFRAME,STARTDATE,COUNT,low);
      CopyClose(_Symbol,TIMEFRAME,STARTDATE,COUNT,close);
   }
   
   void fill(ENUM_TIMEFRAMES TIMEFRAME = PERIOD_CURRENT, datetime STARTDATE = __DATE__, datetime ENDDATE = __DATE__){
      CopyOpen(_Symbol,TIMEFRAME,STARTDATE,ENDDATE,open);
      CopyHigh(_Symbol,TIMEFRAME,STARTDATE,ENDDATE,high);
      CopyLow(_Symbol,TIMEFRAME,STARTDATE,ENDDATE,low);
      CopyClose(_Symbol,TIMEFRAME,STARTDATE,ENDDATE,close);
   }
   
   void fillTime(ENUM_TIMEFRAMES TIMEFRAME = PERIOD_CURRENT, int STARTPOS = 0, int COUNT = 5){
      CopyTime(_Symbol,TIMEFRAME,STARTPOS,COUNT,time);
   }
   
   void fillTime(ENUM_TIMEFRAMES TIMEFRAME = PERIOD_CURRENT, datetime STARTDATE = __DATE__, int COUNT = 1){
      CopyTime(_Symbol,TIMEFRAME,STARTDATE,COUNT,time);
   }
   
   void fillTime(ENUM_TIMEFRAMES TIMEFRAME = PERIOD_CURRENT, datetime STARTDATE = __DATE__, datetime ENDDATE = __DATE__){
      CopyTime(_Symbol,TIMEFRAME,STARTDATE,ENDDATE,time);
   }
   
   double getOpen(int position=0){
      return open[position];
   }
   double getHigh(int position=0){
      return high[position];
   }
   double getLow(int position=0){
      return low[position];
   }
   double getClose(int position=0){
      return close[position];
   }
   datetime getTime(int position=0){
      return time[position];
   }
   
   int getSize(){
      if( (ArraySize(high) == ArraySize(low)) && (ArraySize(high) == ArraySize(close)) && (ArraySize(high) == ArraySize(open)))
         return ArraySize(high);
      else return -1;
   }
   
   int getTimeSize(){
      if(getSize() == ArraySize(time)) return ArraySize(time);
      else return -1;
   }    
   
   void checkComment(int pos=0){
      Comment("O: "+(string)open[pos]+"\n",
               "H: "+(string)high[pos]+"\n",
               "L: "+(string)low[pos]+"\n",
               "C: "+(string)close[pos]+"\n",
               "Time: "+(string)time[pos]
               );
   }
}; // struct end.

struct signalInfo {
   double price;
   double tp;
   double sl;
   datetime sl_time;
   datetime time;
};



/**

datetime d_start = D'2017.10.09 17:59:00';
datetime d_end = D'2017.10.04 09:00:00';

**/

OHLC ohlc_sig, ohlc_sl;
MqlRates priceData[];
MqlTick lastTick[];
MqlTradeRequest request1;
MqlTradeResult result1;
signalInfo sig_info;
bool signalB1_high = false;
bool signalB1_low = false;
bool signalA2_high = false;
bool signalA2_low = false;
input double SL_PTS = 4.0;
input double TP_PTS = 6.0;
input double VOL = 1.0;
double TP, SL;
int candleCounter = 0;
bool firstRun = true;
datetime timeStampLastCheck;
bool ongoingBuyTrade = false;
bool ongoingSellTrade = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---


ArraySetAsSeries(priceData,true);
ArraySetAsSeries(lastTick,true);
ohlc_sig.initAsSeries();
ohlc_sl.initAsSeries();

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
   int ii = 2;
   int receivedTick = CopyTicks(_Symbol,lastTick,COPY_TICKS_ALL,0,1);
   int receivedRates = CopyRates(_Symbol,_Period,0,3,priceData);
   bool newCandle = false;
   datetime timeStampCurrentCandle = priceData[0].time;
   
   if(receivedTick<0){
      Print("MqlTicks copy problem.");
   }
   if(receivedRates<0){
      Print("MqlRates copy problem.");
   } 
   //--- Check if is a new bar, if true copy the last 3 bars,
   //--- from one before the current.
   
   /**
   if(firstRun){
      
      timeStampLastCheck = timeStampCurrentCandle;
      firstRun = false;
   }
   **/
   if(timeStampLastCheck != timeStampCurrentCandle){
      
      candleCounter++;
      ohlc_sig.fill(0,timeStampLastCheck,3);
      ohlc_sig.fillTime(0,timeStampLastCheck,3);
      ohlc_sl.fill(_Period,timeStampLastCheck,sig_info.time);
      timeStampLastCheck = timeStampCurrentCandle;
   }
   
   
   
   if(candleCounter >= 3){
   
      //--- B1
      //--- High;
      if(ohlc_sig.getHigh(ii) <= ohlc_sig.getHigh(ii-1) && ohlc_sig.getLow(ii) < ohlc_sig.getLow(ii-1) && ohlc_sig.getHigh(ii-1) > ohlc_sig.getHigh(ii-2) && ohlc_sig.getLow(ii) <= ohlc_sig.getLow(ii-2)){
         
         ObjectCreate(0,"HighB1 "+(string)(candleCounter-2),OBJ_TREND,0,ohlc_sig.getTime(ii),ohlc_sig.getHigh(ii-1),ohlc_sig.getTime(ii-2),ohlc_sig.getHigh(ii-1));
         sig_info.price = ohlc_sig.getHigh(ii-1);
         sig_info.time = ohlc_sig.getTime(ii-1);
         signalB1_low = false;
         signalA2_high = false;
         signalA2_low = false;
         signalB1_high = true;
      }
      //--- Low;
      if(ohlc_sig.getLow(ii) >= ohlc_sig.getLow(ii-1) && ohlc_sig.getHigh(ii) > ohlc_sig.getHigh(ii-1) && ohlc_sig.getLow(ii-1) < ohlc_sig.getLow(ii-2) && ohlc_sig.getHigh(ii) >= ohlc_sig.getHigh(ii-2)){
         
         ObjectCreate(0,"LowB1 "+(string)(candleCounter-2),OBJ_TREND,0,ohlc_sig.getTime(ii),ohlc_sig.getLow(ii-1),ohlc_sig.getTime(ii-2),ohlc_sig.getLow(ii-1));
         sig_info.price = ohlc_sig.getLow(ii-1);
         sig_info.time = ohlc_sig.getTime(ii-1);
         signalB1_high = false;
         signalA2_high = false;
         signalA2_low = false;
         signalB1_low = true;
      }
      //--- B1 end;

      
      //--- A2
      //--- High;
      if(ohlc_sig.getLow(ii) < ohlc_sig.getLow(ii-1) && ohlc_sig.getHigh(ii) < ohlc_sig.getHigh(ii-1) && ohlc_sig.getHigh(ii-1) == ohlc_sig.getHigh(ii-2)){
         
         ObjectCreate(0,"HighA2 "+(string)(candleCounter-2),OBJ_TREND,0,ohlc_sig.getTime(ii),ohlc_sig.getHigh(ii-1),ohlc_sig.getTime(ii-2),ohlc_sig.getHigh(ii-1));
         sig_info.price = ohlc_sig.getHigh(ii-1);
         sig_info.time = ohlc_sig.getTime(ii-1);         
         signalB1_high = false;
         signalB1_low = false;
         signalA2_low = false;
         signalA2_high = true;
      }
      //--- Low;
      if((ohlc_sig.getHigh(ii) > ohlc_sig.getHigh(ii-1)) && ohlc_sig.getLow(ii) > ohlc_sig.getLow(ii-1) && ohlc_sig.getLow(ii-1) == ohlc_sig.getLow(ii-2)){
         
         ObjectCreate(0,"LowA2 "+(string)(candleCounter-2),OBJ_TREND,0,ohlc_sig.getTime(ii),ohlc_sig.getLow(ii-1),ohlc_sig.getTime(ii-2),ohlc_sig.getLow(ii-1));
         sig_info.price = ohlc_sig.getLow(ii-1);
         sig_info.time = ohlc_sig.getTime(ii-1);         
         signalB1_high = false;
         signalB1_low = false;
         signalA2_high = false;
         signalA2_low = true;
      }      
      //--- A2 end;
   
   } //--- if end;
   
   

   if(signalB1_high || signalA2_high){
      SL = sig_info.price-SL_PTS;
      TP = sig_info.price+TP_PTS;   
   }
   if(signalB1_low || signalA2_low){
      SL = sig_info.price+SL_PTS;
      TP = sig_info.price-TP_PTS;   
   }

   if( (signalB1_high || signalA2_high) && (lastTick[0].last > sig_info.price) && !ongoingBuyTrade){
      
      request1.action = TRADE_ACTION_DEAL;
      request1.type = ORDER_TYPE_BUY;
      request1.symbol = _Symbol;
      request1.volume = 5;
      request1.type_filling = ORDER_FILLING_RETURN;
      request1.price = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      request1.sl = 0;
      request1.tp = 0;
      request1.deviation = 5000;

      _trade.SetTypeFilling(ORDER_FILLING_RETURN);
      ongoingBuyTrade = true;
      ongoingSellTrade = false;
//      Print("Buy Price: ",ask);
      _trade.PositionClose(_Symbol,50);
      Print("RetCode PositionClose: ",_trade.ResultRetcode());
      _trade.OrderSend(request1, result1);
      Print("RetCode OrderSend: ",_trade.ResultRetcode());
      
      //SL = NormalizeDouble((request1.price-SL_PTS),_Digits);
      //TP = NormalizeDouble((request1.price+TP_PTS),_Digits);


      //Print("RetCode PositionModify: ",_trade.ResultRetcode());
      ResetLastError();
   } // if end;
   
   if( (signalB1_low || signalA2_low) && (lastTick[0].last < sig_info.price) && !ongoingSellTrade){
      
      request1.action = TRADE_ACTION_DEAL;
      request1.type = ORDER_TYPE_SELL;
      request1.symbol = _Symbol;
      request1.volume = 5;
      request1.type_filling = ORDER_FILLING_RETURN;
      request1.price = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      request1.sl = 0;
      request1.tp = 0;
      request1.deviation = 5000;

      _trade.SetTypeFilling(ORDER_FILLING_RETURN);
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      ongoingSellTrade = true;
      ongoingBuyTrade = false;
      Print("Sell Price: ",bid);
      _trade.PositionClose(_Symbol,5000);
      Print("RetCode PositionClose: ",_trade.ResultRetcode());
      _trade.OrderSend(request1, result1);
      Print("RetCode OrderSend: ",_trade.ResultRetcode());
      
      //SL = NormalizeDouble((request1.price+SL_PTS),_Digits);
      //TP = NormalizeDouble((request1.price-TP_PTS),_Digits);
      

      //Print("RetCode PositionModify: ",_trade.ResultRetcode());
      ResetLastError();      

   }// if end;

   if(ongoingBuyTrade){
   
      SL = NormalizeDouble((PositionGetDouble(POSITION_PRICE_OPEN)-SL_PTS),_Digits);
      TP = NormalizeDouble((PositionGetDouble(POSITION_PRICE_OPEN)+TP_PTS),_Digits);

      _trade.PositionModify(_Symbol,SL,TP);
      Print("RetCode PositionModify: ",_trade.ResultRetcode());

   }
   if(ongoingSellTrade){
   
      SL = NormalizeDouble((PositionGetDouble(POSITION_PRICE_OPEN)+SL_PTS),_Digits);
      TP = NormalizeDouble((PositionGetDouble(POSITION_PRICE_OPEN)-TP_PTS),_Digits);
      
      _trade.PositionModify(_Symbol,SL,TP);
      Print("RetCode PositionModify: ",_trade.ResultRetcode());

   }

   Comment("ResultRetcode: ",_trade.ResultRetcode());
   
  } //--- OnTick end;
//+------------------------------------------------------------------+
