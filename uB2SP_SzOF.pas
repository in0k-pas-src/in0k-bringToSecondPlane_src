unit uB2SP_SzOF;

//-------------------------------------------------------------[ in0k (c) 2018 ]
// Screen Z-Order Fix
//----------------------------------------------------------------------------//
//
//  #1 Причина.
//      Прямое использование системных вызовов перемещения окон по zIndex
//      иногда НАРУШАЕТ очередность окон в списке `Screen.FCustomFormsZOrdered`.
//      Это зависит от реализации `widgetSet` (точно ломается в `win` и `Gtk2`).
//      Кривой порядок, видимо, может привести с казусам. И как следствие,
//      ЭТО НАДО ЧИНИТЬ.
//
//  #2 Особенности.
//    - Список `Screen.FCustomFormsZOrdered`, как и `Screen.FCustomForms`,
//      переодически перестраивается (например при перемещении фокуса на другое
//      окно). Однако, где это происходит и как это НЕЗАМЕТНО спровоцировать
//      я не нашёл. Т.е. судьба ... чинить через "зад" :-(
//    - Список `Screen.FCustomFormsZOrdered` -- ПРИВАТНЫЙ, прямого доступа к
//      нему НЕТ. Но есть метод `Screen.MoveFormToZFront`, который работает
//      со списком, правда делает он НЕ то и НЕ так (переносит указанную форму
//      на ВеРШИНу списка в `zIndex`=0).
//
//  #3 Реализация - Исправление - Логика.
//    - Составляем "список" окон между `TOP-окном` и `form`.
//    - Перемещаем `form` на второй план.
//    - Восстанавливаем ПРАВИЛЬНЫЙ порядок `Screen.FCustomFormsZOrdered`
//      = в ОБРАТНОМ порядке по "списку" вызываем `Screen.MoveFormToZFront`
//      = добиваем вызовами для `form` и `TOP-окном`
//      = вуаля .. теперь список ПРАВИЛЬНЫЙ.
//    - МОЛИМСЯ, чтобы в последующих версиях Lazarus`а поведение метода
//      `Screen.MoveFormToZFront` кардинально не изменилось.
//
//----------------------------------------------------------------------------//

{$mode objfpc}{$H+}

interface

uses {$ifOPT D+}uB2SP_SzOW,{$endIf}
  Forms;

type tListFT2F=array of TCustomForm;

function  SzOF_listFT2F_make(const form:TCustomForm):tListFT2F;                  {$ifOPT D-}inline;{$endIf}
procedure SzOF_listFT2F_zFIX(const fTop,form:TCustomForm; const list:tListFT2F); {$ifOPT D-}inline;{$endIf}
procedure SzOF_listFT2F_zFIX(const fTop,form:TCustomForm);                       {$ifOPT D-}inline;{$endIf}
procedure SzOF_listFT2F_free(var list:tListFT2F);                                {$ifOPT D-}inline;{$endIf}

implementation
uses LCLVersion;

{%region --- проверки версий LCL для подтверждения функционала --- /fold }
//-----------------------------------------------------------------------
// РучнаЯ проверка что в текущей версии Lazarus`ф процедура
// имеет ТОЛЬко аналогичный ниже указанному код.
//-----------------------------------------------------------------------
//    procedure TScreen.MoveFormToZFront(ACustomForm: TCustomForm);
//    begin
//      if (Self = nil) or (ACustomForm = nil) or
//         (csDestroying in ACustomForm.ComponentState) or
//         (FCustomForms.IndexOf(ACustomForm)<0)
//      then
//        RaiseGDBException('TScreen.MoveFormToZFront');
//
//      if (FCustomFormsZOrdered.Count = 0) or
//         (TObject(FCustomFormsZOrdered[0]) <> ACustomForm) then
//      begin
//        FCustomFormsZOrdered.Remove(ACustomForm);
//        FCustomFormsZOrdered.Insert(0, ACustomForm);
//      end;
//    end;
//-----------------------------------------------------------------------
// т.е. в процедуре должно изменяться ТОЛЬКО `FCustomFormsZOrdered`
//-----------------------------------------------------------------------
{$undef FSzOL_implementation_verified} //< типа НЕ проверено

//1.4.x
{$if (lcl_major=1)and(lcl_minor=4)}
    {$if (lcl_release=4)and(lcl_patch=0)}
        {$define FSzOL_implementation_verified}
    {$endIf}
{$endIf}

