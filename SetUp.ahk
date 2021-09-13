class SetUp {
    static setUpFile := A_WorkingDir . "\Lib\_SetUp\TapTap.SetUp"
    static modificationTime = ""
    static dict = ""
    __new() {
        this.MakeDict()
    }

    GetValue(key) {
        this.ListDict()
        return SetUp.dict[key]
    }

    ListDict() {
        ; ini 날짜 비교, ini 파일 수정 시만 새로 List 작업
		setUpFile := SetUp.setUpFile
		FileGetTime, fileTime , % setUpFile, M
		if (SetUp.modificationTime = fileTime) {
			return
		}
    	this.MakeDict()
    }
    MakeDict() {
        FileEncoding, UTF-8-RAW
        ; MsgBox, %A_FileEncoding%
        ; MsgBox, % DllCall("GetACP")
        setUpFile := SetUp.setUpFile
        if !FileExist(setUpFile) {
			this.CreateSetUpFile()
		}

        try {
            SetUp.dict := {}
            Loop, read, %setUpFile%
            {
               if (Trim(A_LoopReadLine) = "" or InStr(A_LoopReadLine, "#"))	; '#'을 포함한 줄은 모두 제거
                   continue
               if ((pos := InStr(A_LoopReadLine, "=")) = 0) {
                   Throw, "TapTap 환경 설정 구문 해석 에러"
               }
               key := Trim(SubStr(A_LoopReadLine, 1, pos - 1))
               value := Trim(SubStr(A_LoopReadLine, pos + 1))
               SetUp.dict[key] := value
            }
        } catch e {
			MsgBox, 16, TapTap이 설정, %e%
			ExitApp
		}

        FileGetTime, fileTime , % setUpFile, M
        SetUp.modificationTime := fileTime
    }

    ; 한글이 전부 깨짐 -> 사용 불가
    CreateSetUpFile() {
        setUpFile := SetUp.setUpFile
        FileAppend,
(
#
# 탭탭이 환경 설정
#
), %setUpFile%
        FileAppend ,
(

# 탭탭이 기동 시 사용할 핫키 지정
# Control, Alt, Shift, F1 ~ F12 등...
Hotkey=Control
), %setUpFile%
        FileAppend ,
(

# 탭탭이 별칭 입력 상자(Alias Run Box, ARB)의 가로 길이(Pixel)
ArbWidth=400
), %setUpFile%
    }
}
