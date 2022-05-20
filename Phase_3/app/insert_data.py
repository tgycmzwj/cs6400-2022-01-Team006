import numpy as np
import pandas as pd
import mysql.connector
from app.queries import create_table,insert_postalcode,insert_videoplatform,register_insert_user,register_insert_phone,insert_item,insert_board,insert_card,insert_video,insert_jigsaw,insert_computer,insert_swap,accept_or_reject,assign_rating_to_record,insert_function


print('start')
mydb=mysql.connector.connect(
    host='127.0.0.1',
    port=3306,
    user='root',
    passwd='1995812zwj'
)
cursor=mydb.cursor(buffered=True)
create_table(cursor)
cursor.close()



conn = mysql.connector.connect(user='root', password='1995812zwj', database='gameswapDB')
cursor=conn.cursor(buffered=True)
cursor.execute('''SHOW TABLES;''')
all_tables=cursor.fetchall()

#read data from tsv files
data_postal=pd.read_csv('../data/postal_codes.csv',dtype=str)
data_users=pd.read_csv('../data/users.tsv',sep='\t',dtype=str)
data_items=pd.read_csv('../data/items.tsv',sep='\t',dtype=str)
data_swaps=pd.read_csv('../data/swaps.tsv',sep='\t',dtype=str)
data_videoplatforms=['Nintendo','PlayStation','Xbox']

#initlize data for postal code
print('insert data for postal code')
def init_postal(cursor,data_postal):
    for i in range(len(data_postal)):
        zip,city,state,latitude,longitude=data_postal.loc[i]
        insert_postalcode(cursor,zip,city,state,float(latitude),float(longitude))
init_postal(cursor,data_postal)
conn.commit()

#initialize data for users
print('insert data for users')
def init_users_phones(cursor,data_users):
    for i in range(len(data_users)):
        email,password,firstname,lastname,nickname,postalcode,phonenumber,phonetype,sharephone=data_users.loc[i]
        #for users
        r1=register_insert_user(cursor,email,postalcode,password,firstname,lastname,nickname)
        if pd.isna(phonenumber)==False:
            #for phones
            r2=register_insert_phone(cursor,phonenumber,email,phonetype,sharephone)
init_users_phones(cursor,data_users)
conn.commit()

#initialize data for video platform
print('insert data for video platform')
def init_videoplatforms(cursor,data_videoplatforms):
    for i in range(0,len(data_videoplatforms)):
        insert_videoplatform(cursor,data_videoplatforms[i])
init_videoplatforms(cursor,data_videoplatforms)
conn.commit()


#initialize data for items
print('insert data for items')
def init_items(cursor,data_items):
    for i in range(0,len(data_items)):
        itemid,title,game_condition,description,email,gametype,piececount,platform,media=data_items.loc[i]
        title=title.replace('"','')
        if pd.isna(description)==False:
            description=description.replace('"','')
        else:
            description=''
        insert_id=insert_item(cursor,email,title,description,game_condition)
        if gametype=='Board Game':
            insert_board(cursor,int(insert_id))
        elif gametype=='Card Game':
            insert_card(cursor,int(insert_id))
        elif gametype=='Jigsaw Puzzle':
            insert_jigsaw(cursor,int(insert_id),int(piececount))
        elif gametype=='Video Game':
            insert_video(cursor,int(insert_id),platform,media)
        elif gametype=='Computer Game':
            insert_computer(cursor,int(insert_id),platform)
init_items(cursor,data_items)
conn.commit()


#initialize data for swap records
print('insert data for swap records')
def init_swap(cur,data_swaps):
    for i in range(0,len(data_swaps)):
        item_proposed,item_desired,date_proposed,date_reviewed,accepted,proposer_rate,counterparty_rate=data_swaps.loc[i]
        if pd.isna(date_proposed):
            date_proposed='NULL'
        if pd.isna(date_reviewed):
            date_reviewed='NULL'
        if pd.isna(accepted):
            accepted='NULL'
        if pd.isna(proposer_rate):
            proposer_rate='NULL'
        if pd.isna(counterparty_rate):
            counterparty_rate='NULL'
        query1='''INSERT INTO SwapRecord (proposedItemID,desiredItemID,status,propose_date,decide_date,proposer_rate,counterparty_rate) VALUES ({},{},{},"{}",{},{},{});'''
        query2='''INSERT INTO SwapRecord (proposedItemID,desiredItemID,status,propose_date,decide_date,proposer_rate,counterparty_rate) VALUES ({},{},{},"{}","{}",{},{});'''
        query=query1 if date_reviewed=='NULL' else query2
        cursor.execute(query.format(int(item_proposed),int(item_desired),accepted,date_proposed,date_reviewed,proposer_rate,counterparty_rate))
init_swap(cursor,data_swaps)
conn.commit()


#### initialize the cal_dist function
#insert_function(cursor)


print('finished')