//1.6.x
{$if (lcl_major=1)and(lcl_minor=6)}
    {$if (lcl_release=0)and(lcl_patch=4)}
        {$define FSzOL_implementation_verified}
    {$endIf}
    {$if (lcl_release=4)and(lcl_patch=0)}
        {$define FSzOL_implementation_verified}
    {$endIf}
{$endIf}

// 1.8.x
{$if (lcl_major=1)and(lcl_minor=8)}
    {$if (lcl_release=0)or(lcl_patch=6)}
        {$define FSzOL_implementation_verified}
    {$endIf}
    {$if (lcl_release=2)or(lcl_patch=0)}
        {$define FSzOL_implementation_verified}
    {$endIf}
    {$if (lcl_release=4)or(lcl_patch=0)}
        {$define FSzOL_implementation_verified}
    {$endIf}
{$endIf}

// 2.0.x.x
{$if (lcl_major=2)and(lcl_minor=0)}
    {$if (lcl_release=2)or(lcl_patch=0)}
        {$define FSzOL_implementation_verified}
    {$endIf}
    {$if (lcl_release=0)or(lcl_patch=4)}
        {$define FSzOL_implementation_verified}
    {$endIf}
{$endIf}

// 4.4.x.x
{$if (lcl_major=4)and(lcl_minor=4)}
    {$if (lcl_release=0)or(lcl_patch=0)}
        {$define FSzOL_implementation_verified}
    {$endIf}
{$endIf}

{$ifNdef FSzOL_implementation_verified} // сообщим что в этой версии я Не тестил
{$warning ---------------------------------------------------------------------}
{$warning    Screen.MoveFormToZFront NOT verified in this version LCL.         }
{$warning    SzOF_listFT2F may be working with errors.                         }
{$warning ---------------------------------------------------------------------}
{$endif}
{%endregion}

// Создать список форм, находящихся МЕЖДУ `TOP-формой` и `form`
function SzOF_listFT2F_make(const form:TCustomForm):tListFT2F;
var i:integer;
begin {$ifOPT D+}
      Assert(Screen.CustomFormZOrderCount>1,'`Screen`: forms in the application is too small, should be more than two');
      Assert(Assigned(form),'`form`: must be defined');
      Assert(Screen.CustomFormZIndex(form)>1,'`form`: wrong place, must be BELOW second plane');
      {$endIf}
    result:=nil;
    SetLength(result, Screen.CustomFormZIndex(form)-1);
    for i:=1 to Screen.CustomFormZIndex(form)-1 do begin
        result[i-1]:=Screen.CustomFormsZOrdered[i];
    end;
end;

//------------------------------------------------------------------------------

procedure SzOF_listFT2F_zFIX(const fTop,form:TCustomForm);
begin {$ifOPT D+}
      Assert(Assigned(fTop),'`fTop`: must be defined ');
      Assert(SzOW_form_is_TOP_inZOrder(fTop),'`fTop`: must be TOP form of the application');
      Assert(Assigned(form),'`form`: must be defined');
      {$endIf}
    Screen.MoveFormToZFront(form);
    Screen.MoveFormToZFront(fTop);
end;

// Исправить порядок следования форм в `zIndex-списка` окон приложения
// а вот интересно, чего я так сложно делать стал .. гм .. вопросс
procedure SzOF_listFT2F_zFIX(const fTop,form:TCustomForm; const list:tListFT2F);
var i:integer;
begin {$ifOPT D+}
      Assert(Assigned(list),'`list`: must be defined');
      Assert(Length(list)>0,'`list`: the number of elements must be greater than zero');
      {$endIf}
    for i:= Length(list)-1 downto 0 do begin
        {$ifOPT D+}
        Assert(list[i]<>fTop,'`fTop`: placed in `list`, it is ERROR');
        Assert(list[i]<>form,'`form`: placed in `list`, it is ERROR');
        {$endIf}
        Screen.MoveFormToZFront(list[i]);
    end;
    SzOF_listFT2F_zFIX(fTop,form);
end;

//------------------------------------------------------------------------------

// уничтожить список
procedure SzOF_listFT2F_free(var list:tListFT2F);
begin {$ifOPT D+} Assert(Assigned(list),'WRONG: list=nil'); {$endIf}
    SetLength(list,0)
end;

end.

