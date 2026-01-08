unit uBringToSecond_cocoa;

//--- Схема работы функции на примере -------------------------[ in0k (c) 2025 ]
//
//     Z-Index
//
//     0    Wnd00                +-> Wnd_A                      Wnd_A
//     1    Wnd01                |   Wnd00                  +-> Wnd_B
//     2     ...                 |   Wnd01                  |   Wnd00
//     3     ...                 |    ...                   |   Wnd01
//    ...    ...                 |    ...                   |
//     N    Wnd_A.bringToFront---^    ...                   |
//     M     ...                     bringToSecond(Wnd_B)---^
//    ...    ...                      ...
//    ...............................................................
//    DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop
//
//----------------------------------------------------------------------------//
// "НАТИвНаЯ" реализация, НЕ должна моргать
//----------------------------------------------------------------------------//
   {%region --- проверка совместимости ------------------------ /fold}
    {$IF not(DEFINED(LCLcocoa))}
    {$ErrOr 'WRONG `WidgetSet`! Unit must be used only with `cocoa`!'}
    {$endIF}
   {%endregion}
//----------------------------------------------------------------------------//

interface
{$mode objfpc}{$H+}
{$modeswitch objectivec1}
{$modeswitch objectivec2}

uses
  uB2SP_SzOW,
  uB2SP_SzOF,
  //
  Forms,
  //
  CocoaAll, CocoaWindows;

procedure bringToSecond(const form:TCustomForm); {$ifOPT D-}inline;{$endIf}

implementation

{% TESTed in0k 20260108 x86_64-darwin-cocoa Lazarus:4.4.0.0 FPC:3.2.2         %}

{%region --- #0. inLine functions -------------------------------- /fold }

function _get_cocoaWindow_(const form:TCustomForm):TCocoaWindow; {$ifOPT D-}inline;{$endIf}
begin {$ifOPT D+}
        Assert(Assigned(form),'`form`: must be defined');
        Assert(form.HandleAllocated,'`form.HandleAllocated`: must be');
      {$endIf}
    result:=TCocoaWindow(TCocoaWindowContent(form.Handle).lclOwnWindow);
end;

{%endregion -------------------------------------------------------------------}

// Переместить форму на "Второй План"
procedure bringToSecond(const form:TCustomForm);
var fTop      :TCustomForm;
    cocoa_fTop:TCocoaWindow;
    cocoa_form:TCocoaWindow;
begin {$ifOPT D+}
        Assert(Assigned(form),'`form`: must be defined');
      {$endIf}
    if SzOW_SecondPlane_possible(form,fTop) then begin
        // получим `cocoa` формы
        cocoa_fTop:=_get_cocoaWindow_(fTop);
        cocoa_form:=_get_cocoaWindow_(form);
        // ну и если возможно, то делаем перенос
        if assigned(cocoa_fTop) and assigned(cocoa_form) then begin
            // собственно ПЕРЕНОСИМ
            cocoa_form.orderWindow_relativeTo(NSWindowBelow,cocoa_fTop.windowNumber);
            // "чиним" порядок в LCL
            SzOF_listFT2F_zFIX(fTop,form);
        end;
    end;
end;

end.

