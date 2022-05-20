from datetime import datetime

#### create tables
def create_table(cursor):
    query = '''DROP DATABASE IF EXISTS gameswapDB;
CREATE DATABASE IF NOT EXISTS gameswapDB;
USE gameswapDB;
-- SHOW VARIABLES LIKE "secure_file_priv";
-- location table
CREATE TABLE IF NOT EXISTS Location(
    postalCode CHAR(5) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    PRIMARY KEY (postalCode)
);
-- user table
CREATE TABLE IF NOT EXISTS User(
    email VARCHAR(50) NOT NULL,
    postalCode CHAR(5) NOT NULL,
    password VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    nick_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (email),
    FOREIGN KEY (postalCode) REFERENCES Location(postalCode)
);
-- phone table
CREATE TABLE IF NOT EXISTS Phone(
    phoneNumber CHAR(10) NOT NULL,
    ownerEmail VARCHAR(50) NOT NULL,
    phone_type VARCHAR(10) NOT NULL,
    share_phone BOOLEAN NOT NULL,
    PRIMARY KEY (phoneNumber),
    FOREIGN KEY (ownerEmail) REFERENCES User(email)
);
-- item table
CREATE TABLE IF NOT EXISTS Item(
    itemID INT NOT NULL AUTO_INCREMENT,
    ownerEmail VARCHAR(50) NOT NULL,
    title VARCHAR(500) NOT NULL,
    -- game_type VARCHAR(20) NOT NULL,
    description VARCHAR(2000),
    game_condition VARCHAR(30) NOT NULL,
    PRIMARY KEY (itemID),
    FOREIGN KEY (ownerEmail) REFERENCES User(email)
);
-- board game table
CREATE TABLE IF NOT EXISTS BoardGame(
    itemID INT NOT NULL,
    PRIMARY KEY (itemID),
    FOREIGN KEY (itemID) REFERENCES Item(itemID)
);
-- card game table
CREATE TABLE IF NOT EXISTS CardGame(
    itemID INT NOT NULL,
    PRIMARY KEY (itemID),
    FOREIGN KEY (itemID) REFERENCES Item(itemID)
);
-- video platform table
CREATE TABLE IF NOT EXISTS VideoPlatform(
    platformID INT NOT NULL AUTO_INCREMENT,
    platform_name VARCHAR(20) NOT NULL,
    PRIMARY KEY (platformID)
);
-- video game table
CREATE TABLE IF NOT EXISTS VideoGame(
    itemID INT NOT NULL,
    platformID INT NOT NULL,
    media VARCHAR(20) NOT NULL,
    PRIMARY KEY (itemID),
    FOREIGN KEY (itemID) REFERENCES Item(itemID),
    FOREIGN KEY (platformID) REFERENCES VideoPlatform(platformID)
);
-- computer game table
CREATE TABLE IF NOT EXISTS ComputerGame(
    itemID INT NOT NULL,
    computer_platform VARCHAR(20) NOT NULL,
    PRIMARY KEY (itemID),
    FOREIGN KEY (itemID) REFERENCES Item(itemID)
);
-- jigsaw puzzle table
CREATE TABLE IF NOT EXISTS JigsawPuzzle(
    itemID INT NOT NULL,
    piece_count INT NOT NULL,
    PRIMARY KEY (itemID),
    FOREIGN KEY (itemID) REFERENCES Item(itemID)
);
-- swap record table
CREATE TABLE IF NOT EXISTS SwapRecord(
    recordID INT NOT NULL AUTO_INCREMENT,
    -- proposerEmail VARCHAR(50) NOT NULL,
    -- counterpartyEmail VARCHAR(50) NOT NULL,
    proposedItemID INT NOT NULL,
    desiredItemID INT NOT NULL,
    status INT NULL,
    propose_date DATE NOT NULL,
    decide_date DATE,
    proposer_rate FLOAT,
    counterparty_rate FLOAT,
    PRIMARY KEY (recordID, proposedItemID, desiredItemID),
    -- FOREIGN KEY (proposerEmail) REFERENCES User(email),
    -- FOREIGN KEY (counterpartyEmail) REFERENCES User(email),
    FOREIGN KEY (proposedItemID) REFERENCES Item(itemID),
    FOREIGN KEY (desiredItemID) REFERENCES Item(itemID)
);'''
    cursor.execute(query)


#### insert postalcode
def insert_postalcode(cursor, postalcode, city, state, latitude, longitude):
    query = '''INSERT INTO gameswapDB.Location(postalCode,city,state,latitude,longitude)
     VALUES("{}","{}","{}",{},{})'''
    cursor.execute(query.format(postalcode, city, state, latitude, longitude))


#### insert video platform
def insert_videoplatform(cursor, platform_name):
    query = '''INSERT INTO gameswapDB.VideoPlatform(platform_name) VALUES("{}")'''
    cursor.execute(query.format(platform_name))


