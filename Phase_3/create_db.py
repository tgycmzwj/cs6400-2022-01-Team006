import mysql.connector

mydb=mysql.connector.connect(
    host='127.0.0.1',
    port=3306,
    user='root',
    passwd='zxcECHO123*!'
)

my_cursor=mydb.cursor()
my_cursor.execute('''USE gameswapDB;''')
my_cursor.execute('SELECT * FROM User;')

print('finished')