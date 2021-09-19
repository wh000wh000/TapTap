from bs4 import BeautifulSoup
import lxml
import pyperclip
import re
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
import time
from ArbLogger import ArbLogger

class Shopping:
    def __init__(self):
        # User-Agent
        self.headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36'}
        self.logger = ArbLogger().logger

    def check_old_vga(self, opt):
        try:
            browser = self.create_chrome_browser()
            self.logger.info(f'\n<<<<< 구형 Graphic Card {opt} 조사 >>>>>')
            self.logger.info('\n***** 다나와 장터 *****')
            url = 'http://dmall.danawa.com/v3/'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="gnbSearchKeyword"]')
            self.input_text_enter(browser, elem, opt)
            elem = browser.find_element_by_xpath('//*[@id="goodsListContainer"]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            tbody = soup.find('tbody', id='goodsListContainer')
            trs = tbody.find_all('tr')
            for tr in trs:
                td = tr.find('td', class_='subject')
                if td:
                    a = td.find('a')
                    title = a.get_text().strip()
                    lower = title.lower()
                    if ('본체' in lower or '인텔' in lower or 'amd' in lower or '세대' in lower or
                            '조립' in lower or '컴퓨터' in lower or '삽니' in lower):
                        continue
                    td = tr.find('td', class_='price')
                    date = td.find('span').get_text().strip()
                    self.logger.info(f'{title}, 일자: {date}')
                    href = a['href']
                    self.logger.info(f'{href}')

            self.logger.info('\n***** 중고 나라 *****')
            url = 'https://cafe.naver.com/joonggonara'
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="menuLink385"]').click()
            browser.switch_to.frame('cafe_main')
            elem = browser.find_element_by_xpath('//*[@id="query"]')
            self.input_text_enter(browser, elem, opt)
            elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find_all('div', class_='article-board m-tcol-c')[1]
            trs = div.find_all('tr')
            for tr in trs:
                td = tr.find('td', class_='td_article')
                if td:
                    a = td.find('a', class_='article')
                    title = a.get_text().strip()
                    if '매입' in title or '채굴기' in title:
                        continue
                    date = tr.find('td', class_='td_date').get_text().strip()
                    self.logger.info(f'{title}, 일자: {date}')
                    href = a['href']
                    self.logger.info(f'https://cafe.naver.com{href}')
            browser.switch_to.default_content()

            self.logger.info('\n***** 번개 장터 *****')
            url = 'https://m.bunjang.co.kr/'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[3]/div[1]/div[1]/div[1]/div[1]/input')
            self.input_text_enter(browser, elem, opt)
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[5]/div/div[4]/div')
            time.sleep(3)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            prod = soup.find('div', class_='sc-clBsIJ cpjxrb')
            if prod:
                divs = prod.find_all('div', class_='sc-eMRERa kYUAoX')
                for div in divs:
                    if div:
                        title = div.find('div', class_='sc-bqjOQT eTztLy').get_text().strip()
                        lower = title.lower()
                        if ('5600' in lower or '컴퓨터' in lower or '삽니' in lower or 'pc' in lower or '본체' in lower or '구합' in lower
                                or '크탑' in lower or '구매' in lower or '노트' in lower or '사요' in lower
                                or '구입' in lower):
                            continue
                        if pDiv := div.find('div', class_='sc-jkCMRl dtyXfw'):
                            price = pDiv.get_text().strip()
                        else:
                            continue
                        if timeDate := div.find('div', class_='sc-nrwXf hPnigT').find('span'):
                            tD = timeDate.get_text().strip()
                        else:
                            continue
                        self.logger.info(f'{title}, 가격: {price}, 일자: {tD}')
                        href = div.find('a', class_='sc-ciodno dTHXiR')['href'].strip()
                        self.logger.info(f'https://m.bunjang.co.kr{href}')
        except Exception as e:
            self.logger.info(e)
        finally:
            browser.quit()

    def check_3080(self, asus=False):
        try:
            self.logger.info('\n<<<<< RTX 3080 TI 조사 >>>>>')
            self.logger.info('\n***** 퀘이사존 >> 지름, 할인정보 *****')
            for page in range(1, 3):
                url = f'https://quasarzone.com/bbs/qb_saleinfo?_method=post&_token=xMC60o6LY2YYczM2TtVVPaxdJFwjXyguvs7mxwxc&category=PC%2F%ED%95%98%EB%93%9C%EC%9B%A8%EC%96%B4&kind=subject&sort=num%2C%20reply&direction=DESC&page={page}'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='market-type-list market-info-type-list relative').find('tbody').find_all('tr')
                for tr in trs:
                    div = tr.find('div', class_='market-info-list')
                    title = div.find('span', class_='ellipsis-with-reply-cnt').get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if '3080' in lower:
                        if asus and not ('아수스' in lower or 'asus' in lower):
                            continue
                        price = div.find('span', class_='text-orange').get_text().strip()
                        date = div.find('span', class_='date').get_text().strip()
                        self.logger.info(f'{title}, {price}, {date}')
                        href = div.find('a')['href'].strip()
                        self.logger.info(f'https://quasarzone.com{href}')

            self.logger.info('\n***** 쿨앤조이 >> 지름, 알뜰정보 *****')
            for page in range(1, 3):
                url = f'https://coolenjoy.net/bbs/jirum/p{page}?sca=PC%EA%B4%80%EB%A0%A8'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='tbl_head01 tbl_wrap').find('tbody').find_all('tr')
                for tr in trs:
                    a = tr.find('a')
                    title = a.get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if '3080' in lower:
                        if asus and not ('아수스' in lower or 'asus' in lower):
                            continue
                        date = tr.find('td', class_='td_date').get_text().strip()
                        self.logger.info(f'{title}, {date}')
                        href = a['href'].strip()
                        self.logger.info(href)

            browser = self.create_chrome_browser()
            self.logger.info('\n***** 에누리 *****')
            url = 'http://www.enuri.com/Index.jsp'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
            self.input_text_enter(browser, elem, 'rtx 3080')
            elem = browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[4]/div[1]/ul/li[1]/div/div[2]/div[1]/div[1]/a')
            browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[3]/div[2]/ul/li[2]').click()
            while True:
                newElem = browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[4]/div[1]/ul/li[1]/div/div[2]/div[1]/div[1]/a')
                if elem == newElem:
                    time.sleep(1)
                else:
                    break
            soup = BeautifulSoup(browser.page_source, 'lxml')
            ul = soup.find('ul', class_='goods-bundle')
            lis = ul.find_all('li')
            for li in lis:
                div = li.find('div', class_='item__model')
                if div:
                    a = div.find('a')
                    title = a.get_text().strip()
                    lower = title.lower()
                    if '오디세이' in lower:
                        continue
                    if asus and not ('아수스' in lower or 'asus' in lower):
                        continue
                    price = li.find('span', class_='tx--price').get_text().strip()
                    store = li.find('div', class_='opt--count').get_text().strip()
                    self.logger.info(f'{title}, 가격: {price} ({store})')
                    href = a['href'].strip()
                    self.logger.info(f'http://www.enuri.com{href}')

            self.logger.info('\n***** 다나와 *****')
            url = 'http://www.danawa.com/'
            browser.get(url)
            browser.implicitly_wait(5)
            url = 'http://prod.danawa.com/list/?cate=1131480'
            browser.get(url)
            browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
            time.sleep(2)
            browser.find_element_by_xpath('//*[@id="searchAttributeValueRep731869"]').click()
            time.sleep(2)
            browser.find_element_by_xpath('//*[@id="searchAttributeValueRep693448"]').click()
            time.sleep(2)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find('div', class_='main_prodlist main_prodlist_list')
            lis = div.find_all('li', class_='prod_item prod_layer width_change')
            for li in lis:
                div = li.find('div', class_='prod_info')
                a = div.find('a')
                href = a['href']
                title = a.get_text().strip()
                lower = title.lower()
                if asus and not ('아수스' in lower or 'asus' in lower):
                    continue
                div = li.find('div', class_='prod_pricelist')
                a = div.find('a')
                price = a.get_text().strip()
                self.logger.info(f'{title}, 가격: {price}')
                self.logger.info(href)

            self.logger.info('\n***** 중고 나라 *****')
            url = 'https://cafe.naver.com/joonggonara'
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="menuLink385"]').click()
            browser.switch_to.frame('cafe_main')
            # time.sleep(3)
            elem = browser.find_element_by_xpath('//*[@id="query"]')
            self.input_text_enter(browser, elem, '3080')
            elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find_all('div', class_='article-board m-tcol-c')[1]
            trs = div.find_all('tr')
            for tr in trs:
                td = tr.find('td', class_='td_article')
                if td:
                    a = td.find('a', class_='article')
                    title = a.get_text().strip()
                    lower = title.lower()
                    if '매입' in title or '이더' in title or '채굴' in title or '삽니' in title:
                        continue
                    if asus and not ('아수스' in lower or 'asus' in lower):
                        continue
                    date = tr.find('td', class_='td_date').get_text().strip()
                    self.logger.info(f'{title}, 일자: {date}')
                    href = a['href']
                    self.logger.info(f'https://cafe.naver.com{href}')
            browser.switch_to.default_content()

            self.logger.info('\n***** 번개 장터 *****')
            url = 'https://m.bunjang.co.kr/'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[3]/div[1]/div[1]/div[1]/div[1]/input')
            self.input_text_enter(browser, elem, '3080')
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[5]/div/div[4]/div')
            time.sleep(3)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            prod = soup.find('div', class_='sc-clBsIJ cpjxrb')
            if prod:
                divs = prod.find_all('div', class_='sc-eMRERa kYUAoX')
                for div in divs:
                    if div:
                        title = div.find('div', class_='sc-bqjOQT eTztLy').get_text().strip()
                        lower = title.lower()
                        if ('5600' in lower or '컴퓨터' in lower or '삽니' in lower or 'pc' in lower or '본체' in lower or '구합' in lower
                                or '크탑' in lower or '구매' in lower or '3060' in lower or '노트' in lower or '사요' in lower
                                or '이더' in lower or '채굴' in lower or 'i7' in lower):
                            continue
                        if asus and not ('아수스' in lower or 'asus' in lower):
                            continue
                        if pDiv := div.find('div', class_='sc-jkCMRl dtyXfw'):
                            price = pDiv.get_text().strip()
                        else:
                            continue
                        if timeDate := div.find('div', class_='sc-nrwXf hPnigT').find('span'):
                            tD = timeDate.get_text().strip()
                        else:
                            continue
                        self.logger.info(f'{title}, 가격: {price}, 일자: {tD}')
                        href = div.find('a', class_='sc-ciodno dTHXiR')['href'].strip()
                        self.logger.info(f'https://m.bunjang.co.kr{href}')
        except Exception as e:
            self.logger.info(e)
        finally:
            browser.quit()

    def check_3070(self, asus=False):
        try:
            self.logger.info('\n<<<<< RTX 3070 TI 조사 >>>>>')
            self.logger.info('\n***** 퀘이사존 >> 지름, 할인정보 *****')
            for page in range(1, 3):
                url = f'https://quasarzone.com/bbs/qb_saleinfo?_method=post&_token=xMC60o6LY2YYczM2TtVVPaxdJFwjXyguvs7mxwxc&category=PC%2F%ED%95%98%EB%93%9C%EC%9B%A8%EC%96%B4&kind=subject&sort=num%2C%20reply&direction=DESC&page={page}'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='market-type-list market-info-type-list relative').find('tbody').find_all('tr')
                for tr in trs:
                    div = tr.find('div', class_='market-info-list')
                    title = div.find('span', class_='ellipsis-with-reply-cnt').get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if '3070' in lower:
                        if asus and not ('아수스' in lower or 'asus' in lower):
                            continue
                        price = div.find('span', class_='text-orange').get_text().strip()
                        date = div.find('span', class_='date').get_text().strip()
                        self.logger.info(f'{title}, {price}, {date}')
                        href = div.find('a')['href'].strip()
                        self.logger.info(f'https://quasarzone.com{href}')

            self.logger.info('\n***** 쿨앤조이 >> 지름, 알뜰정보 *****')
            for page in range(1, 3):
                url = f'https://coolenjoy.net/bbs/jirum/p{page}?sca=PC%EA%B4%80%EB%A0%A8'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='tbl_head01 tbl_wrap').find('tbody').find_all('tr')
                for tr in trs:
                    a = tr.find('a')
                    title = a.get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if '3070' in lower:
                        if asus and not ('아수스' in lower or 'asus' in lower):
                            continue
                        date = tr.find('td', class_='td_date').get_text().strip()
                        self.logger.info(f'{title}, {date}')
                        href = a['href'].strip()
                        self.logger.info(href)

            browser = self.create_chrome_browser()
            self.logger.info('\n***** 에누리 *****')
            url = 'http://www.enuri.com/Index.jsp'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
            self.input_text_enter(browser, elem, 'rtx 3070')
            elem = browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[4]/div[1]/ul/li[1]/div/div[2]/div[1]/div[1]/a')
            browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[3]/div[2]/ul/li[2]').click()
            while True:
                newElem = browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[4]/div[1]/ul/li[1]/div/div[2]/div[1]/div[1]/a')
                if elem == newElem:
                    time.sleep(1)
                else:
                    break
            soup = BeautifulSoup(browser.page_source, 'lxml')
            ul = soup.find('ul', class_='goods-bundle')
            lis = ul.find_all('li')
            for li in lis:
                div = li.find('div', class_='item__model')
                if div:
                    a = div.find('a')
                    title = a.get_text().strip()
                    lower = title.lower()
                    if '오디세이' in lower:
                        continue
                    if asus and not ('아수스' in lower or 'asus' in lower):
                        continue
                    price = li.find('span', class_='tx--price').get_text().strip()
                    store = li.find('div', class_='opt--count').get_text().strip()
                    self.logger.info(f'{title}, 가격: {price} ({store})')
                    href = a['href'].strip()
                    self.logger.info(f'http://www.enuri.com{href}')

            self.logger.info('\n***** 다나와 *****')
            url = 'http://www.danawa.com/'
            browser.get(url)
            browser.implicitly_wait(5)
            url = 'http://prod.danawa.com/list/?cate=1131480'
            browser.get(url)
            browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
            time.sleep(2)
            browser.find_element_by_xpath('//*[@id="searchAttributeValueRep733033"]').click()
            time.sleep(2)
            browser.find_element_by_xpath('//*[@id="searchAttributeValueRep705343"]').click()
            time.sleep(2)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find('div', class_='main_prodlist main_prodlist_list')
            lis = div.find_all('li', class_='prod_item prod_layer width_change')
            for li in lis:
                div = li.find('div', class_='prod_info')
                a = div.find('a')
                href = a['href']
                title = a.get_text().strip()
                lower = title.lower()
                if asus and not ('아수스' in lower or 'asus' in lower):
                    continue
                div = li.find('div', class_='prod_pricelist')
                a = div.find('a')
                price = a.get_text().strip()
                self.logger.info(f'{title}, 가격: {price}')
                self.logger.info(href)

            self.logger.info('\n***** 중고 나라 *****')
            url = 'https://cafe.naver.com/joonggonara'
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="menuLink385"]').click()
            browser.switch_to.frame('cafe_main')
            # time.sleep(3)
            elem = browser.find_element_by_xpath('//*[@id="query"]')
            self.input_text_enter(browser, elem, '3070')
            elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find_all('div', class_='article-board m-tcol-c')[1]
            trs = div.find_all('tr')
            for tr in trs:
                td = tr.find('td', class_='td_article')
                if td:
                    a = td.find('a', class_='article')
                    title = a.get_text().strip()
                    lower = title.lower()
                    if '매입' in title or '이더' in title or '채굴' in title or '삽니' in title:
                        continue
                    if asus and not ('아수스' in lower or 'asus' in lower):
                        continue
                    date = tr.find('td', class_='td_date').get_text().strip()
                    self.logger.info(f'{title}, 일자: {date}')
                    href = a['href']
                    self.logger.info(f'https://cafe.naver.com{href}')
            browser.switch_to.default_content()

            self.logger.info('\n***** 번개 장터 *****')
            url = 'https://m.bunjang.co.kr/'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[3]/div[1]/div[1]/div[1]/div[1]/input')
            self.input_text_enter(browser, elem, '3070')
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[5]/div/div[4]/div')
            time.sleep(3)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            prod = soup.find('div', class_='sc-clBsIJ cpjxrb')
            if prod:
                divs = prod.find_all('div', class_='sc-eMRERa kYUAoX')
                for div in divs:
                    if div:
                        title = div.find('div', class_='sc-bqjOQT eTztLy').get_text().strip()
                        lower = title.lower()
                        if ('5600' in lower or '컴퓨터' in lower or '삽니' in lower or 'pc' in lower or '본체' in lower or '구합' in lower
                                or '크탑' in lower or '구매' in lower or '3060' in lower or '노트' in lower or '사요' in lower
                                or '이더' in lower or '채굴' in lower or 'i7' in lower):
                            continue
                        if asus and not ('아수스' in lower or 'asus' in lower):
                            continue
                        if pDiv := div.find('div', class_='sc-jkCMRl dtyXfw'):
                            price = pDiv.get_text().strip()
                        else:
                            continue
                        if timeDate := div.find('div', class_='sc-nrwXf hPnigT').find('span'):
                            tD = timeDate.get_text().strip()
                        else:
                            continue
                        self.logger.info(f'{title}, 가격: {price}, 일자: {tD}')
                        href = div.find('a', class_='sc-ciodno dTHXiR')['href'].strip()
                        self.logger.info(f'https://m.bunjang.co.kr{href}')
        except Exception as e:
            self.logger.info(e)
        finally:
            browser.quit()

    def check_cooler(self):
        try:
            self.logger.info('\n<<<<< 에너맥스 Liqmax III ARGB 360 블랙 조사 >>>>>')
            self.logger.info('\n***** 퀘이사존 >> 지름, 할인정보 *****')
            for page in range(1, 3):
                url = f'https://quasarzone.com/bbs/qb_saleinfo?_method=post&_token=xMC60o6LY2YYczM2TtVVPaxdJFwjXyguvs7mxwxc&category=PC%2F%ED%95%98%EB%93%9C%EC%9B%A8%EC%96%B4&kind=subject&sort=num%2C%20reply&direction=DESC&page={page}'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='market-type-list market-info-type-list relative').find('tbody').find_all('tr')
                for tr in trs:
                    div = tr.find('div', class_='market-info-list')
                    title = div.find('span', class_='ellipsis-with-reply-cnt').get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if ('에너맥스' in lower or 'liqmax' in lower) and '360' in lower:
                        price = div.find('span', class_='text-orange').get_text().strip()
                        date = div.find('span', class_='date').get_text().strip()
                        self.logger.info(f'{title}, {price}, {date}')
                        href = div.find('a')['href'].strip()
                        self.logger.info(f'https://quasarzone.com/{href}')

            self.logger.info('\n***** 쿨앤조이 >> 지름, 알뜰정보 *****')
            for page in range(1, 3):
                url = f'https://coolenjoy.net/bbs/jirum/p{page}?sca=PC%EA%B4%80%EB%A0%A8'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='tbl_head01 tbl_wrap').find('tbody').find_all('tr')
                for tr in trs:
                    a = tr.find('a')
                    title = a.get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if ('에너맥스' in lower or 'liqmax' in lower) and '360' in lower:
                        date = tr.find('td', class_='td_date').get_text().strip()
                        self.logger.info(f'{title}, {date}')
                        href = a['href'].strip()
                        self.logger.info(href)

            browser = self.create_chrome_browser()
            self.logger.info('\n***** 에누리 *****')
            url = 'http://www.enuri.com/Index.jsp'
            browser.get(url)
            browser.implicitly_wait(5)
            main_window = browser.current_window_handle
            elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
            self.input_text_enter(browser, elem, 'liqmax 360 블랙')
            browser.find_element_by_link_text('에너맥스 LIQMAX III ARGB 360').click()
            for window in browser.window_handles:
                if window != main_window:
                    browser.close()
                    browser.switch_to.window(window)
                    break
            elem = browser.find_element_by_xpath('//*[@id="prod_option_top"]/div/ul/li[1]/label').click()
            while True:
                title = browser.find_element_by_xpath('//*[@id="prod_summary_top"]/div[1]/h1').text.lower().strip()
                if '블랙' in title:
                    break
                else:
                    time.sleep(1)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find('div', id='special_price')
            ul = div.find('ul', class_='s_price__list')
            lis = ul.find_all('li')
            for li in lis:
                img = li.find('img')
                title = img['alt'].strip()
                price = li.find('span', class_='tx_price').get_text().strip()
                delivery = li.find('span', class_='delivery').get_text().strip()
                self.logger.info(f'판매처: {title}, 가격: {price}, 배송비: {delivery}')
                href = li.find('a')['href'].strip()
                self.logger.info(f'http://www.enuri.com{href}')

            self.logger.info('\n***** 다나와 *****')
            url = 'http://www.danawa.com/'
            browser.get(url)
            browser.implicitly_wait(5)
            url = 'http://prod.danawa.com/list/?cate=11336856'
            browser.get(url)
            browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
            browser.find_element_by_xpath('//*[@id="searchMakerRep3851"]').click()
            browser.find_element_by_xpath('//*[@id="searchAttributeValue198102"]').click()
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find('div', class_='main_prodlist main_prodlist_list')
            lis = div.find_all('li', class_='prod_item prod_layer')
            for li in lis:
                div = li.find('div', class_='prod_info')
                a = div.find('a')
                title = a.get_text().strip()
                if '에너맥스 LIQMAX III ARGB 360' in title:
                    url = a['href'].strip()
                    break
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="priceCompareArea"]/div[3]/ul/li[1]/div/div[1]/a').click()
            browser.find_element_by_xpath('//*[@id="blog_content"]/div[2]/div[2]/div[1]/div[2]/div[1]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            cardDiv = soup.find('div', class_='row lowest_price')
            a = cardDiv.find('a', class_='lwst_prc')
            cardPrice = a.get_text().strip()
            cardHref = a['href']
            cashDiv = soup.find('div', id='lowPriceCash')
            a = cashDiv.find('a', class_='lwst_prc')
            cashPrice = a.get_text().strip()
            cashHref = a['href']
            self.logger.info(f'현찰가: {cashPrice}')
            self.logger.info(cashHref)
            self.logger.info(f'카드가: {cardPrice}')
            self.logger.info(cardHref)

            self.logger.info('\n***** 중고 나라 *****')
            url = 'https://cafe.naver.com/joonggonara'
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="menuLink393"]').click()
            browser.switch_to.frame('cafe_main')
            elem = browser.find_element_by_xpath('//*[@id="query"]')
            self.input_text_enter(browser, elem, 'liqmax')
            elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find_all('div', class_='article-board m-tcol-c')[1]
            trs = div.find_all('tr')
            for tr in trs:
                td = tr.find('td', class_='td_article')
                if td:
                    a = td.find('a', class_='article')
                    title = a.get_text().strip()
                    lower = title.lower()
                    if '240' in lower:
                        continue
                    date = tr.find('td', class_='td_date').get_text().strip()
                    self.logger.info(f'{title}, 일자: {date}')
                    href = a['href']
                    self.logger.info(f'https://cafe.naver.com{href}')
            browser.switch_to.default_content()

            self.logger.info('\n***** 번개 장터 *****')
            url = 'https://m.bunjang.co.kr/'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[3]/div[1]/div[1]/div[1]/div[1]/input')
            self.input_text_enter(browser, elem, 'liqmax 360')
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[5]/div/div[4]/div')
            time.sleep(3)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            prod = soup.find('div', class_='sc-clBsIJ cpjxrb')
            if prod:
                divs = prod.find_all('div', class_='sc-eMRERa kYUAoX')
                for div in divs:
                    title = div.find('div', class_='sc-bqjOQT eTztLy').get_text().strip()
                    price = div.find('div', class_='sc-jkCMRl dtyXfw').get_text().strip()
                    timeDate = div.find('div', class_='sc-nrwXf hPnigT')
                    tD = timeDate.find('span').get_text().strip()
                    self.logger.info(f'{title}, 가격: {price}, 일자: {tD}')
                    href = div.find('a', class_='sc-ciodno dTHXiR')['href'].strip()
                    self.logger.info(f'https://m.bunjang.co.kr{href}')
        except Exception as e:
            self.logger.info(e)
        finally:
            browser.quit()

    def check_ram(self):
        try:
            self.logger.info('\n<<<<< 삼성 RAM 16GB 조사 >>>>>')
            self.logger.info('\n***** 퀘이사존 >> 지름, 할인정보 *****')
            for page in range(1, 3):
                url = f'https://quasarzone.com/bbs/qb_saleinfo?_method=post&_token=xMC60o6LY2YYczM2TtVVPaxdJFwjXyguvs7mxwxc&category=PC%2F%ED%95%98%EB%93%9C%EC%9B%A8%EC%96%B4&kind=subject&sort=num%2C%20reply&direction=DESC&page={page}'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='market-type-list market-info-type-list relative').find('tbody').find_all('tr')
                for tr in trs:
                    div = tr.find('div', class_='market-info-list')
                    title = div.find('span', class_='ellipsis-with-reply-cnt').get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if '삼성' in lower and ('ddr' in lower or '램' in lower or 'ram' in lower):
                        price = div.find('span', class_='text-orange').get_text().strip()
                        date = div.find('span', class_='date').get_text().strip()
                        self.logger.info(f'{title}, {price}, {date}')
                        href = div.find('a')['href'].strip()
                        self.logger.info(f'https://quasarzone.com/{href}')

            self.logger.info('\n***** 쿨앤조이 >> 지름, 알뜰정보 *****')
            for page in range(1, 3):
                url = f'https://coolenjoy.net/bbs/jirum/p{page}?sca=PC%EA%B4%80%EB%A0%A8'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='tbl_head01 tbl_wrap').find('tbody').find_all('tr')
                for tr in trs:
                    a = tr.find('a')
                    title = a.get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if '삼성' in lower and ('ddr' in lower or '램' in lower or 'ram' in lower):
                        date = tr.find('td', class_='td_date').get_text().strip()
                        self.logger.info(f'{title}, {date}')
                        href = a['href'].strip()
                        self.logger.info(href)

            browser = self.create_chrome_browser()
            self.logger.info('\n***** 에누리 *****')
            url = 'http://www.enuri.com/Index.jsp'
            browser.get(url)
            browser.implicitly_wait(5)
            main_window = browser.current_window_handle
            elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
            self.input_text_enter(browser, elem, '삼성 ddr4 16g')
            browser.find_element_by_link_text('삼성전자 DDR4 PC4-25600').click()
            for window in browser.window_handles:
                if window != main_window:
                    browser.close()
                    browser.switch_to.window(window)
                    break
            elem = browser.find_element_by_xpath('//*[@id="prod_option_top"]/div/ul/li[2]/label').click()
            while True:
                title = browser.find_element_by_xpath('//*[@id="prod_summary_top"]/div[1]/h1').text.lower().strip()
                if '16g' in title:
                    break
                else:
                    time.sleep(1)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find('div', id='special_price')
            ul = div.find('ul', class_='s_price__list')
            lis = ul.find_all('li')
            for li in lis:
                img = li.find('img')
                title = img['alt'].strip()
                price = li.find('span', class_='tx_price').get_text().strip()
                delivery = li.find('span', class_='delivery').get_text().strip()
                self.logger.info(f'판매처: {title}, 가격: {price}, 배송비: {delivery}')
                href = li.find('a')['href'].strip()
                self.logger.info(f'http://www.enuri.com{href}')

            self.logger.info('\n***** 다나와 *****')
            url = 'http://www.danawa.com/'
            browser.get(url)
            browser.implicitly_wait(5)
            url = 'http://prod.danawa.com/list/?cate=1131326'
            browser.get(url)
            browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
            browser.find_element_by_xpath('//*[@id="searchMakerRep702"]').click()
            browser.find_element_by_xpath('//*[@id="searchAttributeValueRep90210"]').click()
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find('div', class_='main_prodlist main_prodlist_list')
            lis = div.find_all('li', class_='prod_item prod_layer')
            for li in lis:
                div = li.find('div', class_='prod_info')
                a = div.find('a')
                title = a.get_text().strip()
                if '삼성전자 DDR4-3200' in title:
                    url = a['href'].strip()
                    break
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="priceCompareArea"]/div[3]/ul/li[2]/div/div[1]/a').click()
            browser.find_element_by_xpath('//*[@id="blog_content"]/div[2]/div[2]/div[1]/div[2]/div[1]/div[1]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            cardDiv = soup.find('div', class_='row lowest_price')
            a = cardDiv.find('a', class_='lwst_prc')
            cardPrice = a.get_text().strip()
            cardHref = a['href']
            cashDiv = soup.find('div', id='lowPriceCash')
            a = cashDiv.find('a', class_='lwst_prc')
            cashPrice = a.get_text().strip()
            cashHref = a['href']
            self.logger.info(f'현찰가: {cashPrice}')
            self.logger.info(cashHref)
            self.logger.info(f'카드가: {cardPrice}')
            self.logger.info(cardHref)

            self.logger.info('\n***** 중고 나라 *****')
            url = 'https://cafe.naver.com/joonggonara'
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="menuLink385"]').click()
            browser.switch_to.frame('cafe_main')
            elem = browser.find_element_by_xpath('//*[@id="query"]')
            self.input_text_enter(browser, elem, '삼성 16g')
            elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find_all('div', class_='article-board m-tcol-c')[1]
            trs = div.find_all('tr')
            for tr in trs:
                td = tr.find('td', class_='td_article')
                if td:
                    a = td.find('a', class_='article')
                    title = a.get_text().strip()
                    lower = title.lower()
                    if ('8g' in lower or 'ddr3' in lower or '213' in lower or '2666' in lower or
                            '삽니' in lower or '노트' in lower):
                        continue
                    date = tr.find('td', class_='td_date').get_text().strip()
                    self.logger.info(f'{title}, 일자: {date}')
                    href = a['href']
                    self.logger.info(f'https://cafe.naver.com{href}')
            browser.switch_to.default_content()

            self.logger.info('\n***** 번개 장터 *****')
            url = 'https://m.bunjang.co.kr/'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[3]/div[1]/div[1]/div[1]/div[1]/input')
            self.input_text_enter(browser, elem, '삼성 ddr 16g')
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[5]/div/div[4]/div')
            time.sleep(3)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            prod = soup.find('div', class_='sc-clBsIJ cpjxrb')
            if prod:
                divs = prod.find_all('div', class_='sc-eMRERa kYUAoX')
                for div in divs:
                    title = div.find('div', class_='sc-bqjOQT eTztLy').get_text().strip()
                    lower = title.lower()
                    if '삽니' in lower or '노트' in lower:
                        continue
                    price = div.find('div', class_='sc-jkCMRl dtyXfw').get_text().strip()
                    timeDate = div.find('div', class_='sc-nrwXf hPnigT')
                    tD = timeDate.find('span').get_text().strip()
                    self.logger.info(f'{title}, 가격: {price}, 일자: {tD}')
                    href = div.find('a', class_='sc-ciodno dTHXiR')['href'].strip()
                    self.logger.info(f'https://m.bunjang.co.kr{href}')
        except Exception as e:
            self.logger.info(e)
        finally:
            browser.quit()

    def check_ssd(self):
        try:
            self.logger.info('\n<<<<< 하이닉스 SSD P31 조사 >>>>>')
            self.logger.info('\n***** 퀘이사존 >> 지름, 할인정보 *****')
            for page in range(1, 3):
                url = f'https://quasarzone.com/bbs/qb_saleinfo?_method=post&_token=xMC60o6LY2YYczM2TtVVPaxdJFwjXyguvs7mxwxc&category=PC%2F%ED%95%98%EB%93%9C%EC%9B%A8%EC%96%B4&kind=subject&sort=num%2C%20reply&direction=DESC&page={page}'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='market-type-list market-info-type-list relative').find('tbody').find_all('tr')
                for tr in trs:
                    div = tr.find('div', class_='market-info-list')
                    title = div.find('span', class_='ellipsis-with-reply-cnt').get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if 'p31' in lower:
                        price = div.find('span', class_='text-orange').get_text().strip()
                        date = div.find('span', class_='date').get_text().strip()
                        self.logger.info(f'{title}, {price}, {date}')
                        href = div.find('a')['href'].strip()
                        self.logger.info(f'https://quasarzone.com/{href}')

            self.logger.info('\n***** 쿨앤조이 >> 지름, 알뜰정보 *****')
            for page in range(1, 3):
                url = f'https://coolenjoy.net/bbs/jirum/p{page}?sca=PC%EA%B4%80%EB%A0%A8'
                res = requests.get(url, headers=self.headers)
                res.raise_for_status()
                soup = BeautifulSoup(res.text, 'lxml')
                trs = soup.find('div', class_='tbl_head01 tbl_wrap').find('tbody').find_all('tr')
                for tr in trs:
                    a = tr.find('a')
                    title = a.get_text().strip()
                    lower = title.lower()
                    toPrint = False
                    if 'p31' in lower:
                        date = tr.find('td', class_='td_date').get_text().strip()
                        self.logger.info(f'{title}, {date}')
                        href = a['href'].strip()
                        self.logger.info(href)

            browser = self.create_chrome_browser()
            self.logger.info('\n***** 에누리 *****')
            url = 'http://www.enuri.com/Index.jsp'
            browser.get(url)
            browser.implicitly_wait(5)
            main_window = browser.current_window_handle
            elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
            self.input_text_enter(browser, elem, '하이닉스 p31')
            browser.find_element_by_link_text('SK하이닉스 GOLD P31 M.2 NVMe').click()
            for window in browser.window_handles:
                if window != main_window:
                    browser.close()
                    browser.switch_to.window(window)
                    break
            elem = browser.find_element_by_xpath('//*[@id="prod_option_top"]/div/ul/li[1]/label').click()
            # wait_time = 5
            # wait_variable = WebDriverWait(browser, wait_time)
            # wait_variable.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#special_price'))).click()
            # title = browser.find_element_by_xpath('//*[@id="prod_summary_top"]/div[1]/h1').text.lower().strip()
            while True:
                title = browser.find_element_by_xpath('//*[@id="prod_summary_top"]/div[1]/h1').text.lower().strip()
                if '500' in title:
                    time.sleep(1)
                else:
                    break
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find('div', id='special_price')
            ul = div.find('ul', class_='s_price__list')
            lis = ul.find_all('li')
            for li in lis:
                img = li.find('img')
                title = img['alt'].strip()
                price = li.find('span', class_='tx_price').get_text().strip()
                delivery = li.find('span', class_='delivery').get_text().strip()
                self.logger.info(f'판매처: {title}, 가격: {price}, 배송비: {delivery}')
                href = li.find('a')['href'].strip()
                self.logger.info(f'http://www.enuri.com{href}')

            self.logger.info('\n***** 다나와 *****')
            url = 'http://www.danawa.com/'
            browser.get(url)
            browser.implicitly_wait(5)
            url = 'http://prod.danawa.com/list/?cate=112760'
            browser.get(url)
            browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
            browser.find_element_by_xpath('//*[@id="searchMakerRep4131"]').click()
            browser.find_element_by_xpath('//*[@id="searchAttributeValueRep202347"]').click()
            browser.find_element_by_xpath('//*[@id="searchAttributeValueRep610817"]').click()
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find('div', class_='main_prodlist main_prodlist_list')
            lis = div.find_all('li', class_='prod_item prod_layer')
            for li in lis:
                div = li.find('div', class_='prod_info')
                a = div.find('a')
                title = a.get_text().strip()
                if 'SK하이닉스 Gold P31 M.2 NVMe' in title:
                    url = a['href'].strip()
                    break
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="priceCompareArea"]/div[3]/ul/li[1]/div/div[1]/a/span[2]').click()
            browser.find_element_by_xpath('//*[@id="blog_content"]/div[2]/div[2]/div[1]/div[2]/div[1]/div[1]/span[2]/a/em')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            cardDiv = soup.find('div', class_='row lowest_price')
            a = cardDiv.find('a', class_='lwst_prc')
            cardPrice = a.get_text().strip()
            cardHref = a['href']
            cashDiv = soup.find('div', id='lowPriceCash')
            a = cashDiv.find('a', class_='lwst_prc')
            cashPrice = a.get_text().strip()
            cashHref = a['href']
            self.logger.info(f'현찰가: {cashPrice}')
            self.logger.info(cashHref)
            self.logger.info(f'카드가: {cardPrice}')
            self.logger.info(cardHref)

            self.logger.info('\n***** 중고 나라 *****')
            url = 'https://cafe.naver.com/joonggonara'
            browser.get(url)
            browser.implicitly_wait(5)
            browser.find_element_by_xpath('//*[@id="menuLink386"]').click()
            browser.switch_to.frame('cafe_main')
            elem = browser.find_element_by_xpath('//*[@id="query"]')
            self.input_text_enter(browser, elem, '하이닉스 p31')
            elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
            soup = BeautifulSoup(browser.page_source, 'lxml')
            div = soup.find_all('div', class_='article-board m-tcol-c')[1]
            trs = div.find_all('tr')
            for tr in trs:
                td = tr.find('td', class_='td_article')
                if td:
                    a = td.find('a', class_='article')
                    title = a.get_text().strip()
                    lower = title.lower()
                    if '500' in lower or '노트북' in lower:
                        continue
                    date = tr.find('td', class_='td_date').get_text().strip()
                    self.logger.info(f'{title}, 일자: {date}')
                    href = a['href']
                    self.logger.info(f'https://cafe.naver.com{href}')
            browser.switch_to.default_content()

            self.logger.info('\n***** 번개 장터 *****')
            url = 'https://m.bunjang.co.kr/'
            browser.get(url)
            browser.implicitly_wait(5)
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[3]/div[1]/div[1]/div[1]/div[1]/input')
            self.input_text_enter(browser, elem, '하이닉스 p31')
            elem = browser.find_element_by_xpath('//*[@id="root"]/div/div/div[5]/div/div[4]/div')
            time.sleep(3)
            soup = BeautifulSoup(browser.page_source, 'lxml')
            prod = soup.find('div', class_='sc-clBsIJ cpjxrb')
            if prod:
                divs = prod.find_all('div', class_='sc-eMRERa kYUAoX')
                for div in divs:
                    title = div.find('div', class_='sc-bqjOQT eTztLy').get_text().strip()
                    lower = title.lower()
                    if '삽니' in lower or '노트북' in lower:
                        continue
                    price = div.find('div', class_='sc-jkCMRl dtyXfw').get_text().strip()
                    timeDate = div.find('div', class_='sc-nrwXf hPnigT')
                    tD = timeDate.find('span').get_text().strip()
                    self.logger.info(f'{title}, 가격: {price}, 일자: {tD}')
                    href = div.find('a', class_='sc-ciodno dTHXiR')['href'].strip()
                    self.logger.info(f'https://m.bunjang.co.kr{href}')
        except Exception as e:
            self.logger.info(e)
        finally:
            browser.quit()

    def shop_quasarzone(self):
        self.logger.info('퀘이사존 >> 지름, 할인정보')
        for page in range(1, 3):
            url = f'https://quasarzone.com/bbs/qb_saleinfo?_method=post&_token=xMC60o6LY2YYczM2TtVVPaxdJFwjXyguvs7mxwxc&category=PC%2F%ED%95%98%EB%93%9C%EC%9B%A8%EC%96%B4&kind=subject&sort=num%2C%20reply&direction=DESC&page={page}'
            res = requests.get(url, headers=self.headers)
            res.raise_for_status()
            soup = BeautifulSoup(res.text, 'lxml')
            trs = soup.find('div', class_='market-type-list market-info-type-list relative').find('tbody').find_all('tr')
            for tr in trs:
                div = tr.find('div', class_='market-info-list')
                title = div.find('span', class_='ellipsis-with-reply-cnt').get_text().strip()
                lower = title.lower()
                toPrint = False
                if '3070' in lower: # and ('아수스' in lower or 'asus' in lower):
                    toPrint = True
                if 'p31' in lower:
                    toPrint = True
                if '삼성' in lower and ('ddr' in lower or '램' in lower or 'ram' in lower):
                    toPrint = True
                if ('에너맥스' in lower or 'liqmax' in lower) and '360' in lower:
                    toPrint = True
                if toPrint:
                    price = div.find('span', class_='text-orange').get_text().strip()
                    date = div.find('span', class_='date').get_text().strip()
                    self.logger.info(f'{title}, {price}, {date}')
                    # href = div.find('a')['href'].strip()
                    # self.logger.info(f'https://quasarzone.com/{href}')

    def shop_coolenjoy(self):
        self.logger.info('쿨앤조이 >> 지름, 알뜰정보')
        for page in range(1, 3):
            url = f'https://coolenjoy.net/bbs/jirum/p{page}?sca=PC%EA%B4%80%EB%A0%A8'
            res = requests.get(url, headers=self.headers)
            res.raise_for_status()
            soup = BeautifulSoup(res.text, 'lxml')
            trs = soup.find('div', class_='tbl_head01 tbl_wrap').find('tbody').find_all('tr')
            for tr in trs:
                a = tr.find('a')
                title = a.get_text().strip()
                lower = title.lower()
                toPrint = False
                if '3070' in lower: # and ('아수스' in lower or 'asus' in lower):
                    toPrint = True
                if 'p31' in lower:
                    toPrint = True
                if '삼성' in lower and ('ddr' in lower or '램' in lower or 'ram' in lower):
                    toPrint = True
                if ('에너맥스' in lower or 'liqmax' in lower) and '360' in lower:
                    toPrint = True
                if toPrint:
                    date = tr.find('td', class_='td_date').get_text().strip()
                    self.logger.info(f'{title}, {date}')
                    # href = a['href'].strip()
                    # self.logger.info(href)

    def shop_enury(self):
        self.logger.info('에누리')
        delay = 3 # 3초
        browser = self.create_chrome_browser()
        url = 'http://www.enuri.com/Index.jsp'
        browser.get(url)
        browser.implicitly_wait(delay)
        main_window = browser.current_window_handle

        self.logger.info('하이닉스 P31 1TB')   # 하이닉스 P31
        elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
        self.input_text_enter(browser, elem, '하이닉스 p31')
        browser.find_element_by_link_text('SK하이닉스 GOLD P31 M.2 NVMe').click()
        for window in browser.window_handles:
            if window != main_window:
                browser.close()
                browser.switch_to.window(window)
                break
        elem = browser.find_element_by_xpath('//*[@id="prod_option_top"]/div/ul/li[1]/label').click()
        # wait_time = 5
        # wait_variable = WebDriverWait(browser, wait_time)
        # wait_variable.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#special_price'))).click()
        # title = browser.find_element_by_xpath('//*[@id="prod_summary_top"]/div[1]/h1').text.lower().strip()
        while True:
            title = browser.find_element_by_xpath('//*[@id="prod_summary_top"]/div[1]/h1').text.lower().strip()
            if '500' in title:
                time.sleep(1)
            else:
                break
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find('div', id='special_price')
        ul = div.find('ul', class_='s_price__list')
        lis = ul.find_all('li')
        for li in lis:
            img = li.find('img')
            title = img['alt'].strip()
            price = li.find('span', class_='tx_price').get_text().strip()
            delivery = li.find('span', class_='delivery').get_text().strip()
            self.logger.info(f'판매처: {title}, 가격: {price}, 배송비: {delivery}')
            # href = li.find('a')['href'].strip()
            # self.logger.info(f'http://www.enuri.com{href}')

        self.logger.info('삼성 램 16GB')   # 삼성 램
        main_window = browser.current_window_handle
        elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
        self.input_text_enter(browser, elem, '삼성 ddr4 16g')
        browser.find_element_by_link_text('삼성전자 DDR4 PC4-25600').click()
        for window in browser.window_handles:
            if window != main_window:
                browser.close()
                browser.switch_to.window(window)
                break
        elem = browser.find_element_by_xpath('//*[@id="prod_option_top"]/div/ul/li[2]/label').click()
        while True:
            title = browser.find_element_by_xpath('//*[@id="prod_summary_top"]/div[1]/h1').text.lower().strip()
            if '16g' in title:
                break
            else:
                time.sleep(1)
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find('div', id='special_price')
        ul = div.find('ul', class_='s_price__list')
        lis = ul.find_all('li')
        for li in lis:
            img = li.find('img')
            title = img['alt'].strip()
            price = li.find('span', class_='tx_price').get_text().strip()
            delivery = li.find('span', class_='delivery').get_text().strip()
            self.logger.info(f'판매처: {title}, 가격: {price}, 배송비: {delivery}')
            # href = li.find('a')['href'].strip()
            # self.logger.info(f'http://www.enuri.com{href}')

        self.logger.info('에너맥스 Liqmax III 360 블랙')   # 에너맥스
        main_window = browser.current_window_handle
        elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
        self.input_text_enter(browser, elem, 'liqmax 360 블랙')
        browser.find_element_by_link_text('에너맥스 LIQMAX III ARGB 360').click()
        for window in browser.window_handles:
            if window != main_window:
                browser.close()
                browser.switch_to.window(window)
                break
        elem = browser.find_element_by_xpath('//*[@id="prod_option_top"]/div/ul/li[1]/label').click()
        while True:
            title = browser.find_element_by_xpath('//*[@id="prod_summary_top"]/div[1]/h1').text.lower().strip()
            if '블랙' in title:
                break
            else:
                time.sleep(1)
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find('div', id='special_price')
        ul = div.find('ul', class_='s_price__list')
        lis = ul.find_all('li')
        for li in lis:
            img = li.find('img')
            title = img['alt'].strip()
            price = li.find('span', class_='tx_price').get_text().strip()
            delivery = li.find('span', class_='delivery').get_text().strip()
            self.logger.info(f'판매처: {title}, 가격: {price}, 배송비: {delivery}')
            # href = li.find('a')['href'].strip()
            # self.logger.info(f'http://www.enuri.com{href}')

        self.logger.info('RTX 3070 TI')   # 3070 ti
        elem = browser.find_element_by_xpath('//*[@id="search_keyword"]')
        self.input_text_enter(browser, elem, 'rtx 3070')
        elem = browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[4]/div[1]/ul/li[1]/div/div[2]/div[1]/div[1]/a')
        browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[3]/div[2]/ul/li[2]').click()
        while True:
            newElem = browser.find_element_by_xpath('//*[@id="listBodyDiv"]/div[2]/div[1]/div[4]/div[1]/ul/li[1]/div/div[2]/div[1]/div[1]/a')
            if elem == newElem:
                time.sleep(1)
            else:
                break
        soup = BeautifulSoup(browser.page_source, 'lxml')
        ul = soup.find('ul', class_='goods-bundle')
        lis = ul.find_all('li')
        for li in lis:
            div = li.find('div', class_='item__model')
            if div:
                a = div.find('a')
                title = a.get_text().strip()
                if '오디세이' in title:
                    continue
                price = li.find('span', class_='tx--price').get_text().strip()
                store = li.find('div', class_='opt--count').get_text().strip()
                self.logger.info(f'{title}, 가격: {price} ({store})')
                # href = a['href'].strip()
                # self.logger.info(f'http://www.enuri.com{href}')

    def shop_danawa(self):
        self.logger.info('다나와')
        delay = 3 # 3초
        browser = self.create_chrome_browser()
        url = 'http://www.danawa.com/'
        browser.get(url)
        browser.implicitly_wait(delay)

        self.logger.info('하이닉스 P31 1TB')   # 하이닉스 P31
        url = 'http://prod.danawa.com/list/?cate=112760'
        browser.get(url)
        browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
        browser.find_element_by_xpath('//*[@id="searchMakerRep4131"]').click()
        browser.find_element_by_xpath('//*[@id="searchAttributeValueRep202347"]').click()
        browser.find_element_by_xpath('//*[@id="searchAttributeValueRep610817"]').click()
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find('div', class_='main_prodlist main_prodlist_list')
        lis = div.find_all('li', class_='prod_item prod_layer')
        for li in lis:
            div = li.find('div', class_='prod_info')
            a = div.find('a')
            title = a.get_text().strip()
            if 'SK하이닉스 Gold P31 M.2 NVMe' in title:
                url = a['href'].strip()
                break
        browser.get(url)
        browser.implicitly_wait(delay)
        browser.find_element_by_xpath('//*[@id="priceCompareArea"]/div[3]/ul/li[1]/div/div[1]/a/span[2]').click()
        browser.find_element_by_xpath('//*[@id="blog_content"]/div[2]/div[2]/div[1]/div[2]/div[1]/div[1]/span[2]/a/em')
        soup = BeautifulSoup(browser.page_source, 'lxml')
        cardDiv = soup.find('div', class_='row lowest_price')
        a = cardDiv.find('a', class_='lwst_prc')
        cardPrice = a.get_text().strip()
        cardHref = a['href']
        cashDiv = soup.find('div', id='lowPriceCash')
        a = cashDiv.find('a', class_='lwst_prc')
        cashPrice = a.get_text().strip()
        cashHref = a['href']
        self.logger.info(f'현찰가: {cashPrice}')
        # self.logger.info(cashHref)
        self.logger.info(f'카드가: {cardPrice}')
        # self.logger.info(cardHref)

        self.logger.info('삼성 램 16GB')   # 삼성 램
        url = 'http://prod.danawa.com/list/?cate=1131326'
        browser.get(url)
        browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
        browser.find_element_by_xpath('//*[@id="searchMakerRep702"]').click()
        browser.find_element_by_xpath('//*[@id="searchAttributeValueRep90210"]').click()
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find('div', class_='main_prodlist main_prodlist_list')
        lis = div.find_all('li', class_='prod_item prod_layer')
        for li in lis:
            div = li.find('div', class_='prod_info')
            a = div.find('a')
            title = a.get_text().strip()
            if '삼성전자 DDR4-3200' in title:
                url = a['href'].strip()
                break
        browser.get(url)
        browser.implicitly_wait(delay)
        browser.find_element_by_xpath('//*[@id="priceCompareArea"]/div[3]/ul/li[2]/div/div[1]/a').click()
        browser.find_element_by_xpath('//*[@id="blog_content"]/div[2]/div[2]/div[1]/div[2]/div[1]/div[1]')
        soup = BeautifulSoup(browser.page_source, 'lxml')
        cardDiv = soup.find('div', class_='row lowest_price')
        a = cardDiv.find('a', class_='lwst_prc')
        cardPrice = a.get_text().strip()
        cardHref = a['href']
        cashDiv = soup.find('div', id='lowPriceCash')
        a = cashDiv.find('a', class_='lwst_prc')
        cashPrice = a.get_text().strip()
        cashHref = a['href']
        self.logger.info(f'현찰가: {cashPrice}')
        # self.logger.info(cashHref)
        self.logger.info(f'카드가: {cardPrice}')
        # self.logger.info(cardHref)

        self.logger.info('에너맥스 Liqmax III 360 블랙')   # 에너맥스
        url = 'http://prod.danawa.com/list/?cate=11336856'
        browser.get(url)
        browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
        browser.find_element_by_xpath('//*[@id="searchMakerRep3851"]').click()
        browser.find_element_by_xpath('//*[@id="searchAttributeValue198102"]').click()
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find('div', class_='main_prodlist main_prodlist_list')
        lis = div.find_all('li', class_='prod_item prod_layer')
        for li in lis:
            div = li.find('div', class_='prod_info')
            a = div.find('a')
            title = a.get_text().strip()
            if '에너맥스 LIQMAX III ARGB 360' in title:
                url = a['href'].strip()
                break
        browser.get(url)
        browser.implicitly_wait(delay)
        browser.find_element_by_xpath('//*[@id="priceCompareArea"]/div[3]/ul/li[1]/div/div[1]/a').click()
        browser.find_element_by_xpath('//*[@id="blog_content"]/div[2]/div[2]/div[1]/div[2]/div[1]')
        soup = BeautifulSoup(browser.page_source, 'lxml')
        cardDiv = soup.find('div', class_='row lowest_price')
        a = cardDiv.find('a', class_='lwst_prc')
        cardPrice = a.get_text().strip()
        cardHref = a['href']
        cashDiv = soup.find('div', id='lowPriceCash')
        a = cashDiv.find('a', class_='lwst_prc')
        cashPrice = a.get_text().strip()
        cashHref = a['href']
        self.logger.info(f'현찰가: {cashPrice}')
        # self.logger.info(cashHref)
        self.logger.info(f'카드가: {cardPrice}')
        # self.logger.info(cardHref)

        self.logger.info('RTX 3070 TI')   # 3070 ti
        url = 'http://prod.danawa.com/list/?cate=1131480'
        browser.get(url)
        browser.find_element_by_xpath('//*[@id="productListArea"]/div[2]/div[1]/ul/li[3]/a').click()
        time.sleep(2)
        browser.find_element_by_xpath('//*[@id="searchAttributeValueRep733033"]').click()
        time.sleep(2)
        browser.find_element_by_xpath('//*[@id="searchAttributeValueRep705343"]').click()
        time.sleep(2)
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find('div', class_='main_prodlist main_prodlist_list')
        lis = div.find_all('li', class_='prod_item prod_layer width_change')
        for li in lis:
            div = li.find('div', class_='prod_info')
            a = div.find('a')
            href = a['href']
            title = a.get_text().strip()
            div = li.find('div', class_='prod_pricelist')
            a = div.find('a')
            price = a.get_text().strip()
            self.logger.info(f'{title}, 가격: {price}')
            # self.logger.info(href)

    def shop_joongonara(self):
        self.logger.info('중고 나라')
        delay = 3 # 3초
        browser = self.create_chrome_browser()
        url = 'https://cafe.naver.com/joonggonara'
        browser.get(url)
        browser.implicitly_wait(delay)

        self.logger.info('하이닉스 P31 1TB')   # 하이닉스 P31
        browser.find_element_by_xpath('//*[@id="menuLink386"]').click()
        browser.switch_to.frame('cafe_main')
        elem = browser.find_element_by_xpath('//*[@id="query"]')
        self.input_text_enter(browser, elem, '하이닉스 p31')
        elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find_all('div', class_='article-board m-tcol-c')[1]
        trs = div.find_all('tr')
        for tr in trs:
            td = tr.find('td', class_='td_article')
            if td:
                a = td.find('a', class_='article')
                title = a.get_text().strip()
                if '500' in title:
                    continue
                date = tr.find('td', class_='td_date').get_text().strip()
                self.logger.info(f'{title}, 일자: {date}')
                # href = a['href']
                # self.logger.info(f'https://cafe.naver.com{href}')
        browser.switch_to.default_content()

        self.logger.info('삼성 램 16GB')   # 삼성 램
        browser.find_element_by_xpath('//*[@id="menuLink385"]').click()
        browser.switch_to.frame('cafe_main')
        elem = browser.find_element_by_xpath('//*[@id="query"]')
        self.input_text_enter(browser, elem, '삼성 16g')
        elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find_all('div', class_='article-board m-tcol-c')[1]
        trs = div.find_all('tr')
        for tr in trs:
            td = tr.find('td', class_='td_article')
            if td:
                a = td.find('a', class_='article')
                title = a.get_text().strip()
                lower = title.lower()
                if '8g' in lower or 'ddr3' in lower or '213' in lower or '2666' in lower:
                    continue
                date = tr.find('td', class_='td_date').get_text().strip()
                self.logger.info(f'{title}, 일자: {date}')
                # href = a['href']
                # self.logger.info(f'https://cafe.naver.com{href}')
        browser.switch_to.default_content()

        self.logger.info('에너맥스 Liqmax III 360 블랙')   # 에너맥스
        browser.find_element_by_xpath('//*[@id="menuLink393"]').click()
        browser.switch_to.frame('cafe_main')
        elem = browser.find_element_by_xpath('//*[@id="query"]')
        self.input_text_enter(browser, elem, 'liqmax')
        elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find_all('div', class_='article-board m-tcol-c')[1]
        trs = div.find_all('tr')
        for tr in trs:
            td = tr.find('td', class_='td_article')
            if td:
                a = td.find('a', class_='article')
                title = a.get_text().strip()
                lower = title.lower()
                if '240' in lower:
                    continue
                date = tr.find('td', class_='td_date').get_text().strip()
                self.logger.info(f'{title}, 일자: {date}')
                # href = a['href']
                # self.logger.info(f'https://cafe.naver.com{href}')
        browser.switch_to.default_content()

        self.logger.info('RTX 3070 TI')   # 3070 ti
        browser.find_element_by_xpath('//*[@id="menuLink385"]').click()
        browser.switch_to.frame('cafe_main')
        elem = browser.find_element_by_xpath('//*[@id="query"]')
        self.input_text_enter(browser, elem, '3070')
        elem = browser.find_element_by_xpath('//*[@id="main-area"]/div[5]')
        soup = BeautifulSoup(browser.page_source, 'lxml')
        div = soup.find_all('div', class_='article-board m-tcol-c')[1]
        trs = div.find_all('tr')
        for tr in trs:
            td = tr.find('td', class_='td_article')
            if td:
                a = td.find('a', class_='article')
                title = a.get_text().strip()
                lower = title.lower()
                # if '240' in lower:
                #     continue
                date = tr.find('td', class_='td_date').get_text().strip()
                self.logger.info(f'{title}, 일자: {date}')
                # href = a['href']
                # self.logger.info(f'https://cafe.naver.com{href}')
        browser.switch_to.default_content()

    # Chrome 사용
    def delete_dirty_window (self, browser):
        current_window = browser.current_window_handle
        for window in browser.window_handles:
            if window != current_window:
                browser.switch_to.window(window)
                browser.close()
                browser.switch_to.window(current_window)

    def create_chrome_browser (self, headless = False):
        options = Options()
        options.add_experimental_option('prefs', {
            'profile.default_content_settings.popups' : 0,
            'download.default_directory' : r'C:\T'
            })
        if headless:
            options.add_argument('headless')
            options.add_argument('window-size=1920x1080')
            options.add_argument("disable-gpu") # 혹은 options.add_argument("--disable-gpu")
            options.add_argument('user-agent=Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36')
            options.add_argument('lang=ko_KR')

        browser = webdriver.Chrome(executable_path=r'C:\App\Prog\miniconda3\envs\Stock\Scripts\chromedriver.exe', options=options)
        # self.delete_dirty_window(browser)
        return browser

    def input_text (self, browser, elem, input):
        pyperclip.copy(input)
        elem.click()
        time.sleep(1)
        #     elem.clear()
        #     time.sleep(1)
        webdriver.ActionChains(browser).key_down(Keys.CONTROL).send_keys('v').key_up(Keys.CONTROL).perform()
        time.sleep(1)

    def input_text_enter (self, browser, elem, input):
        self.input_text(browser, elem, input)
        elem.send_keys(Keys.ENTER)

    def copy_login(self, browser, path, input):
        pyperclip.copy(input)
        elem = browser.find_element_by_id(path)
        elem.click()
        # time.sleep(1)
        # elem.clear()
        time.sleep(1)
        webdriver.ActionChains(browser).key_down(Keys.CONTROL).send_keys('v').key_up(Keys.CONTROL).perform()
        time.sleep(1)

    def login_naver(self, browser):
        time.sleep(2)
        elem = browser.find_element_by_class_name('link_login')
        elem.click()

        time.sleep(2)
        self.copy_login(browser, 'id', 'rtos9er')
        password = 'Icando9!'
        # with open('Login.txt', 'r') as f:
        #     password = f.read();
        # password = password[0:8]
        self.copy_login(browser, 'pw', password)

        browser.find_element_by_id('log.login').click()


if __name__ == '__main__':
    Shopping()
