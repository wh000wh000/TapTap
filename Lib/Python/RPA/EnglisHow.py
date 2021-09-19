import os
import time
import pyautogui as pag
# import keyboard -> pynput으로 변경
from pynput import keyboard
from PyQt5.QtCore import QTime, QTimer
import pyperclip
import sys
import webbrowser
from win32com.client import GetObject


class EnglisHow():
    '''EnglisHow.co.kr 자동 로그인 출석 체크'''

    def __init__(self):
        super().__init__()
        self.is_logging = False
        # Image 폴더 위치 지정
        self.image_dir = os.path.join(os.getcwd(), 'Lib\\Python\\RPA\\Image')
        self.run_english_timer()
        print(os.getcwd())
        print(self.image_dir)
        pag.sleep(10)

    # keyboard 용 -> pynput 으로 변경
    # def stop_login_by_esc(self, key):
    #     '''ESC키로 로그인 무한 루프 빠져 나오기'''
    #     if self.is_logging:
    #         self.is_logging = False
            # print(f'Escape 키 눌림: {key}')

    def stop_login_by_esc(self, key):
        '''ESC키로 로그인 무한 루프 빠져 나오기'''
        if key == keyboard.Key.esc:
            # isinstance(key, keyboard.Key) and key.name == 'esc':
            self.is_logging = False
            return False    # Stop listener

    def run_english_timer(self):
        if not hasattr(self, "english_timer"):
            self.need_to_login = False
            # self.english_timer = QTimer()
            # self.english_timer.timeout.connect(self.adjust_timer)
            # self.english_timer.setInterval(1000)
            # self.english_timer.start()

    def test_login(self):
        '''즉시 login 시도'''
        # self.english_timer.stop()
        # self.english_timer.setInterval(1000)    # 1초 후, 로그인 시도
        self.need_to_login = True
        # self.english_timer.start()
        self.adjust_timer()

    def adjust_timer(self):
        '''점진형 타이머 by 1시간'''
        # self.english_timer.stop()
        if self.need_to_login:
            self.login()
        # target_time = QTime.fromString('23:59:25','hh:mm:ss')   # login 시간: test 시, test_login() 사용할 것
        # currtime = QTime.currentTime()
        # diff_to_target = currtime.secsTo(target_time)
        # if diff_to_target < 0 or diff_to_target > 3600:
        #     interval = 60 * 60 * 1000
        #     self.need_to_login = False
        # else:
        #     interval = diff_to_target * 1000
        #     self.need_to_login = True
        # self.english_timer.setInterval(interval)
        # self.english_timer.start()
        # print(f'남은 시간: {diff_to_target}초, 세팅 시간: {interval}')

    def login(self):
        if self.is_logging:
            return
        try:
            self.is_logging = True
            # keyboard.on_press_key('esc', self.stop_login_by_esc)  # keyboard -> pynput 으로 변경
            self.keyboard_listener = keyboard.Listener(
                on_press=self.stop_login_by_esc
            )
            self.keyboard_listener.start()

            self.start_Time = QTime.currentTime()
            # print(f'자동 로그인 시작: {self.start_Time.toString("hh:mm:ss.zzz")}')
            win = None
            # 크롬 열기
            if self.is_logging:
                # os.startfile('Chrome')
                url = "http://www.englishow.co.kr"
                # webbrowser.open(url, new=2)
                webbrowser.open_new_tab(url)
                pag.sleep(3)

            # 크롬 최대화
            if self.is_logging:
                wins = pag.getWindowsWithTitle('Chrome')
                if wins:
                    win = wins[0]
                    if not win.isActive:
                        win.activate()
                        for _ in range(10):
                            pag.sleep(0.2)
                            if win.isActive:
                                break
                    if not win.isMaximized:
                        win.maximize()
                        for _ in range(10):
                            pag.sleep(0.3)
                            if win.isMaximized:
                                break
                else:
                    print('Chrome이 열리지 않았습니다.')

            # 이상 종료 복구 제거
            if self.is_logging:
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'chrome_fix.png'), confidence=0.8)
                if elem:
                    print('이상 종료 확인 클릭')
                    pag.click(elem)

            # 로그 아웃
            if self.is_logging:
                # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_logout.png'))
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'english_logout.png'), confidence=0.8)
                if elem:
                    print('로그 아웃')
                    pag.click(elem)
                    pag.sleep(3)
                    while True:
                        # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_login.png'))
                        elem = pag.locateOnScreen(os.path.join(self.image_dir, 'english_login.png'), confidence=0.8)
                        if elem:
                            break
                        else:
                            pag.hotkey('f5')
                            pag.sleep(2)

            # 로그 인
            if self.is_logging:
                # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_title.png'))
                # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_login.png'))
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'english_login.png'), confidence=0.8)
                if elem:
                    print('로그인')
                    pag.moveTo(elem)
                    pag.move(xOffset=-135, yOffset=-35) # id from login button
                    pag.click()
                    pyperclip.copy('rtos9er@gmail.com')
                    # pyperclip.copy('the9er@gmail.com')
                    # pyperclip.copy('good9er@gmail.com')
                    # pyperclip.copy('mart9er@gmail.com')
                    # pyperclip.copy('rtos9er@naver.com')
                    pag.hotkey('ctrl', 'v')
                    pag.sleep(1)
                    # pag.move(xOffset=0, yOffset=32) # pw from id
                    pag.press('tab')
                    pag.sleep(1)
                    pyperclip.copy('wecando9')
                    pag.hotkey('ctrl', 'v')
                    pag.sleep(1)
                    # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_login.png'))
                    elem = pag.locateOnScreen(os.path.join(self.image_dir, 'english_login.png'), confidence=0.8)
                    pag.click(elem)
                    pag.sleep(3)
            # 비밀번호 변경 제거
            if self.is_logging:
                # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_pw_change.png'))
                # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'english_pw_change.png'), confidence=0.8)
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_pw_change.png'), confidence=0.8)
                if elem:
                    print('비밀번호 변경 확인 클릭')
                    pag.click(elem)
                # else:
                #     pag.click(1502, 399)

            # 출석 화면
            if self.is_logging:
                url = 'http://www.englishow.co.kr/attendance'
                webbrowser.open(url, new=0)
                pag.sleep(5)

            is_presented = False
            try_num = 0
            print(f'출석 중... {QTime.currentTime().toString("hh:mm:ss")}')
            while self.is_logging:
                try_num += 1
                # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_present_already.png'))
                # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'englishow_present_mark.png'))
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'english_present_mark.png'), region=(1280, 1020, 400, 80), confidence=0.8)
                if elem:
                    print(f'출석 마크 클릭: {QTime.currentTime().toString("hh:mm:ss.zzz")}')
                    pag.click(elem)
                    is_presented = True
                else:
                    if is_presented:
                        print('출석 완료')
                        break
                    print(f'{try_num}: 출석 마크 없음')

                print('Press F5 to refresh')
                pag.press('f5')
                pag.sleep(1)
                # elem = pag.locateOnScreen(os.path.join(self.image_dir, 'english_refresh.png'), confidence=0.8)
                # if elem:
                #     print('Refresh 버튼 클릭')
                #     pag.click(elem)
                #     pag.sleep(1)

                # 무한 도전 막기 00:02:00 넘으면 종료
                # now = QTime.currentTime()   # ToDo: 235991 초
                # if (self.start_Time.toString('hhmmss') > '235900' and
                #         now.toString('hh') == '00' and now.toString('mmss') > '0200'):
                #     break
                # elif self.start_Time.secsTo(now) > 30:  # when Test
                #     break

                # if keyboard.read_key() == 'esc': # 블록됨 cf. pynput: keyboard.Key.esc
                # if keyboard.is_pressed('esc'):
                #     break

            if is_presented:
                pag.sleep(5)
                # 이미 출석하셨습니다.
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'english_already_present.png'), confidence=0.8)
                if elem:
                    print('이미 출석 완료 확인')
                    pag.click(elem)

        except Exception as e:
            print(e)
        finally:
            # 크롬 화면 원위치
            if win is not None:
                win.restore()
            if self.is_logging:
                if self.start_Time.toString('hhmmss') > '235900':   # ToDo: 235991 초
                    elapsed = 60 - int(self.start_Time.toString('ss'))
                    elapsed2 = int(QTime.currentTime().toString('hhmmss'))
                    print(f'소요 시간: {elapsed + elapsed2} 초')
                else:   # when Test
                    elapsed = int(self.start_Time.toString('hhmmss'))
                    elapsed2 = int(QTime.currentTime().toString('hhmmss'))
                    print(f'소요 시간: {elapsed2 - elapsed} 초')
            self.is_logging = False
            print('잉하 로그인 종료')
            # pag.sleep(30)


if __name__ == '__main__':
    인자 = ""
    for i, arg in enumerate(sys.argv):
        인자 += f"명령어 인자( {i} ): {arg}\n"
    print(인자)
    time.sleep(10)
    e = EnglisHow()
    # e.test_login()
