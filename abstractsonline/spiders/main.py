# -*- coding: utf-8 -*-
import scrapy
from scrapy_splash import SplashRequest
from scrapy.utils.response import open_in_browser
from PIL import Image
import io
import os
from scrapy.selector import Selector
from abstractsonline.items import ParticipantItemLoader, PresentationItemLoader


class MainSpider(scrapy.Spider):
    name = 'main'
    allowed_domains = ['abstractsonline.com']
    dir = os.path.dirname(os.path.abspath(__file__))
    jl_out_file = dir + '\\..\\..\\out.jl'
    csv_out_file = dir + '\\..\\..\\out_nested.csv'

    start_urls = ['https://www.abstractsonline.com/pp8/#!/6812/participants/@timeSlot=Mar31/166']
    # start_urls = ['https://www.abstractsonline.com/pp8/#!/6812/participants/@timeSlot=Mar29/1']
    # start_urls = ['https://www.abstractsonline.com/pp8/#!/6812/']

    page_counter = 0
    max_pages = 10000
    has_next = True

    with open(dir + '\\get_page.lua', 'r') as file:
        lua_script = file.read()

    def start_requests(self):
        for url in self.start_urls:
            # yield SplashRequest(url=url, callback=self.show_screenshot, endpoint='render.png', args={'wait': 6})

            yield SplashRequest(url=url, callback=self.parse, endpoint='execute', args={
                'lua_source': self.lua_script,
                'timeout': 90
            })

    def parse(self, response):
        for item in response.css('#results li.result'):
            ld = ParticipantItemLoader(selector=item)
            ld.add_css('name', 'h4.name span.bodyTitle::text')
            ld.add_css('location', 'span.location::text')
            ld.add_value('presentations', self.parse_presentations(item))
            yield ld.load_item()

        self.page_counter += 1
        self.has_next = response.data['has_next']

        if self.page_counter < self.max_pages and self.has_next:
            # replace page number in url
            list_url = response.url.split('/')
            current_page = int(list_url[-1]) if list_url[-1].isdigit() else 1
            next_url = '/'.join(list_url[:-1] + [str(current_page + 1)])

            yield SplashRequest(url=next_url, callback=self.parse,
                                endpoint='execute', args={
                    'lua_source': self.lua_script,
                    'timeout': 90
                })

    def parse_presentations(self, item):
        presentations = []
        for presentation in item.css('table.table tr'):
            ld = PresentationItemLoader(selector=presentation)
            ld.add_xpath('code', './td[1]/text()')
            ld.add_xpath('short_description', './td[2]/text()')
            ld.add_xpath('date', './td[3]/*/text()')
            presentations.append(dict(ld.load_item()))

        return presentations

    def show_screenshot(self, response):
        # self.logger.info(response.data.cookies)
        image = Image.open(io.BytesIO(response.body))
        image.show()
