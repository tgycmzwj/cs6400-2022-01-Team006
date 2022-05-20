import os
class Config(object):
    SECRET_KEY=os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    #SQLALCHEMY_DATABASE_URI='sqlite:///gameswap.db'
    #SQLALCHEMY_DATABASE_URI='mysql+pymysql://root:1995812zwj@localhost/gameswapDB'
    #SQLALCHEMY_TRACK_MODIFICATIONS=False
    MYSQL_HOST='localhost'
    MYSQL_USER='root'
    MYSQL_PASSWORD='1995812zwj'
    MYSQL_DB='gameswapDB'
