/*
    탭탭이(TapTap) 기동(부팅) 시,
    자동 실행 루틴
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, Force

#Include, Lib\AHK\WifeWatch.ahk
#Include, Lib\AHK\ScreenSaver.ahk

; arg := A_Args[1]
; MsgBox, 0, 전달받은 인자, %arg%, 5

new WifeWatch() ; 색시 시계
new ScreenSaver()   ; 마우스 포인터를 화면 좌상단(0, 0) 으로 가져가면 화면 보호기 실행