#### function
def insert_function(cursor):
    query = '''USE gameswapDB;

DROP FUNCTION IF EXISTS cal_dist;
DELIMITER $$
CREATE FUNCTION cal_dist(
    zip1 CHAR(5),
    zip2 CHAR(5)
) RETURNS float
READS SQL DATA
BEGIN
    DECLARE lat1,lon1,lat2,lon2 FLOAT DEFAULT 0;
	DECLARE delta_lat FLOAT DEFAULT 0;
    DECLARE delta_lon FLOAT DEFAULT 0;
    DECLARE a FLOAT DEFAULT 0;
    DECLARE c FLOAT DEFAULT 0;

    SELECT latitude,longitude
    INTO lat1,lon1
    FROM gameswapDB.Location
    WHERE postalCode=zip1;

    SELECT latitude,longitude
    INTO lat2,lon2
    FROM gameswapDB.Location
    WHERE postalCode=zip2;


    SELECT pi()*lat1/180-pi()*lat2/180 INTO delta_lat;
    SELECT pi()*lon1/180-pi()*lon2/180 INTO delta_lon;
    SELECT power(sin(delta_lat/2),2)+cos(pi()*lat1/180)*cos(pi()*lat2/180)
           *power(sin(delta_lon/2),2) INTO a;
    SELECT 2*atan2(sqrt(a),sqrt(1-a)) INTO c;
    RETURN ROUND(c*6371,1);
END$$
DELIMITER ;
    '''
    cursor.execute(query)


#### login part
#the case when user input a phone number--get email
def login_get_email(cursor,phone):
    query='''SELECT ownerEmail FROM gameswapDB.Phone WHERE Phone.phoneNumber="{}"'''
    cursor.execute(query.format(phone))
    query_result=cursor.fetchone()
    if query_result is not None:
        return query_result[0]
    else:
        return 'ERROR'

#the case when user input an email
def login_input_email(cursor,email):
    query='''SELECT password FROM gameswapDB.User WHERE User.email="{}";'''
    cursor.execute(query.format(email))
    query_result=cursor.fetchone()
    if query_result is not None:
        return query_result[0]
    else:
        return 'ERROR'


#### registration part
# check if the email exists
def register_check_email(cursor,email):
    query_email='''SELECT COUNT(*) FROM gameswapDB.User WHERE User.email="{}";'''
    cursor.execute(query_email.format(email))
    query_email_result=cursor.fetchone()[0]
    return query_email_result
# check if the phone number exists
def register_check_phone(cursor,phone):
    query_phone='''SELECT COUNT(*) FROM gameswapDB.Phone WHERE Phone.phoneNumber="{}";'''
    cursor.execute(query_phone.format(phone))
    query_phone_result=cursor.fetchone()[0]
    return query_phone_result
#check if the postal code is valid
def register_check_postalcode(cursor,postalcode):
    query_postalcode='''SELECT COUNT(*) FROM gameswapDB.Location WHERE Location.postalCode="{}";'''
    cursor.execute(query_postalcode.format(postalcode))
    query_postalcode_result=cursor.fetchone()[0]
    return query_postalcode_result
# check if city and state are correct
def register_check_city(cursor,postalcode):
    query_city='''SELECT city, state FROM gameswapDB.Location WHERE Location.postalCode="{}";'''
    cursor.execute(query_city.format(postalcode))
    query_city_result=cursor.fetchone()
    return query_city_result
# insert this new user to User
def register_insert_user(cursor,email,postalcode,password,firstname,lastname,nickname):
    query_insert_user='''INSERT INTO gameswapDB.User(email,postalCode,password,first_name,last_name,nick_name) 
                         VALUES("{}","{}","{}","{}","{}","{}");'''
    cursor.execute(query_insert_user.format(email,postalcode,password,firstname,lastname,nickname))
    return email
# insert phone infor to Phone
def register_insert_phone(cursor,phonenumber,email,phonetype,sharephone):
    query_insert_phone='''INSERT INTO gameswapDB.Phone(phoneNumber,ownerEmail,phone_type,share_phone)
                          VALUES("{}","{}","{}","{}");'''
    cursor.execute(query_insert_phone.format(phonenumber,email,phonetype,sharephone))
    return phonenumber



### update information part
# check if phonenumber used by someone else
def update_check_phone(cursor,phonenumber,email):
    query_phone='''SELECT COUNT(*) FROM gameswapDB.Phone WHERE Phone.phoneNumber="{}" AND Phone.ownerEmail!="{}";'''
    cursor.execute(query_phone.format(phonenumber,email))
    query_phone_result=cursor.fetchone()[0]
    return query_phone_result
# check if postalcode is valid
def update_check_postalcode(cursor,postalcode):
    return register_check_postalcode(cursor,postalcode)
#check if city, state is correct
def update_check_city(cursor,postalcode):
    return register_check_city(cursor,postalcode)
#update this user to User
def update_user(cursor,email,postalcode,password,firstname,lastname,nickname):
    query_update_user='''UPDATE gameswapDB.User
                         SET postalCode="{}",password="{}",first_name="{}",last_name="{}",nick_name="{}"
                         WHERE email="{}";'''
    cursor.execute(query_update_user.format(postalcode,password,firstname,lastname,nickname,email))
    return email
#update phone to Phone
def update_phone(cursor,phonenumber,email,phonetype,sharephone):
    query_insert_phone='''UPDATE gameswapDB.Phone
                          SET phoneNumber="{}", phone_type="{}", share_phone="{}"
                          WHERE ownerEmail="{}";'''
    cursor.execute(query_insert_phone.format(phonenumber,phonetype,sharephone,email))
    return phonenumber



### main menu part
# welcome information
def menu_welcome(cursor,email):
    query_menu_welcome='''SELECT first_name,last_name FROM gameswapDB.User
                          WHERE User.email="{}";'''
    cursor.execute(query_menu_welcome.format(email))
    query_menu_welcome_result = cursor.fetchone()
    return query_menu_welcome_result
