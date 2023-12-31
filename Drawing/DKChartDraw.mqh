//+------------------------------------------------------------------+
//|                                                  DKChartDraw.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool TrendLineCreate(const long            chart_ID = 0,      // chart's ID
                     const string          name = "TrendLine", // line name
                     const string          descr = "TrendLine", // line name
                     const int             sub_window = 0,    // subwindow index
                     datetime              time1 = 0,         // first point time
                     double                price1 = 0,        // first point price
                     datetime              time2 = 0,         // second point time
                     double                price2 = 0,        // second point price
                     const color           clr = clrRed,      // line color
                     const ENUM_LINE_STYLE style = STYLE_SOLID, // line style
                     const int             width = 1,         // line width
                     const bool            back = false,      // in the background
                     const bool            selection = true,  // highlight to move
                     const bool            ray_left = false,  // line's continuation to the left
                     const bool            ray_right = false, // line's continuation to the right
                     const bool            hidden = true,     // hidden in the object list
                     const long            z_order = 0) {     // priority for mouse click
//--- reset the error value
  ResetLastError();
//--- create a trend line by the given coordinates
  if(!ObjectCreate(chart_ID, name, OBJ_TREND, sub_window, time1, price1, time2, price2)) {
    Print(__FUNCTION__,
          ": failed to create a trend line! Error code = ", GetLastError());
    return(false);
  }
//--- set line color
  ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set line display style
  ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set line width
  ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
  ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the left
  ObjectSetInteger(chart_ID, name, OBJPROP_RAY_LEFT, ray_left);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
  ObjectSetInteger(chart_ID, name, OBJPROP_RAY_RIGHT, ray_right);
//--- hide (true) or display (false) graphical object name in the object list
  ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
  ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
  ObjectSetString(chart_ID, name, OBJPROP_TEXT, descr);
  ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, name + "\n" + descr);
  return(true);
}

//+------------------------------------------------------------------+
//| Create a rectangle by the given coordinates                      |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // ID графика
                     const string          name="Rectangle",  // имя прямоугольника
                     const string          descr="Rectangle", // описание прямоугольника
                     const int             sub_window=0,      // номер подокна 
                     datetime              time1=0,           // время первой точки
                     double                price1=0,          // цена первой точки
                     datetime              time2=0,           // время второй точки
                     double                price2=0,          // цена второй точки
                     const color           clr=clrRed,        // цвет прямоугольника
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линий прямоугольника
                     const int             width=1,           // толщина линий прямоугольника
                     const bool            fill=false,        // заливка прямоугольника цветом
                     const bool            back=false,        // на заднем плане
                     const bool            selection=true,    // выделить для перемещений
                     const bool            hidden=true,       // скрыт в списке объектов
                     const long            z_order=0)         // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим прямоугольник по заданным координатам
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": не удалось создать прямоугольник! Код ошибки = ",GetLastError());
      return(false);
     }
//--- установим цвет прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим толщину линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- включим (true) или отключим (false) режим заливки прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим выделения прямоугольника для перемещений
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, descr);
   ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, name + "\n" + descr);   
//--- успешное выполнение
   return(true);
  }