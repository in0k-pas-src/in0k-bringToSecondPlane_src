unit in0k_bringToSecondPlane_lclGtk3;

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
//     M     ...                   Wnd_B.bringToSecondPlane-^
//    ...    ...                    ...
//    ...............................................................
//    DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop DeskTop
//
//----------------------------------------------------------------------------//
// "НАТИвНаЯ" реализация, НЕ моргает.
//----------------------------------------------------------------------------//
   {%region --- проверка совместимости ------------------------ /fold}
    {$IF not(DEFINED(LCLgtk3))}
    {$ErrOr 'WRONG `WidgetSet`! Unit must be used only with `LCLgtk3`!'}
    {$endIF}
   {%endregion}
   {%in0k(c)Tested [20181222 Lazarus:1.6.4 FPC:3.0.2 i386-linux-gtk2]}
//----------------------------------------------------------------------------//

interface

uses
  in0k_SzOW,
  in0k_SzOF,
  Forms,
  gtk3widgets, LazGdk3;

procedure bringToSecondPlane(const form:TCustomForm); {$ifOPT D-}inline;{$endIf}

implementation

// расположить `Формы` в порядке `zIndex` (.. source -> wndNXT .. DeskTop).
procedure _set_zIndex_in_Order_(const source,wndNXT:TCustomForm);
var pWndNXT:PGdkWindow;
    pSource:PGdkWindow;
begin {$ifOPT D+}
      Assert(Assigned(source),'`source`: must be defined');
      Assert(Assigned(wndNXT),'`wndNXT`: must be defined');
      {$endIf}
    // получаем `Gtk` указатели ... надеюсь я это правилно делаю :-)
    pSource:=nil;
    if Assigned(TGtk3Window(source.Handle)) AND
       Assigned(TGtk3Window(source.Handle).Widget)
    then pSource:=TGtk3Window(source.Handle).Widget^.window;
    if pSource=nil then Exit;
    pWndNXT:=nil;
    if Assigned(TGtk3Window(wndNXT.Handle)) AND
       Assigned(TGtk3Window(wndNXT.Handle).Widget)
    then pWndNXT:=TGtk3Window(wndNXT.Handle).Widget^.window;
    if pWndNXT=nil then Exit;
    // перемещаем
    gdk_window_restack(pWndNXT,pSource,false);
end;

// переместить форму на "Второй План"
// @prm fTop форма, которая в настоящий момент находится на переднем плане
// @prm form перемещаемая форма
procedure in0k_bringToSecondPlane(const fTop,form:TCustomForm); {$ifOPT D-}inline;{$endIf}
var list:tListFT2F;
begin {$ifOPT D+}
      Assert(Assigned(form),'`form`: must be defined');
      Assert(Assigned(fTop),'`fTop`: must be defined');
      Assert(SzOW_form_is_TOP_inZOrder(fTop),'`fTop`: must be TOP form in the app');
      {$endIf}
    // Особенности см. `in0k_SzOF.#1`
    list:=SzOF_listFT2F_make (form);
   _set_zIndex_in_Order_(fTop,form);
    SzOF_listFT2F_zFIX  (fTop,form,list);
    SzOF_listFT2F_free  (list);
end;

// Переместить форму на "Второй План"
procedure bringToSecondPlane(const form:TCustomForm);
begin {$ifOPT D+} Assert(Assigned(form),'`form`: must be defined'); {$endIf}
    if SzOW_SecondPlane_possible(form)
    then in0k_bringToSecondPlane(SzOW_get_topForm_inZOrder,form);
end;

end.
