from flask import Flask
from config import Config
from flask_login import LoginManager
from flask_mysqldb import MySQL
from flask_migrate import Migrate


app = Flask(__name__)
app.config.from_object(Config)
mysql = MySQL(app)

from app import routes


