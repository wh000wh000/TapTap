class SetUp {
    static setUpFile := A_WorkingDir . "\Lib\TapTap.ini"
    static dict := {HotKey: "Control"}
    __new() {
        this.ReadSetUpFile()
    }

    ReadSetUpFile() {
        configFile := SetUp.setUpFile
        if !FileExist(configFile) {
			return
		}
        try {
            Loop, read, %configFile%
            {
               if (Trim(A_LoopReadLine) = "" or InStr(A_LoopReadLine, "#"))	; '#'을 포함한 줄은 모두 제거
                   continue
               if ((pos := InStr(A_LoopReadLine, "=")) = 0) {
                   Throw, "TapTap 설정 구문 해석 에러"
               }
               key := Trim(SubStr(A_LoopReadLine, 1, pos - 1))
               value := Trim(SubStr(A_LoopReadLine, pos + 1))
               SetUp[key] = value
            }
        } catch e {
			MsgBox, 16, TapTap이 설정 파일, %e%
			ExitApp
		}
    }

    WriteSetUpFile() {
        configFile := SetUp.setUpFile
        if FileExist(configFile) {
			return
		}
        FileEncoding, UTF-8
        FileAppend,
(
#
# 탭탭이 환경 설정
#

# 탭탭이 기동 시 사용할 핫키 지정
# Control, Alt, Shift, F1 ~ F12 등...
), %configFile%
        for key, value in SetUp.dict {
            line := key . "=" . value
            FileAppend , line, %configFile%, UTF-8
        }
    }
}