# my rating
def my_rating(cursor,email):
    query_my_rating='''SELECT AVG(rate) FROM(
                           -- when I am the proposer of the swap, select the counterparty_rate
                           SELECT counterparty_rate AS rate
                           FROM gameswapDB.SwapRecord NATURAL JOIN(
                               SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	                           FROM gameswapDB.Item
                           ) AS M1
                           WHERE M1.proposerEmail="{}"
                           UNION ALL
                           -- when I am the counterparty of the swap, select the proposer_rate
	                       SELECT proposer_rate AS rate
                           FROM gameswapDB.SwapRecord
                           NATURAL JOIN(
                               SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	                           FROM gameswapDB.Item
                           ) AS M2
                           WHERE M2.counterpartyEmail="{}") AS M;'''
    cursor.execute(query_my_rating.format(email,email))
    query_my_rating_result=cursor.fetchone()
    return query_my_rating_result[0]
# number of unaccepted swaps
def unaccepted_swaps(cursor,email):
    query_unaccepted_swaps='''SELECT COUNT(*)
                              FROM gameswapDB.SwapRecord NATURAL JOIN (
                                  SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
                                  FROM gameswapDB.Item
                              ) AS M
                              WHERE M.counterpartyEmail="{}" AND SwapRecord.status IS NULL;'''
    cursor.execute(query_unaccepted_swaps.format(email))
    query_unaccepted_swaps_result=cursor.fetchone()
    return query_unaccepted_swaps_result[0]
# any swaps more than five days old
def old_swaps(cursor,email):
    query_old_swaps='''SELECT COUNT(*)
FROM gameswapDB.SwapRecord NATURAL JOIN (
     SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
     FROM gameswapDB.Item
     ) AS M
WHERE M.counterpartyEmail="{}" AND SwapRecord.status IS NULL AND DATEDIFF(CURDATE(),SwapRecord.propose_date)>5;
    '''
    cursor.execute(query_old_swaps.format(email))
    query_old_swaps_result=cursor.fetchone()
    return query_old_swaps_result[0]

#number of unrated swaps
def unrated_swaps(cursor,email):
    query_unrated_swaps='''SELECT COUNT(*)
                           FROM gameswapDB.SwapRecord NATURAL JOIN (
	                           SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	                           FROM gameswapDB.Item
                               )AS M1 NATURAL JOIN (
	                           SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	                           FROM gameswapDB.Item
                               )AS M2
                           WHERE ((proposerEmail="{}" AND proposer_rate IS NULL) OR (counterpartyEmail="{}" AND counterparty_rate IS NULL)) AND (status=1);'''
    cursor.execute(query_unrated_swaps.format(email,email))
    query_unrated_swaps_result=cursor.fetchone()
    return query_unrated_swaps_result[0]



### additional checks
#check whether an item belongs to a user
def check_item_owner(cursor,email,itemid):
    query_check_item_owner='''SELECT COUNT(*) FROM gameswapDB.Item WHERE ownerEmail="{}" AND itemID={};
    '''
    cursor.execute(query_check_item_owner.format(email,itemid))
    return cursor.fetchone()[0]
#check whether an item is available
def check_item_notavail(cursor,itemid):
    query_check_item_notavail='''SELECT COUNT(*) FROM
(SELECT proposedItemID AS ItemID FROM SwapRecord WHERE status = 1 OR status IS NULL
UNION
SELECT desiredItemID AS ItemID FROM SwapRecord WHERE status = 1 OR status IS NULL) AS M
WHERE M.ItemID={};
    '''
    cursor.execute(query_check_item_notavail.format(itemid))
    return cursor.fetchone()[0]
#check whether a swap record is associated with a user
def check_swap_asso(cursor,email,recordid):
    query_check_swap_asso='''WITH M1 AS (SELECT itemID AS proposedItemID, ownerEmail AS proposerEmail FROM Item),
     M2 AS (SELECT itemID AS desiredItemID, ownerEmail as counterpartyEmail FROM Item)
SELECT COUNT(*) 
FROM SwapRecord LEFT JOIN M1 ON SwapRecord.proposedItemID=M1.proposedItemID LEFT JOIN M2 ON SwapRecord.desiredItemID=M2.desiredItemID
WHERE (proposerEmail="{}" OR counterpartyEmail="{}") AND recordID={};
    '''
    cursor.execute(query_check_swap_asso.format(email,email,recordid))
    return cursor.fetchone()[0]


###list item part
#insert to Item
def insert_item(cursor,email,title,description,game_condition):
    query_insert_item='''INSERT INTO Item(ownerEmail,title,description,game_condition)
                         VALUES ("{}","{}","{}","{}");'''
    cursor.execute(query_insert_item.format(email,title,description,game_condition))
    query_insert_id='''SELECT LAST_INSERT_ID()'''
    cursor.execute(query_insert_id)
    return cursor.fetchone()[0]
#insert to board game
def insert_board(cursor,id):
    query_insert_board='''INSERT INTO Boardgame(itemID) VALUES ({});'''
    cursor.execute(query_insert_board.format(id))
    query_insert_board_msg='''SELECT ROW_COUNT();'''
    cursor.execute(query_insert_board_msg)
    return cursor.fetchone()[0]
#insert to card game
def insert_card(cursor,id):
    query_insert_card='''INSERT INTO Cardgame(itemID) VALUES ({});'''
    cursor.execute(query_insert_card.format(id))
    query_insert_card_msg='''SELECT ROW_COUNT();'''
    cursor.execute(query_insert_card_msg)
    return cursor.fetchone()[0]
