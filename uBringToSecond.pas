unit uBringToSecond;

//--- Схема работы функции на примере ------------------------ [ in0k (c) 2018 ]
//
//     Z-Index
//
//     0    Wnd00              +-> Wnd_A                        Wnd_A
//     1    Wnd01              |   Wnd00                    +-> Wnd_B
//     2     ...               |   Wnd01                    |   Wnd00
//     3     ...               |    ...                     |   Wnd01
//    ...    ...               |    ...                     |
//     N    Wnd_A.bringToFront-^    ...                     |
//     M     ...                   bringToSecond(Wnd_B)-----^
//    ...    ...                    ...
//    ...............................................................
//    DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop
//
//----------------------------------------------------------------------------//
{%region ---               Выбираем РЕАЛИзацИЮ                 --- /fold }
{$unDef b2sp_implementation_selected}
//--- #0. по ЦЕЛЕВОЙ платформе
{$If DEFINED(MSWINDOWS)}
  {$IF DEFINED(LCLWin32) or DEFINED(LCLWin64)}
    {$define b2sp_implementation_WIN}{$define b2sp_implementation_selected}
  {$elseIf DEFINED(LCLqt) or DEFINED(LCLqt5)}
    {$define b2sp_implementation_WIN}{$define b2sp_implementation_selected}
  {$elseIf DEFINED(LCLgtk2)}
    {$define b2sp_implementation_WIN}{$define b2sp_implementation_selected}
  {$endIF}
{$endIF}
//--- #1.1 по ЦЕЛЕВЫМ виджитам
{$ifNdef b2sp_implementation_selected} // видимо нативно через ВИДЖИТЫ
  {$if DEFINED(LCLcocoa)}
    {$define b2sp_implementation_cocoa}{$define b2sp_implementation_selected}
  {$endIF}
{$endIF}
//--- #1.2 по ЦЕЛЕВЫМ виджитам
{$ifNdef b2sp_implementation_selected} // видимо нативно через ВИДЖИТЫ
  {$if DEFINED(LCLqt) or DEFINED(LCLqt5)}
    {$define b2sp_implementation_QtX}{$define b2sp_implementation_selected}
  {$elseIf DEFINED(LCLgtk2) or DEFINED(LCLgtk3)}
    {$define b2sp_implementation_GtkX}{$define b2sp_implementation_selected}
  {$endIF}
{$endIF}
{%endRegion -------------------------------------------------------------}
//----------------------------------------------------------------------------//

{$mode objfpc}{$H+}

interface

uses
  Forms,
  {$if     defined(b2sp_implementation_WIN) }
    uBringToSecond_WIN
  {$elseif defined(b2sp_implementation_cocoa) }
    uBringToSecond_cocoa
  {$elseif defined(b2sp_implementation_QtX) }
      // теперь надо определить, можно ли использовать X11 НАПРЯМУЮ
      {$if DEFINED(LCLqt5)}
        {%region --- воровано `qt56.pas` /fold }
            {$IFDEF MSWINDOWS}
            {$ELSE}
              {$IFDEF DARWIN}
                {$LINKFRAMEWORK Qt5Pas}
              {$ELSE}
                  {$IF DEFINED(LINUX) or DEFINED(FREEBSD) or DEFINED(NETBSD)}
                  {$DEFINE BINUX}
                {$ENDIF}
              {$ENDIF}
            {$ENDIF}
        {%endRegion}
      {$elseif DEFINED(LCLqt)}
        {%region --- воровано `qt45.pas` /fold }
            {$IFNDEF QTOPIA}
              {$IF DEFINED(LINUX) or DEFINED(FREEBSD) or DEFINED(NETBSD)}
                {$DEFINE BINUX}
              {$ENDIF}
            {$ENDIF}
        {%endRegion}
      {$endif}
      //-- выбор реализаии
      {$if defined(BINUX)}
         {$define b2sp_implementation_X11}
         uBringToSecond_X11
      {$else}
         uBringToSecond_QtX
      {$endif}
  {$elseif defined(b2sp_implementation_GtkX)}
      // теперь надо определить, можно ли использовать X11 НАПРЯМУЮ
      {$if DEFINED(LCLgtk3)}
           // буду копать по необходимости
      {$elseif DEFINED(LCLgtk2)}
           {%region --- воровано `gtk2defines.inc` /fold }
                {off $define UseX}
                {$ifdef Unix}
                  // on darwin we try to use native gtk
                  {$ifdef Darwin}
                    {$ifdef UseX} // it can be overridden
                      {$define HasX}
                    {$endif}
                  {$else}
                    {$define HasX}
                  {$endif}
                {$endif}
           {%endRegion}
      {$endif}
      //-- выбор реализаии
      {$if defined(HasX)}
         {$define b2sp_implementation_X11}
         uBringToSecond_X11
      {$else}
         uBringToSecond_GtkX
      {$endif}
  {$else}{шансов НЕТ .. вариант по умолчанию}  uBringToSecond_LCLv2
    {$note --------------------------------------------------------------------}
    {$note  in0k-bringToSecondPlane: The basic cross-platform version is used. }
    {$note  Can work slowly and with flicker.                                  }
    {$note --------------------------------------------------------------------}
  {$endIF};

{$ifOpt D+}
const cBringToSecondUNIT=
{$if     defined(b2sp_implementation_WIN) }  'uBringToSecond_WIN'
{$elseif defined(b2sp_implementation_X11) }  'uBringToSecond_X11'
{$elseif defined(b2sp_implementation_QtX) }  'uBringToSecond_QtX'
{$elseif defined(b2sp_implementation_GtkX)}  'uBringToSecond_GtkX'
{$elseif defined(b2sp_implementation_cocoa)} 'uBringToSecond_cocoa'
{$else}'uBringToSecond_LCL'{$endIF};
{$endIF}

procedure bringToSecond(const form:TCustomForm);

implementation

procedure bringToSecond(const form:TCustomForm);
begin {$ifOPT D+} Assert(Assigned(form),'`form`: must be defined'); {$endIf}
  {$if defined(b2sp_implementation_WIN)}
    uBringToSecond_WIN.bringToSecond(form);
  {$elseif defined(b2sp_implementation_X11)}
    uBringToSecond_X11.bringToSecond(form);
  {$elseif defined(b2sp_implementation_QtX)}
    uBringToSecond_QtX.bringToSecond(form);
  {$elseif defined(b2sp_implementation_GtkX)}
    uBringToSecond_GtkX.bringToSecond(form);
  {$elseif defined(b2sp_implementation_cocoa)}
    uBringToSecond_cocoa.bringToSecond(form);
  {$else}
    uBringToSecond_LCLv2.bringToSecond(form);
  {$endIF}
end;

end.

