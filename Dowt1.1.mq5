//+------------------------------------------------------------------+
//|                                                      Dowt1.0.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"



// Exemplo datetime d1=D'19.07.1980 12:30:27';




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



//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---


/**
datetime d_start = D'2018.07.02 17:59:00';
datetime d_end = D'2018.07.02 09:00:00';


datetime d_start = D'2017.10.04 17:59:00';
datetime d_end = D'2017.10.04 09:00:00';
**/





datetime d_start = D'2017.10.09 17:59:00';
datetime d_end = D'2017.10.04 09:00:00';
OHLC ohlc;
//ohlc.initAsSeries();
ohlc.fill(0,d_start,d_end);
ohlc.fillTime(0,d_start,d_end);
int t_size = ohlc.getTimeSize()-1;
//ohlc.checkComment(t_size);
bool waitH = false;
bool waitL = false;
int countH = 0;
int countL = 0;
for(int i = 0 ; i <= t_size-2 ; i++){
   /**
   if(ohlc.getHigh(i) == ohlc.getHigh(i+1)){
      
      if(!waitH){
         waitH = true;
         ObjectCreate(0,"SameH"+(string)i,OBJ_TREND,0,ohlc.getTime(i),ohlc.getHigh(i),ohlc.getTime(i+1),ohlc.getHigh(i));
      }
      
   }
   if(ohlc.getHigh(i) != ohlc.getHigh(i+1)) waitH = false;
   
   if(ohlc.getLow(i) == ohlc.getLow(i+1)){
      
      if(!waitL){
         waitL = true;
         ObjectCreate(0,"SameL"+(string)i,OBJ_TREND,0,ohlc.getTime(i),ohlc.getLow(i),ohlc.getTime(i+1),ohlc.getLow(i));
      }
      
   }
   if(ohlc.getLow(i) != ohlc.getLow(i+1)) waitL = false;
   **/
   //--- B1
   //--- High;
   if(ohlc.getHigh(i) <= ohlc.getHigh(i+1) && ohlc.getLow(i) < ohlc.getLow(i+2) && ohlc.getHigh(i+1) > ohlc.getHigh(i+2) && ohlc.getLow(i) <= ohlc.getLow(i+2)){
      ObjectCreate(0,"HighB1 "+(string)i,OBJ_TREND,0,ohlc.getTime(i),ohlc.getHigh(i+1),ohlc.getTime(i+2),ohlc.getHigh(i+1));
      countH++;
   }
   //--- Low;
   if(ohlc.getLow(i) >= ohlc.getLow(i+1) && ohlc.getHigh(i) > ohlc.getHigh(i+1) && ohlc.getLow(i+1) < ohlc.getLow(i+2) && ohlc.getHigh(i) >= ohlc.getHigh(i+2)){
      ObjectCreate(0,"LowB1 "+(string)i,OBJ_TREND,0,ohlc.getTime(i),ohlc.getLow(i+1),ohlc.getTime(i+2),ohlc.getLow(i+1));
      countL++;
   }
   //--- B1 end;
   
   /**
   //--- A1
   if((ohlc.getHigh(i) > ohlc.getHigh(i+1)) && ohlc.getLow(i) == ohlc.getLow(i+1)){
      ObjectCreate(0,"LowA1 "+(string)i,OBJ_TREND,0,ohlc.getTime(i-1),ohlc.getLow(i),ohlc.getTime(i+1),ohlc.getLow(i));
   }
   if(ohlc.getLow(i) < ohlc.getLow(i+1)  && ohlc.getHigh(i) == ohlc.getHigh(i+1)){
      ObjectCreate(0,"HighA1 "+(string)i,OBJ_TREND,0,ohlc.getTime(i-1),ohlc.getHigh(i),ohlc.getTime(i+1),ohlc.getHigh(i));
   }
   //--- A1 end;
   **/
   
   //--- A2
   //--- Low;
   if((ohlc.getHigh(i) > ohlc.getHigh(i+1)) && ohlc.getLow(i) > ohlc.getLow(i+1) && ohlc.getLow(i+1) == ohlc.getLow(i+2)){
      ObjectCreate(0,"LowA2 "+(string)i,OBJ_TREND,0,ohlc.getTime(i),ohlc.getLow(i+1),ohlc.getTime(i+2),ohlc.getLow(i+1));
      countL++;
   }
   //--- High;
   if(ohlc.getLow(i) < ohlc.getLow(i+1) && ohlc.getHigh(i) < ohlc.getHigh(i+1) && ohlc.getHigh(i+1) == ohlc.getHigh(i+2)){
      ObjectCreate(0,"HighA2 "+(string)i,OBJ_TREND,0,ohlc.getTime(i),ohlc.getHigh(i+1),ohlc.getTime(i+2),ohlc.getHigh(i+1));
      countH++;
   }
   //--- A2 end;
   
   
   
   //--- Mesure 7pts;
   
   
   //--- Mesure 7pts end;
   
}
Comment("High: ", countH, "Low: ",countL);
}
//+------------------------------------------------------------------+
