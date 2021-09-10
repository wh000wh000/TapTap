#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
; FileEncoding, UTF-16    ; 한글 사용을 위해 UTF-16 적용

/*
    탭탭이(TapTap)에서 사용할 "한 글자" 핫키 설정
    영문자는 대문자만 핫키로 사용.
*/
; 숫자 핫키 테스트
T_Hotkey_1:   ; '1'키 Hotkey
인사말 := "안녕하세요, 탭탭이입니다!`n`n이 창은 5초 후 사라집니다."
MsgBox, , 대화 창, %인사말%, 5
return

; 탭탭이 종료
T_Hotkey_Q:   ; 'Q'키 Hotkey
(new T_TapTapHelper()).ExitTapTap()
return

; 탭탭이 재 실행
T_HotKey_R:   ; 'R'키 Hotkey
(new T_TapTapHelper()).ReloadTapTap()
return

/*
    탭탭이에서 사용하는 오토핫키 핫키
*/
; 탭탭이(TapTap) ARB 기동 용 핫키 지정
; Control::   ; Control 키 Hotkey
Alt::       ; Alt 키 Hotkey
; Shift::     ; Shift 키 Hotkey
; F1::        ; F1 키 Hotkey
GoSub, T_ShowAliasRunBox ; 탭탭이 별칭 입력창(Alias Run Box) 보이기
return

/*
    탭탭이 관련 실행 루틴
*/
; 탭탭이 기동 시, 자동 실행 루틴
T_OnTapTapBoot:
; new Watch() ; 색시 시계
; new ScreenSaver()   ; 마우스 포인터를 화면 좌상단(0, 0) 으로 가져가면 화면 보호기 실행
return

/*
    Hotkey 용 실행 루틴 파일 Include
*/
#Include, Resources\AHK_Scripts\Watch.ahk
#Include, Resources\AHK_Scripts\ScreenSaver.ahk

/*
    탭탭이 도우미 클래스
    절대 지우거나 변경하지 마세요.
    도우미 클래스가 없으면, 탭탭이는 실행되지 않습니다.
*/
class T_TapTapHelper {
    static singleton := ""

    __New() {
        if (T_TapTapHelper.singleton = "")
            T_TapTapHelper.singleton := this
        else
            return T_TapTapHelper.singleton
    }

    RunBeforeTapTapRun() {
        try {
            GoSub, T_OnTapTapBoot
        } catch e {
            msg := "탭탭이 기동 루틴이 없습니다.`n" . e
            MsgBox, 16, Error, %msg%, 5
        }
    }

    RunTapTap() {
        this.RunBeforeTapTapRun()
        GoSub, T_TapTapMain
    }

    RunBeforeHotkeyRun(hotkey) {
        MsgBox, 64, 알림 창, %hotkey% 실행., 5
    }

    RunHotkey(hotkey) {
        this.RunBeforeHotkeyRun(hotkey)
        GoSub, %hotkey%
        this.RunAfterHotkeyRun(hotkey)
    }

    RunAfterHotkeyRun(hotkey) {
        MsgBox, 64, 알림 창, %hotkey% 종료., 5
    }

    RunBeforeTapTapQuit(hotkey) {
        MsgBox, 64, 알림 창, 탭탭이 종료., 5
    }

    ExitTapTap() {
        this.RunBeforeTapTapQuit()
        ExitApp
    }

    ReloadTapTap() {
        this.RunBeforeTapTapQuit()
        Reload
    }
}