#insert to video game
def insert_video(cursor,id,video_platform,video_media):
    query_insert_video='''INSERT INTO Videogame(itemID, platformID, media) 
                          VALUES ({}, (SELECT PlatformID FROM VideoPlatform WHERE platform_name="{}"), "{}");'''
    cursor.execute(query_insert_video.format(id,video_platform,video_media))
    query_insert_video_msg='''SELECT ROW_COUNT();'''
    cursor.execute(query_insert_video_msg)
    return cursor.fetchone()[0]
#insert to computer game
def insert_computer(cursor,id,computer_platform):
    query_insert_computer='''INSERT INTO Computergame(itemID, computer_platform) VALUES ({},"{}");'''
    cursor.execute(query_insert_computer.format(id,computer_platform))
    query_insert_computer_msg='''SELECT ROW_COUNT();'''
    cursor.execute(query_insert_computer_msg)
    return cursor.fetchone()[0]
#insert to jigsaw puzzle
def insert_jigsaw(cursor,id,piececount):
    query_insert_jigsaw='''INSERT INTO Jigsawpuzzle(itemID, piece_count) VALUES ({},{});'''
    cursor.execute(query_insert_jigsaw.format(id,piececount))
    query_insert_jigsaw_msg='''SELECT ROW_COUNT();'''
    cursor.execute(query_insert_jigsaw_msg)
    return cursor.fetchone()[0]


### view my items part
#upper table
def view_items_upper(cursor,email):
    query_view_items_upper='''-- upper table --- need to update to word file
                              SELECT
                              (SELECT COUNT(*) FROM Item WHERE Item.ownerEmail="{}" AND Item.itemID IN (SELECT itemID FROM BoardGame)) AS BoardGame,
                              (SELECT COUNT(*) FROM Item WHERE Item.ownerEmail="{}" AND Item.itemID IN (SELECT itemID FROM CardGame)) AS CardGame,
                              (SELECT COUNT(*) FROM Item WHERE Item.ownerEmail="{}" AND Item.itemID IN (SELECT itemID FROM ComputerGame)) AS ComputerGame,
                              (SELECT COUNT(*) FROM Item WHERE Item.ownerEmail="{}" AND Item.itemID IN (SELECT itemID FROM JigsawPuzzle)) AS JigsawPuzzle,
                              (SELECT COUNT(*) FROM Item WHERE Item.ownerEmail="{}" AND Item.itemID IN (SELECT itemID FROM VideoGame)) AS VideoGame,
                              (SELECT COUNT(*) FROM Item WHERE Item.ownerEmail="{}") AS Total;'''
    cursor.execute(query_view_items_upper.format(email,email,email,email,email,email))
    return [i[0] for i in cursor.description],cursor.fetchall()
#lower table
def view_items_lower(cursor,email):
    query_view_items_lower='''SELECT itemID, CASE
                              WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
                              WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
                              WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
                              WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
                              WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
                              ELSE 'Error Type'
                              END AS Game_Type, title, game_condition, description
                              FROM Item WHERE Item.ownerEmail="{}"
                              ORDER BY itemID ASC;'''
    cursor.execute(query_view_items_lower.format(email))
    return [i[0] for i in cursor.description],cursor.fetchall()



### search item part
#search by keyword
def search_keyword(cursor,email,keyword):
    query_search_keyword='''SELECT Item.itemID AS 'Item', CASE
                            WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
                            WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
                            WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
                            WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
                            WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
                            ELSE 'Error Type'
                            END AS  'Game type',
                            Item.Title AS 'Title',Item.game_condition AS 'Condition',Item.Description AS 'Description',
                            cal_dist((SELECT User.postalCode FROM User WHERE User.email ="{}"), User.postalCode) AS 'Distance'
                            FROM Item INNER JOIN User ON User.Email = Item.ownerEmail
                            WHERE User.Email != "{}"
                                AND (Item.Description LIKE "{}" OR Item.Title LIKE "{}")
                                AND (Item.itemID NOT IN (SELECT proposedItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
                                AND (Item.itemID NOT IN (SELECT desiredItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
                            ORDER BY Distance ASC, Item.itemID ASC;'''
    cursor.execute(query_search_keyword.format(email,email,keyword,keyword))
    return [i[0] for i in cursor.description], cursor.fetchall()
#search by my postal code
def search_my_postalcode(cursor,email):
    query_search_mypostal='''SELECT Item.itemID AS 'Item', CASE
    WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
    WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
    WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
    WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
    WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
    ELSE 'Error Type'
    END AS  'Game type',
       Item.Title AS 'Title',
       Item.game_condition AS 'Condition',
       Item.Description AS 'Description',
       cal_dist((SELECT User.postalCode FROM User WHERE User.email = "{}"), User.postalCode) AS 'Distance'
FROM Item INNER JOIN User ON User.Email = Item.ownerEmail
WHERE User.postalCode = (SELECT User.postalCode FROM User WHERE User.email = "{}")
   AND User.Email != "{}"
   AND (Item.itemID NOT IN (
     SELECT proposedItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
   AND (Item.itemID NOT IN (
     SELECT desiredItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
ORDER BY Distance ASC, Item.itemID ASC;
    '''
    cursor.execute(query_search_mypostal.format(email,email,email))
    return [i[0] for i in cursor.description], cursor.fetchall()
