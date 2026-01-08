
in0k-bringToSecondPlane
=======================

Библиотека [модулей][L1] для использования в [Lazarus][L2] [LCL][L3].


Назначение
----------

Единственная функция `bringToSecond`:
переместить окно (`tForm`) на ВТОРУЮ позицию списка Z-Order окон приложения.

      Z-Index

      T0P   Wnd00                 +--> Wnd_A                      Wnd_A
       1    Wnd01                 |    Wnd00                 +--> Wnd_B
       2     ...                  |    Wnd01                 |    Wnd00
       3     ...                  |     ...                  |    Wnd01
      ...    ...                  |     ...                  |
       N    bringToSecond(Wnd_A)--^     ...                  |
       M     ...                       bringToSecond(Wnd_B)--^
      ...    ...                        ...
      .................................................................
      DeskTop DeskTop DeskTop  DeskTop DeskTop  DeskTop DeskTop DeskTop



Состав
------

* `uBringToSecond.pas` **обобщенный** вариант.
   По возможности использует **нативную** реализацию для целевой платформы.
   Если реализации нет, то кроссплатформенный вариант.
* `uBringToSecond_LCL.pas` кроссплатформенный вариант
   * Функционал процедуры `bringToSecond` достигается двумя
     последовательными вызовами стандартного метода `tForm.bringToFront`.
   * :shit: периодически заметно характерное мерцание интерфейса.
     :+1:   должно работать на ВСЕХ платформах
* `uBringToSecond_WIN.pas`  используются функции **WinAPI**
* `uBringToSecond_X11.pas`  используются функции **xlib**
* `uBringToSecond_GtkX.pas` используются методы  **Gtk**
* `uBringToSecond_QtX.pas`  используются методы  **Qt***
* `uBringToSecond_cocoa.pas`  используются методы  **NSWindow**


 ::include{file=chapter1.md}


Таблица совместимости
---------------------

   |              |win32/64|x11/xlib|  GTK2  |  GTK3  |   Qt4  |   Qt5  | cocoa  |
   |:-------------|:------:|:------:|:------:|:------:|:------:|:------:|:------:|
   | `.._LCL.pas` |  [::]  |  [::]  |  [::]  |  [::]  |  [::]  |  [::]  |  [::]  |
   | `.._WIN.pas` |  [+]   |        |  [+]   |        |  [#]   |  [+]   |        |
   | `.._X11.pas` |        |        |  [+]   |        |  [+]   |  [+]   |        |
   | `.._GtkX.pas`|  [~1]  |        |  [+]   |  [+]   |        |        |        |
   | `.._QtX.pas` |  [~2]  |        |        |        |  [~3]  |  [~3]  |        |
   | `..cocoa.pas`|        |        |        |        |        |        |  [+]   |

- `[::]` - должно работать ВЕЗДЕ, где присутствует Lazarus
- `[+] ` - реализовано, тестировано
- `[#] ` - реализовано, НЕ тестировано
- `[~1]` - используемая функция `gdk_window_restack` НЕКОРРЕКТНО
           работает под `WINDOWS`,
           реализация аналогична `LCL` но методами `GTK` ( [+] GTK2; [#] GTK3 ).
- `[~2]` - в связи с ОТСУТСТВИЕМ необходимых методов,
           реализация аналогична `LCL` но методами `Qt` ( [#] Qt4; [+] Qt5 ).
- `[~3]` - в связи с ОТСУТСТВИЕМ необходимых методов,
           реализация аналогична `LCL` но методами `Qt` ( [+] Qt4; [+] Qt5 ).



Применение
----------

1. Поместите исходники библиотеки в папку `%SomeDIR%`
   (клонируйте репозиторий или [скачайте][Z] последнюю версию).
2. В параметрах проекта укажите `%SomeDIR%` в [путях поиска][L4].
3. Использование в коде:

     ```pascal    
        uses ...
             uBringToSecond,
             ...;
        
        ..
        bringToSecond(myForm);
        ..
     ```



ДЕМО
====

Готовый для исследования пример смотрите в [репозитории][D] демо проекта.



[L1]: http://wiki.lazarus.freepascal.org/Unit
[L2]: https://www.lazarus-ide.org/
[L3]: http://wiki.lazarus.freepascal.org/LCL
[L4]: http://wiki.lazarus.freepascal.org/IDE_Window:_Project_Options#Other_Unit_Files
[R]:  https://github.com/in0k-pas-src/in0k-bringToSecondPlane_src/releases
[D]:  https://github.com/in0k-pas-prj/in0k-bringToSecondPlane






