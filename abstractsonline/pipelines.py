# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.htm

from prikid_scraping_tools import jl2csv


class NestedCSVPipeline(object):
    # data = []

    def process_item(self, item, spider):
        # self.data.append(dict(item))
        return item

    def close_spider(self, spider):
        # Nested2CSV(self.data).to_csv('out1.csv')
        try:
            jl2csv(spider.jl_out_file, spider.csv_out_file)
        except FileNotFoundError:
            spider.logger.error('File not found for converting jl to csv')