#search by miles
def search_miles(cursor,email,miles):
    query_search_miles='''SELECT Item.itemID AS 'Item',CASE
    WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
    WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
    WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
    WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
    WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
    ELSE 'Error Type'
    END AS  'Game type',
       Item.Title AS 'Title',
       Item.game_condition AS 'Condition',
       Item.Description AS 'Description',
       cal_dist((SELECT User.postalCode FROM User WHERE User.email = "{}"), User.postalCode) AS 'Distance'
FROM Item INNER JOIN User ON User.Email = Item.ownerEmail
WHERE User.postalCode IN (
    SELECT User.postalCode
    FROM User INNER JOIN Item ON User.Email = Item.ownerEmail
    WHERE cal_dist((SELECT User.postalCode FROM User WHERE User.email = "{}"), User.postalCode) <= {}
)
AND User.Email != "{}"
AND (Item.itemID NOT IN (
  SELECT proposedItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
AND (Item.itemID NOT IN (
  SELECT desiredItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
ORDER BY Distance ASC, Item.itemID ASC;
    '''
    cursor.execute(query_search_miles.format(email,email,miles,email))
    return [i[0] for i in cursor.description], cursor.fetchall()
#search by postal code
def search_postalcode(cursor,email,postalcode):
    query_search_postalcode='''SELECT Item.itemID AS 'Item', CASE
    WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
    WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
    WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
    WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
    WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
    ELSE 'Error Type'
    END AS  'Game type',
       Item.Title AS 'Title',
       Item.game_condition AS 'Condition',
       Item.Description AS 'Description',
       cal_dist((SELECT User.postalCode FROM User WHERE User.email = "{}"), User.postalCode) AS 'Distance'
FROM Item INNER JOIN User ON User.Email = Item.ownerEmail
WHERE User.postalCode ="{}" AND User.Email != "{}"
  AND (Item.itemID NOT IN (
     SELECT proposedItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
  AND (Item.itemID NOT IN (
     SELECT desiredItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
ORDER BY Distance ASC, Item.itemID ASC;
    '''
    cursor.execute(query_search_postalcode.format(email,postalcode,email))
    return [i[0] for i in cursor.description], cursor.fetchall()


### swap history part
#upper table
def swap_history_upper(cursor,email):
    query_swap_history_upper='''WITH
UserItem AS (
    SELECT email, postalCode, first_name, last_name, nick_name, itemID, title, description, game_condition
	  FROM User
    JOIN Item ON User.email = Item.ownerEmail),
MySwapRecord AS (
    SELECT recordID, PUserItem.email AS proposerEmail, CUserItem.email AS counterpartyEmail, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate, PUserItem.title AS Ptitle, CUserItem.title AS Ctitle, PUserItem.nick_name AS Pnick_name, CUserItem.nick_name AS Cnick_name
	  FROM SwapRecord
    JOIN UserItem AS PUserItem ON SwapRecord.proposedItemID = PUserItem.itemID
	  JOIN UserItem AS CUserItem ON SwapRecord.desiredItemID = CUserItem.itemID
    WHERE (PUserItem.email = "{}" OR CUserItem.email = "{}") AND status IS NOT NULL)
SELECT  CASE WHEN proposerEmail = "{}" THEN "Proposer"
             WHEN counterpartyEmail = "{}" THEN "Counterparty"
        END AS "My role", COUNT(*) AS Total, sum(status) AS Accepted, sum(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS Rejected,
        ROUND(SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) / COUNT(*)*100,1) AS "Rejected %"
FROM MySwapRecord
GROUP BY CASE WHEN proposerEmail = "{}" THEN "Proposer"
              WHEN counterpartyEmail = "{}" THEN "Counterparty"
END;
    '''
    cursor.execute(query_swap_history_upper.format(email,email,email,email,email,email))
    return [i[0] for i in cursor.description], cursor.fetchall()


# lower table
def swap_history_lower(cursor,email):
    query_swap_history_lower='''WITH
UserItem AS (
    SELECT  email, postalCode, first_name, last_name, nick_name, itemID, title, description, game_condition
	  FROM User JOIN Item ON User.email = Item.ownerEmail),
MySwapRecord AS (
    SELECT  recordID, PUserItem.email AS proposerEmail, CUserItem.email AS counterpartyEmail, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate, PUserItem.title AS Ptitle, CUserItem.title AS Ctitle, PUserItem.nick_name AS Pnick_name, CUserItem.nick_name AS Cnick_name
	  FROM SwapRecord
    JOIN UserItem AS PUserItem ON SwapRecord.proposedItemID = PUserItem.itemID
	  JOIN UserItem AS CUserItem ON SwapRecord.desiredItemID = CUserItem.itemID
    WHERE   (PUserItem.email = "{}" OR CUserItem.email = "{}") AND status IS NOT NULL)
SELECT  recordID, propose_date AS "Proposed Date", decide_date AS "Accepted/Rejected Date",
    CASE WHEN status=1 THEN "Accepted"
         WHEN status=0 THEN "Rejected"
    END AS "Swap Status",
	CASE WHEN MySwapRecord.proposerEmail = "{}" THEN "Proposer"
       WHEN MySwapRecord.counterpartyEmail = "{}" THEN "Counterparty"
	END AS "My Role",
  Ptitle AS "Proposed Item", Ctitle AS "Desired Item",
  CASE WHEN MySwapRecord.proposerEmail != "{}" THEN Pnick_name
		   WHEN MySwapRecord.counterpartyEmail != "{}" THEN Cnick_name
  END AS "Other User",
  CASE WHEN (status = 1) AND MySwapRecord.proposerEmail = "{}" THEN
			 CASE WHEN proposer_rate IS NOT NULL THEN proposer_rate
				    WHEN proposer_rate IS NULL THEN "Wait for rating"
       END
       WHEN (status = 1) AND MySwapRecord.counterpartyEmail = "{}" THEN
			 CASE WHEN counterparty_rate IS NOT NULL THEN counterparty_rate
            WHEN counterparty_rate IS NULL THEN "Wait for rating"
       END
  END AS "Rating"
FROM MySwapRecord ORDER BY decide_date DESC, propose_date;
    '''
    cursor.execute(query_swap_history_lower.format(email,email,email,email,email,email,email,email))
    return [i[0] for i in cursor.description], cursor.fetchall()



