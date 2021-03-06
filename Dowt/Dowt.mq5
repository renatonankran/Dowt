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



//--- Fim dos #includes;



//--- structs
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
}; // struct ohlc end;

struct signalInfo {
   double price;
   double tp;
   double sl;
   datetime sl_time;
   datetime time;
}; // struct signalInfo end;




//--- Fim da declaração de structs;



//--- Funções;
bool distanceFromSignalPrice(double signalPrice, double distanceValue, double stopPts){
   
   double last = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_LAST),_Digits);
   double distance = MathAbs(signalPrice - last);
   double stopExit;
   

   stopExit = MathAbs(NormalizeDouble(last - signalPrice,_Digits));
   
   
   if(distance >= distanceValue)
      return true;

   if(signalPrice == last &&  modify3pts)
      return true;
      
   if(stopExit == stopPts && !modify3pts)
      return true;
      
   else
      return false;

   
   return false;
}




//--- Fim da declaração de funções;






//--- Variáveis;

//--- A variável ohlc_sl está declara para futuramente
//--- contar os candles para achar o stop técnico.

OHLC ohlc_sig, ohlc_sl;
MqlRates priceData[];
MqlTick lastTick[];
MqlTradeRequest request1;
MqlTradeResult result1,result2;
signalInfo sig_infoHi, sig_infoLo;
double sig_price;
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
bool modify3pts = false;
bool modify5pts = false;
bool interOpConditions1 = true;
//bool interOpConditions2 = true;
bool cancelLastSignal = false;
bool mesureStart = false;

