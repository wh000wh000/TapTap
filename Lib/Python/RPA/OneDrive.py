import os
import pyautogui as pag
import pyperclip
import time
import webbrowser


class OneDrive:
    '''마이크로소프트 OneDrive 자동 로그인
    '''

    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, '_OneDrive__singleton'):
            cls.__singleton = super().__new__(cls)
        return cls.__singleton

    def __init__(self):
        cls = type(self)
        if not hasattr(cls, '_OneDrive__init'):
            cls.__init = True
            super().__init__()
            # Image 폴더 위치 지정
            self.image_dir = os.path.join(os.getcwd(), 'Lib\\Python\\RPA\\Image')

    def login(self):
        try:
            # self.start_time = time.time()
            # 크롬 열기
            url = "https://login.microsoftonline.com"
            webbrowser.open_new_tab(url)
            pag.sleep(3)
            win = pag.getWindowsWithTitle('Chrome')[0]
            if not win.isActive:
                win.activate()
                for _ in range(10):
                    pag.sleep(0.2)
                    if win.isActive:
                        break
            # 로그인
            elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_choice.png'), confidence=0.8)
            if elem:
                # print('계정 선택 진입')
                pag.click(elem)
                pag.sleep(1)
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_choice_one.png'), confidence=0.8)
                if elem:
                    # print('계정 선택 클릭')
                    pag.click(elem)
                    pag.sleep(3)
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_ready.png'), confidence=0.8)
                if elem:
                    # print('계정 선택 클릭')
                    pag.click(elem)
                    pag.sleep(3)
            else:
                # print('로그인 진입')
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_id.png'), confidence=0.8)
                if elem:
                    pag.moveTo(elem)
                    # print(f'로그인 좌표: {elem}')
                    pag.move(xOffset=0, yOffset=60) # id from login button
                    pag.click()
                    pyperclip.copy('rtos9er@od.168826.xyz')
                    pag.hotkey('ctrl', 'v')
                    pag.sleep(1)
                    elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_next.png'), confidence=0.8)
                    pag.click(elem)
                    pag.sleep(3)

            elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_pw.png'), confidence=0.8)
            if elem:
                pag.moveTo(elem)
                # print(f'Password 좌표: {elem}')
                pag.move(xOffset=0, yOffset=60) # pw from login button
                pag.click()
                pyperclip.copy('lenovo100!')
                pag.hotkey('ctrl', 'v')
                pag.sleep(1)
                elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_login.png'), confidence=0.8)
                pag.click(elem)
                pag.sleep(3)

            # 로그인 유지 제거
            elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_pass.png'), confidence=0.8)
            if elem:
                # print('로그인 유지 NO 클릭')
                pag.click(elem)

            # 자세한 정보 필요 제거
            elem = pag.locateOnScreen(os.path.join(self.image_dir, 'one_drive_detail_info.png'), confidence=0.8)
            if elem:
                # print('자세한 정보 필요 다음 클릭')
                pag.click(elem)

        except Exception as e:
            print(e)
        finally:
            # print('OneDrive Login 소요 시간:', self.start_time - time.time())
            # 크롬 화면 원위치
            win.restore()
            pag.sleep(10)


if __name__ == '__main__':
    od = OneDrive()
    od.login()