### view item detail part
def view_item_detail(cursor,email,itemid):
    query_item_detail='''-- view items
SELECT itemID, CASE
WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
ELSE 'Error Type'
END AS Game_Type, title, game_condition, description, email, first_name, last_name,
cal_dist(postalCode, (SELECT postalCode FROM User WHERE email="{}")) AS Distance,
(SELECT AVG(rate)
FROM(
    SELECT proposerEmail as Email, counterparty_rate AS rate
    FROM gameswapDB.SwapRecord
        NATURAL JOIN(
            SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	        FROM gameswapDB.Item
        ) AS M1
    WHERE M1.proposerEmail=(SELECT ownerEmail FROM Item WHERE itemID={})
    UNION ALL
    -- when I am the counterparty of the swap, select the proposer_rate
	SELECT counterpartyEmail AS Email, proposer_rate AS rate
    FROM gameswapDB.SwapRecord
        NATURAL JOIN(
            SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	        FROM gameswapDB.Item
        ) AS M2
    WHERE M2.counterpartyEmail=(SELECT ownerEmail FROM Item WHERE itemID={})
) AS M) AS Rating
FROM Item
NATURAL JOIN
(SELECT email, first_name, last_name, email AS ownerEmail, postalCode FROM User) AS U
WHERE Item.itemID={};
    '''
    cursor.execute(query_item_detail.format(email,itemid,itemid,itemid))
    return [i[0] for i in cursor.description], cursor.fetchall()


### propose swap part: get my available items
def get_avail_item(cursor,email,desiredItemID):
    query_get_avail_item='''SELECT itemID, CASE
WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
ELSE 'Error Type'
END AS Game_Type
, title, game_condition
FROM Item
WHERE ownerEmail = "{}" AND
		(itemID NOT IN (SELECT proposedItemID
                        FROM SwapRecord
                        WHERE status = 1 or status IS NULL)) AND
		(itemID NOT IN (SELECT desiredItemID
                    FROM SwapRecord
                    WHERE status = 1 or status IS NULL)) AND 
        (SELECT COUNT(*) FROM SwapRecord WHERE desiredItemID={} AND proposedItemID=itemId)=0;
    '''
    cursor.execute(query_get_avail_item.format(email,desiredItemID))
    return [i[0] for i in cursor.description], cursor.fetchall()

# Insert Pending Swap to SwapRecord
def insert_pending_swap(cursor, proposed_item_id, desired_item_id, proposed_date):
    query_check_swap = '''SELECT COUNT(*) FROM SwapRecord WHERE proposedItemID = {} AND desiredItemID = {}; '''
    cursor.execute(query_check_swap.format(proposed_item_id, desired_item_id))
    r1 = cursor.fetchone()[0]
    query_check_item = '''SELECT COUNT(*) FROM
    (SELECT proposedItemID AS ItemID FROM SwapRecord WHERE status = 1 OR status IS NULL
    UNION
    SELECT desiredItemID AS ItemID FROM SwapRecord WHERE status = 1 OR status IS NULL) AS M
    WHERE M.ItemID={};
        '''
    cursor.execute(query_check_item.format(proposed_item_id))
    r2 = cursor.fetchone()[0]
    cursor.execute(query_check_item.format(desired_item_id))
    r3 = cursor.fetchone()[0]
    if r1+r2+r3==0:
        insert_pending_sql = f"INSERT INTO gameswapDB.SwapRecord (proposedItemID, desiredItemID, status, propose_date, " \
                         f"decide_date, proposer_rate, counterparty_rate)" \
                         f"VALUES ({proposed_item_id},{desired_item_id},NULL,'{proposed_date}',NULL,NULL,NULL)"
        cursor.execute(insert_pending_sql)
        query_insert_id = '''SELECT LAST_INSERT_ID()'''
        cursor.execute(query_insert_id)
        return cursor.fetchone()[0]
    return 'ERROR'

### propose swap part: insert a swap record
def insert_swap(cursor,proposed_item,desired_item):
    query_check_swap='''SELECT COUNT(*) FROM SwapRecord WHERE proposedItemID = {} AND desiredItemID = {}; '''
    cursor.execute(query_check_swap.format(proposed_item,desired_item))
    r1=cursor.fetchone()[0]
    query_check_item='''SELECT COUNT(*) FROM
(SELECT proposedItemID AS ItemID FROM SwapRecord WHERE status = 1 OR status IS NULL
UNION
SELECT desiredItemID AS ItemID FROM SwapRecord WHERE status = 1 OR status IS NULL) AS M
WHERE M.ItemID={};
    '''
    cursor.execute(query_check_item.format(proposed_item))
    r2=cursor.fetchone()[0]
    cursor.execute(query_check_item.format(desired_item))
    r3=cursor.fetchone()[0]
    if r1+r2+r3==0:
        query_insert_swap = "INSERT INTO SwapRecord (proposedItemID,desiredItemID,status,propose_date,decide_date,proposer_rate,counterparty_rate) VALUES ({},{},NULL,CURDATE(),NULL,NULL,NULL);"
        cursor.execute(query_insert_swap.format(proposed_item,desired_item))
        query_insert_id = '''SELECT LAST_INSERT_ID()'''
        cursor.execute(query_insert_id)
        return cursor.fetchone()[0]
    return 'ERROR'