//--- Fim da declaração de variáveis;



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

   if(timeStampLastCheck != timeStampCurrentCandle){      
      
      //if(interOpConditions1)
      //   interOpConditions2 = true;
      
      candleCounter++;
      ohlc_sig.fill(0,timeStampLastCheck,3);
      ohlc_sig.fillTime(0,timeStampLastCheck,3);
      //ohlc_sl.fill(_Period,timeStampLastCheck,sig_info.time);
      timeStampLastCheck = timeStampCurrentCandle;
   
         
//--- Padrões de sinais;
   
      if(candleCounter >= 3){

         //--- B1
         //--- High;
         if(ohlc_sig.getHigh(ii) <= ohlc_sig.getHigh(ii-1) && ohlc_sig.getLow(ii) <= ohlc_sig.getLow(ii-1) && ohlc_sig.getHigh(ii-1) > ohlc_sig.getHigh(ii-2) && ohlc_sig.getLow(ii) <= ohlc_sig.getLow(ii-2)){
            
            ObjectCreate(0,"HighB1 "+(string)(candleCounter-2)+" cancelLastSignal: "+(string)cancelLastSignal,OBJ_TREND,0,ohlc_sig.getTime(ii),ohlc_sig.getHigh(ii-1),ohlc_sig.getTime(ii-2),ohlc_sig.getHigh(ii-1));
            sig_infoHi.price = ohlc_sig.getHigh(ii-1);
            sig_infoHi.time = ohlc_sig.getTime(ii-1);
            //signalB1_low = false;
            //signalA2_high = false;
            //signalA2_low = false;
            signalB1_high = true;
         }
         //--- Low;
         if(ohlc_sig.getLow(ii) >= ohlc_sig.getLow(ii-1) && ohlc_sig.getHigh(ii) >= ohlc_sig.getHigh(ii-1) && ohlc_sig.getLow(ii-1) < ohlc_sig.getLow(ii-2) && ohlc_sig.getHigh(ii) >= ohlc_sig.getHigh(ii-2)){
            
            ObjectCreate(0,"LowB1 "+(string)(candleCounter-2)+" cancelLastSignal: "+(string)cancelLastSignal,OBJ_TREND,0,ohlc_sig.getTime(ii),ohlc_sig.getLow(ii-1),ohlc_sig.getTime(ii-2),ohlc_sig.getLow(ii-1));
            sig_infoLo.price = ohlc_sig.getLow(ii-1);
            sig_infoLo.time = ohlc_sig.getTime(ii-1);
            //signalB1_high = false;
            //signalA2_high = false;
            //signalA2_low = false;
            signalB1_low = true;
         }
         //--- B1 end;
   
         
         //--- A2
         //--- High;
         if(ohlc_sig.getLow(ii) < ohlc_sig.getLow(ii-1) && ohlc_sig.getHigh(ii) < ohlc_sig.getHigh(ii-1) && ohlc_sig.getHigh(ii-1) == ohlc_sig.getHigh(ii-2)){
            
            ObjectCreate(0,"HighA2 "+(string)(candleCounter-2)+" cancelLastSignal: "+(string)cancelLastSignal,OBJ_TREND,0,ohlc_sig.getTime(ii),ohlc_sig.getHigh(ii-1),ohlc_sig.getTime(ii-2),ohlc_sig.getHigh(ii-1));
            sig_infoHi.price = ohlc_sig.getHigh(ii-1);
            sig_infoHi.time = ohlc_sig.getTime(ii-1);         
            //signalB1_high = false;
            //signalB1_low = false;
            //signalA2_low = false;
            signalA2_high = true;
         }
         //--- Low;
         if((ohlc_sig.getHigh(ii) > ohlc_sig.getHigh(ii-1)) && ohlc_sig.getLow(ii) > ohlc_sig.getLow(ii-1) && ohlc_sig.getLow(ii-1) == ohlc_sig.getLow(ii-2) ){
            
            ObjectCreate(0,"LowA2 "+(string)(candleCounter-2)+" cancelLastSignal: "+(string)cancelLastSignal,OBJ_TREND,0,ohlc_sig.getTime(ii),ohlc_sig.getLow(ii-1),ohlc_sig.getTime(ii-2),ohlc_sig.getLow(ii-1));
            sig_infoLo.price = ohlc_sig.getLow(ii-1);
            sig_infoLo.time = ohlc_sig.getTime(ii-1);         
            //signalB1_high = false;
            //signalB1_low = false;
            //signalA2_high = false;
            signalA2_low = true;
         }      
         //--- A2 end;
      
      } //--- if end;




//--- Fim do módulo de sinais;      
   
   
   } // Fim da checagem de nova barra;
   


   

  //Print("interOpConditions: ",interOpConditions2," mesureStart: ",mesureStart);
   
   
   // Aqui todas as FLAGS que tem haver com operações que só devem ocorrer uma vez
   // por Position são zeradas;   
   if(!PositionsTotal()){ 
      ongoingBuyTrade = false;
      ongoingSellTrade = false;
   }
   if(PositionsTotal()){
   
         signalB1_high = false;
         signalB1_low = false;
         signalA2_high = false;
         signalA2_low = false;   
   }
   
   
   
   
