
in0k-bringToSecondPlane
=======================

[Units][L1] for use in [Lazarus][L2] [LCL][L3].


Target
------

Single function `bringToSecond`:
move window (`tForm`) to the SECOND position
in the Z-Order list of application windows.


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



Structure
---------

* `uBringToSecond.pas` **generalized** version.
   If possible, use a **native** implementation for the target platform.
   If there is no implementation, it is a cross-platform version.
* `uBringToSecond_LCL.pas` cross-platform version
   * the functionality of the `bringToSecond` procedure
     is achieved by two consecutive calls to the standard `tForm.bringToFront`
   * :shit: periodically noticeable characteristic flickering of the interface.
     :+1:   should work on ALL platforms
* `uBringToSecond_WIN.pas`   use functions **WinAPI**
* `uBringToSecond_X11.pas`   use functions **xlib**
* `uBringToSecond_GtkX.pas`  use functions **Gtk**
* `uBringToSecond_QtX.pas`   use functions **Qt**
* `uBringToSecond_cocoa.pas` use functions **NSWindow**



Compatibility
-------------

   |              |win32/64|x11/xlib|  GTK2  |  GTK3  |   Qt4  |   Qt5  | cocoa  |
   |:-------------|:------:|:------:|:------:|:------:|:------:|:------:|:------:|
   | `.._LCL.pas` |  [::]  |  [::]  |  [::]  |  [::]  |  [::]  |  [::]  |  [::]  |
   | `.._WIN.pas` |  [+]   |        |  [+]   |        |  [#]   |  [+]   |        |
   | `.._X11.pas` |        |        |  [+]   |        |  [+]   |  [+]   |        |
   | `.._GtkX.pas`|  [~1]  |        |  [+]   |  [+]   |        |        |        |
   | `.._QtX.pas` |  [~2]  |        |        |        |  [~3]  |  [~3]  |        |
   | `..cocoa.pas`|        |        |        |        |        |        |  [+]   |

- `[::]` - should work EVERYWHERE, where there is Lazarus
- `[+] ` - implemented, tested
- `[#] ` - implemented, NOT tested
- `[~1]` - used `gdk_window_restack` INCORRECT works under `WINDOWS`,
           the implementation is similar to `LCL`
           but with `GTK` methods ( [+] GTK2; [#] GTK3 ).
- `[~2]` - the necessary methods do not EXIST,
           the implementation is similar to `LCL`
           but with `Qt` methods ( [#] Qt4; [+] Qt5 ).
- `[~3]` - the necessary methods do not EXIST,
           the implementation is similar to `LCL`
           but with `Qt` methods ( [+] Qt4; [+] Qt5 ).



Usage
-----

1. Place the source code of the library into the folder `%SomeDIR%`
   (clone the repository or [download][R] the latest version).
2. In the project settings, specify the folder `%SomeDIR%`
   in [other unit files][L4].
3. Using in code:

     ```pascal    
        uses ...
             uBringToSecond,
             ...;
        
        ..
        bringToSecond(myForm);
        ..
     ```    



DEMO
====

For a ready-to-study example, see in [repository][D] of demo project.


[L1]: http://wiki.lazarus.freepascal.org/Unit
[L2]: https://www.lazarus-ide.org/
[L3]: http://wiki.lazarus.freepascal.org/LCL
[L4]: http://wiki.lazarus.freepascal.org/IDE_Window:_Project_Options#Other_Unit_Files
[R]:  https://github.com/in0k-pas-src/in0k-bringToSecondPlane_src/releases
[D]:  https://github.com/in0k-pas-prj/in0k-bringToSecondPlane