### accept/reject swap part
def show_pending_swap(cursor,email):
    query_show_pending_swap='''WITH UserItem AS (
SELECT email, postalCode, nick_name,
    (SELECT ROUND(AVG(rate),2)
	 FROM(
          SELECT proposerEmail as Email, counterparty_rate AS rate
          FROM SwapRecord NATURAL JOIN(
              SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
		      FROM Item
		  ) AS M1
          WHERE M1.proposerEmail=email
          UNION ALL
		  SELECT counterpartyEmail AS Email, proposer_rate AS rate
          FROM SwapRecord NATURAL JOIN(
              SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	          FROM Item
          ) AS M2
          WHERE M2.counterpartyEmail=email
      ) AS M)
      AS rating, itemID, title
FROM    User
JOIN    Item
ON      User.email = Item.ownerEmail)
SELECT  SwapRecord.recordID, SwapRecord.propose_date AS Date, CUserItem.title AS "Desired Item",
		PUserItem.nick_name AS "Proposer", PUserItem.rating AS "Rating",
		cal_dist(PUserItem.postalCode, CUserItem.postalCode) AS Distance,
		PUserItem.title AS "Proposed Item"
FROM    SwapRecord
JOIN    UserItem AS CUserItem
ON      SwapRecord.desiredItemID = CUserItem.itemID
JOIN    UserItem AS PUserItem
ON      SwapRecord.proposedItemID = PUserItem.itemID
WHERE   SwapRecord.status IS NULL AND CUserItem.email="{}"
ORDER BY SwapRecord.propose_date;
    '''
    cursor.execute(query_show_pending_swap.format(email))
    return [i[0] for i in cursor.description], cursor.fetchall()



### rate swap part
def show_unrated_swap(cursor,email):
    query_show_unrated_swap='''WITH UserItem AS (
    SELECT email, postalCode, first_name, last_name, nick_name, itemID, title, description, game_condition
	  FROM User
    JOIN Item ON User.email = Item.ownerEmail),
MySwapRecord AS (SELECT recordID, PUserItem.email AS proposerEmail, CUserItem.email AS counterpartyEmail, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate, PUserItem.title AS Ptitle, CUserItem.title AS Ctitle, PUserItem.nick_name AS Pnick_name, CUserItem.nick_name as Cnick_name
    FROM SwapRecord
    JOIN UserItem AS PUserItem
    ON SwapRecord.proposedItemID = PUserItem.itemID
    JOIN UserItem AS CUserItem
    ON SwapRecord.desiredItemID = CUserItem.itemID
    WHERE   (PUserItem.email = "{}" OR CUserItem.email = "{}") AND status IS NOT NULL)
SELECT recordID, decide_date AS "Accepted/Rejected Date",
    CASE WHEN MySwapRecord.proposerEmail = "{}" THEN "Proposer"
         WHEN MySwapRecord.counterpartyEmail = "{}" THEN "Counterparty"
    END AS "My Role",
    Ptitle AS "Proposed Item", Ctitle AS "Desired Item",
    CASE WHEN MySwapRecord.proposerEmail != "{}" THEN Pnick_name
         WHEN MySwapRecord.counterpartyEmail != "{}" THEN Cnick_name
    END AS "Other User",
	  CASE WHEN MySwapRecord.proposerEmail = "{}" AND MySwapRecord.proposer_rate IS NULL THEN "Wait for rating"
         WHEN MySwapRecord.counterpartyEmail = "{}" AND MySwapRecord.counterparty_rate IS NULL THEN "Wait for rating"
    END AS Rating
FROM    MySwapRecord
WHERE   status = 1 AND ((MySwapRecord.proposerEmail = "{}" AND MySwapRecord.proposer_rate IS NULL) OR (MySwapRecord.counterpartyEmail = "{}" AND MySwapRecord.counterparty_rate IS NULL))
ORDER BY decide_date DESC;
    '''
    cursor.execute(query_show_unrated_swap.format(email,email,email,email,email,email,email,email,email,email))
    return [i[0] for i in cursor.description], cursor.fetchall()


### assign a rating value to a record
def assign_rating_to_record(cursor, rating, record_id, role):
    if role == "Proposer":
        assign_rating_to_record_sql = "UPDATE gameswapDB.SwapRecord SET proposer_rate={} WHERE recordID={};"
    else:
        assign_rating_to_record_sql ="UPDATE gameswapDB.SwapRecord SET counterparty_rate={} WHERE recordID={};"
    cursor.execute(assign_rating_to_record_sql.format(rating, record_id))
    return record_id

### accept or reject
def accept_or_reject(cursor, record_id, accept_or_reject):
    now = datetime.now()
    sql ="UPDATE gameswapDB.SwapRecord SET status={}, decide_date ='{}' WHERE recordID={};"
    sql = sql.format(accept_or_reject, now, record_id)
    cursor.execute(sql)
    return record_id
def display_contact(cursor,record_id):
    query_display_contact='''SELECT email,nick_name, phoneNumber, share_phone
FROM User LEFT JOIN Phone ON User.email=Phone.ownerEmail
WHERE User.email=(SELECT ownerEmail FROM Item WHERE itemID=(
SELECT proposedItemID FROM SwapRecord WHERE recordID={}))'''
    cursor.execute(query_display_contact.format(record_id))
    return cursor.fetchone()

