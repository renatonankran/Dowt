//+------------------------------------------------------------------+
//|                                                     ATRtoCSV.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+


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






void OnStart()
  {
//---
Print(__PATH__);
Print(TerminalInfoString(TERMINAL_DATA_PATH));
datetime d_start = D'2018.06.28 00:00:00';
datetime d_end = D'2012.12.03 00:00:00';
OHLC ohlc;
ohlc.initAsSeries();
ohlc.fill(0,d_start,d_end);
ohlc.fillTime(0,d_start,d_end);
int t_size = ohlc.getTimeSize()-1;
//ohlc.checkComment(t_size);
//ohlc.checkComment(0);

double ATRpriceArray[];
int ATRhandle = iATR(_Symbol,_Period,4);
ArraySetAsSeries(ATRpriceArray,true);
CopyBuffer(ATRhandle,0,d_start,d_end,ATRpriceArray);
int ATRsize = ArraySize(ATRpriceArray)-1;
//Comment(t_size == ATRsize);

int filehandle=FileOpen("deltaATR_4_shift1.csv",FILE_UNICODE|FILE_WRITE|FILE_CSV,',',CP_UTF8); 
   if(filehandle!=INVALID_HANDLE) 
   {
      FileWrite(filehandle,"DELTA_D1","ATR_4");
      for(int i = t_size ; i>0 ; i--){
         double delta = NormalizeDouble(ohlc.getHigh(i-1) - ohlc.getLow(i-1),3);
         double atr = NormalizeDouble(ATRpriceArray[i],3);
         FileWrite(filehandle,delta,atr);
      }
      FileClose(filehandle);
   } 


 
  }
//+------------------------------------------------------------------+
