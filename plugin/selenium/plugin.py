# -*- coding: utf-8 -*-

# built-in # https://docs.python.org/ko/3/
import os
import logging
import traceback
from logging.handlers import RotatingFileHandler

# third-party
from flask import Blueprint, request, Response, render_template, redirect, jsonify
from flask_login import login_required

# sjva common
from framework.logger import get_logger
from framework import path_data, app, db, scheduler
from framework.util import Util

# package
package_name = __name__.split('.')[0]
logger = get_logger(package_name)

from .logic import Logic
from .model import ModelSetting

blueprint = Blueprint(package_name, package_name, url_prefix='/%s' % package_name, template_folder=os.path.join(os.path.dirname(__file__), 'templates'))

# menu conf
menu = {
    'main': [package_name, 'Selenium'],
    'sub': [
        ['setting', '설정'], ['log', '로그']
    ],
    'category': 'custom',
}

plugin_info = {
    "name": "selenium",
    "category_name": "custom",
    "version": "0.0.0.0",
    "developer": "ssokka",
    "description": "Selenium Auto Clicker",
    "home": "https://github.com/ssokka/SJVA/tree/master/selenium",
    "more": "",
}

def plugin_load():
    Logic.plugin_load()

def plugin_unload():
    Logic.plugin_unload()
