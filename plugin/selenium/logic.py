# -*- coding: utf-8 -*-

# built-in modules: https://docs.python.org/
import os
import traceback

# third-party modules


# sjva common
from framework import db
from framework.util import Util

# package
from .plugin import logger, package_name
from .model import ModelSetting

class Logic(object):
    # db_default = Conf.read()
    # if not db_default:
    db_default = {
        'remote': 'True',
        'driver': 'True'
    }

    @staticmethod
    def db_init():
        try:
            for key, value in Logic.db_default.items():
                if db.session.query(ModelSetting).filter_by(key=key).count() == 0:
                    db.session.add(ModelSetting(key, value))
            db.session.commit()
        except Exception as e:
            logger.error('Exception: %s' % e)
            logger.error(traceback.format_exc())

    @staticmethod
    def plugin_load():
        try:
            # DB 초기화
            Logic.db_init()

            # 편의를 위해 json 파일 생성
            from plugin import plugin_info
            Util.save_from_dict_to_json(plugin_info, os.path.join(os.path.dirname(__file__), 'info.json'))

        except Exception as e:
            logger.error('Exception: %s' % e)
            logger.error(traceback.format_exc())

    @staticmethod
    def plugin_unload():
        try:
            logger.debug('%s plugin_unload' % package_name)
        except Exception as e:
            logger.error('Exception: %s' % e)
            logger.error(traceback.format_exc())

    @staticmethod
    def setting_save(req):
        try:
            for key, value in req.form.items():
                logger.debug('Key: %s Value: %s' % (key, value))
                entity = db.session.query(ModelSetting).filter_by(key=key).with_for_update().first()
                entity.value = value
            db.session.commit()
            return True
        except Exception as e:
            logger.error('Exception: %s' % e)
            logger.error(traceback.format_exc())
            return False