###swap details part
def view_swap_detail(cursor,email,recordid):
    query_view_swap_detail='''WITH TargetSwapRecord AS (
SELECT recordID, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate
FROM  SwapRecord WHERE recordID = {}),
UserItemPhone AS  (
SELECT  email, postalCode, first_name, last_name, nick_name, phoneNumber, phone_type, share_phone, itemID, title, description, game_condition,
    CASE WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
				 WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
         WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
         WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
         WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
         ELSE 'Error Type'
    END AS game_Type
FROM User
JOIN Item ON User.email = Item.ownerEmail
LEFT JOIN Phone ON User.email = Phone.ownerEmail),
TargetSwapAllInfo AS (
SELECT recordID, PUserItemPhone.email AS proposerEmail, CUserItemPhone.email AS counterpartyEmail,
			 proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate,
       counterparty_rate, PUserItemPhone.title AS Ptitle, CUserItemPhone.title AS Ctitle,
       PUserItemPhone.game_type AS Pgame_type, CUserItemPhone.game_type as Cgame_type,
       PUserItemPhone.game_condition AS Pgame_condition, CUserItemPhone.game_condition AS Cgame_condition,
       PUserItemPhone.description AS Pdescription, PUserItemPhone.nick_name AS Pnick_name,
       CUserItemPhone.nick_name AS Cnick_name, PUserItemPhone.first_name AS Pfirst_name,
       CUserItemPhone.first_name AS Cfirst_name,PUserItemPhone.last_name AS Plast_name,
       CUserItemPhone.last_name AS Clast_name, PUserItemPhone.postalCode AS PpostalCode,
       CUserItemPhone.postalCode AS CpostalCode, PUserItemPhone.phoneNumber AS PphoneNumber,
       CUserItemPhone.phoneNumber AS CphoneNumber, PUserItemPhone.phone_type AS Pphone_type,
       CUserItemPhone.phone_type AS Cphone_type, PUserItemPhone.share_phone AS Pshare_phone,
       CUserItemPhone.share_phone AS Cshare_phone
       FROM TargetSwapRecord
       JOIN UserItemPhone AS PUserItemPhone
       ON TargetSwapRecord.proposedItemID = PUserItemPhone.itemID
       JOIN UserItemPhone AS CUserItemPhone
       ON TargetSwapRecord.desiredItemID = CUserItemPhone.itemID)

SELECT
-- swap details
   propose_date AS Proposed, decide_date AS "Accepted/Rejected",
   CASE WHEN status=1 THEN "Accepted"
        WHEN status=0 THEN "Rejected"
        WHEN status IS NULL THEN "Pending"
   END AS Status,
   CASE WHEN TargetSwapAllInfo.proposerEmail = "{}" THEN "Proposer"
        WHEN TargetSwapAllInfo.counterpartyEmail = "{}" THEN "Counterparty"
   END AS "My Role",
   CASE WHEN TargetSwapAllInfo.proposerEmail = "{}" THEN
        CASE WHEN proposer_rate IS NOT NULL THEN proposer_rate
             ElSE "$Rating"
	 END
        WHEN TargetSwapAllInfo.counterpartyEmail = "{}" THEN
	 CASE WHEN counterparty_rate IS NOT NULL THEN counterparty_rate
             ElSE "$Rating"
        END
   END AS "Rating left",
-- other user details
   CASE WHEN proposerEmail ="{}" THEN Cnick_name
        WHEN counterpartyEmail ="{}" THEN Pnick_name
   END AS "Nickname",
   cal_dist(PpostalCode, CpostalCode) AS Distance,
   CASE WHEN status = 1 THEN
		 CASE WHEN proposerEmail = "{}" THEN Cfirst_name
              WHEN counterpartyEmail = "{}" THEN Pfirst_name
		 END
         ELSE NULL
	END AS "Name",
	CASE WHEN status = 1 THEN
       CASE WHEN proposerEmail = "{}" THEN counterpartyEmail
			      WHEN counterpartyEmail = "{}" THEN proposerEmail
		   END
       ELSE NULL
	END AS "Email",
	CASE WHEN status = 1 THEN
       CASE WHEN (proposerEmail = "{}" AND Cshare_phone=1) THEN CphoneNumber
			 WHEN (counterpartyEmail = "{}" AND Pshare_phone=1) THEN PphoneNumber
            ELSE NULL
       END
       ELSE NULL
  END AS "Phone Number",
	CASE WHEN status = 1 THEN
       CASE WHEN (proposerEmail = "{}" AND Cshare_phone=1) THEN Cphone_type
			      WHEN (counterpartyEmail = "{}" AND pshare_phone=1) THEN Pphone_type
            ELSE NULL
       END
       ELSE NULL
  END AS "Phone Type",
-- proposed item
  proposedItemID AS "Item #", Ptitle AS "Title", Pgame_type AS "Game type",
            Pgame_condition AS "Condition", Pdescription AS "Description",
-- desired item
  desiredItemID AS "Item #", Ctitle AS "Title", Cgame_type AS "Game type",
            Cgame_condition AS "Condition"
FROM    TargetSwapAllInfo;
    '''
    cursor.execute(query_view_swap_detail.format(recordid,email,email,email,email,email,email,email,email,email,email,email,email,email,email))
    return [i[0] for i in cursor.description], cursor.fetchall()
