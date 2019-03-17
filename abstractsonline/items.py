# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy.loader.processors import Identity, TakeFirst
from scrapy.loader import ItemLoader


class PresentationItem(scrapy.Item):
    code = scrapy.Field()
    short_description = scrapy.Field()
    date = scrapy.Field()


class PresentationItemLoader(ItemLoader):
    default_item_class = PresentationItem
    default_output_processor = TakeFirst()


class ParticipantItem(scrapy.Item):
    name = scrapy.Field()
    location = scrapy.Field()
    presentations = scrapy.Field(output_processor=Identity())


class ParticipantItemLoader(ItemLoader):
    default_item_class = ParticipantItem
    default_output_processor = TakeFirst()