//--- Começo da lógica operacional;
   
   

   


   if(interOpConditions1){

      //--- Compras e Vendas
      double buyMax = sig_infoHi.price + 1;
      double sellMin = sig_infoLo.price - 1;
      double ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      
      if(cancelLastSignal){
      
         signalB1_high = false;
         signalB1_low = false;
         signalA2_high = false;
         signalA2_low = false;
         cancelLastSignal = false;      
      }
      
      if( (signalB1_high || signalA2_high) && (ask > sig_infoHi.price && ask < buyMax) && !ongoingBuyTrade && !PositionsTotal()){
         
         modify3pts = false;
         modify5pts = false;     
         
         request1.action = TRADE_ACTION_DEAL;
         request1.type = ORDER_TYPE_BUY;
         request1.symbol = _Symbol;
         request1.volume = 5;
         request1.type_filling = ORDER_FILLING_RETURN;
         request1.price = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
         request1.sl = NormalizeDouble((request1.price-SL_PTS),_Digits);
         request1.tp = NormalizeDouble((request1.price+TP_PTS),_Digits);
         request1.deviation = 5000;
   
         _trade.SetTypeFilling(ORDER_FILLING_RETURN);
         
         sig_price = sig_infoHi.price;
         ongoingBuyTrade = true;
         mesureStart = true;
         interOpConditions1 = false;
         //interOpConditions2 = false;         

            _trade.OrderSend(request1, result1);
  
         Print("RetCode OrderSend: ",_trade.ResultRetcode(), " Result1 deal: ", result1.deal);   
         

      } // if end;
      
      if( (signalB1_low || signalA2_low) && (bid < sig_infoLo.price && bid > sellMin) && !ongoingSellTrade && !PositionsTotal()){
         
         modify3pts = false;
         modify5pts = false;
         
         request1.action = TRADE_ACTION_DEAL;
         request1.type = ORDER_TYPE_SELL;
         request1.symbol = _Symbol;
         request1.volume = 5;
         request1.type_filling = ORDER_FILLING_RETURN;
         request1.price = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
         //NormalizeDouble(lastTick[0].last,_Digits);
         request1.sl = NormalizeDouble((request1.price+SL_PTS),_Digits);
         request1.tp = NormalizeDouble((request1.price-TP_PTS),_Digits);;
         request1.deviation = 5000;
   
         _trade.SetTypeFilling(ORDER_FILLING_RETURN);
         
         sig_price = sig_infoLo.price;
         ongoingSellTrade = true;
         mesureStart = true;
         interOpConditions1 = false;
         //interOpConditions2 = false;
         

            _trade.OrderSend(request1, result2);
   
         Print("RetCode OrderSend: ",_trade.ResultRetcode(), " Result2 deal: ", result2.deal);   
   
      }// if end;
   }  
   
   
//--- Fim do modulo de compra e venda;
   
   
   
      //--- Ajuste de stops;
      ulong positionTicket = PositionGetTicket(PositionsTotal()-1);
      
      //--- Aqui nesta função é preciso checar se a ordem foi modificada com sucesso retcode 10009;
      
      if(positionTicket && ongoingBuyTrade){
         //PositionSelect(_Symbol)
         double profit = PositionGetDouble(POSITION_PRICE_CURRENT) - PositionGetDouble(POSITION_PRICE_OPEN);
         
         if(profit >= 3.0 && !modify3pts){
         
            _trade.PositionModify(positionTicket,PositionGetDouble(POSITION_PRICE_OPEN)-1.0,PositionGetDouble(POSITION_TP));
            modify3pts = true;
         }
         if(profit >=5.0 && !modify5pts){
         
            _trade.PositionModify(positionTicket,PositionGetDouble(POSITION_PRICE_OPEN),PositionGetDouble(POSITION_TP));
            modify5pts = true;
         }
      }
      
      if(positionTicket && ongoingSellTrade){
         //PositionSelect(_Symbol)
         double profit = PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_PRICE_CURRENT);
         

         if(profit >= 3.0 && !modify3pts){
         
            _trade.PositionModify(positionTicket,PositionGetDouble(POSITION_PRICE_OPEN)+1.0,PositionGetDouble(POSITION_TP));
            modify3pts = true;
         }
         if(profit >=5.0 && !modify5pts){
         
            _trade.PositionModify(positionTicket,PositionGetDouble(POSITION_PRICE_OPEN),PositionGetDouble(POSITION_TP));
            modify5pts = true;
         }
         
      }   
   


//--- Fim do módulo de ajuste de stops;


      if(mesureStart){
   
      interOpConditions1 = distanceFromSignalPrice(sig_price,TP_PTS+1.0,SL_PTS-0.500);
      if(interOpConditions1) 
         mesureStart = false;
         cancelLastSignal = true;
      }
   

   
   
} //--- OnTick end;
//+------------------------------------------------------------------+