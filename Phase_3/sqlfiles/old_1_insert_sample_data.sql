USE gameswapDB;

-- insert data for Location: need to put postal_codes.csv in /tmp folder
LOCK TABLES Location WRITE;
LOAD DATA INFILE '/tmp/postal_codes.csv'
INTO TABLE Location
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for User
LOCK TABLES User WRITE;
INSERT INTO gameswapDB.User(
    email,postalCode,password,first_name,last_name,nick_name
)
VALUES
('user1@gmail.com','12345','aaaaaaaa','first_name1','last_name1','nick_name1'),
('user2@gmail.com','00212','aaaaaaaa','first_name2','last_name2','nick_name2'),
('user3@gmail.com','00670','aaaaaaaa','first_name3','last_name3','nick_name3'),
('user4@gmail.com','00911','aaaaaaaa','first_name4','last_name4','nick_name4'),
('user5@gmail.com','01106','aaaaaaaa','first_name5','last_name5','nick_name5'),
('user6@gmail.com','01201','aaaaaaaa','first_name6','last_name6','nick_name6'),
('user7@gmail.com','01262','aaaaaaaa','first_name7','last_name7','nick_name7'),
('user8@gmail.com','01568','aaaaaaaa','first_name8','last_name8','nick_name8'),
('user9@gmail.com','01852','aaaaaaaa','first_name9','last_name9','nick_name9'),
('user10@gmail.com','02065','aaaaaaaa','first_name10','last_name10','nick_name10'),
('user11@gmail.com','12345','aaaaaaaa','first_name11','last_name11','nick_name11'),
('user12@gmail.com','00212','aaaaaaaa','first_name12','last_name12','nick_name12'),
('user13@gmail.com','00670','aaaaaaaa','first_name13','last_name13','nick_name13'),
('user14@gmail.com','00911','aaaaaaaa','first_name14','last_name14','nick_name14'),
('user15@gmail.com','01106','aaaaaaaa','first_name15','last_name15','nick_name15'),
('user16@gmail.com','01201','aaaaaaaa','first_name16','last_name16','nick_name16'),
('user17@gmail.com','01262','aaaaaaaa','first_name17','last_name17','nick_name17'),
('user18@gmail.com','01568','aaaaaaaa','first_name18','last_name18','nick_name18'),
('user19@gmail.com','01852','aaaaaaaa','first_name19','last_name19','nick_name19'),
('user20@gmail.com','02065','aaaaaaaa','first_name20','last_name20','nick_name20');
UNLOCK TABLES;


-- insert data for Phone
LOCK TABLES Phone WRITE;
INSERT INTO gameswapDB.Phone(
    phoneNumber,ownerEmail,phone_type,share_phone
)
VALUES
('0000000001','user1@gmail.com','home',TRUE),
('0000000004','user4@gmail.com','work',FALSE),
-- try a problematic case
-- ('0000000020','user20@gmail.com','home',TRUE),
('0000000007','user7@gmail.com','mobile',FALSE),
('0000000010','user10@gmail.com','work',FALSE),
('0000000013','user13@gmail.com','work',FALSE),
('0000000016','user16@gmail.com','work',FALSE),
('0000000019','user19@gmail.com','work',FALSE);
UNLOCK TABLES;


-- insert data for VideoPlatform
LOCK TABLES VideoPlatform WRITE;
INSERT INTO gameswapDB.VideoPlatform(
    platform_name
)
VALUES
('Nintendo'),
('PlayStation'),
('Xbox');
UNLOCK TABLES;


-- insert data for Item
LOCK TABLES Item WRITE;
INSERT INTO gameswapDB.Item(
	ownerEmail,title,description,game_condition
)
VALUES
('user1@gmail.com','UFO','xxxx','Lightly Used'),  -- 1, 'Board Game'
('user3@gmail.com','UFG','xxxx','Lightly Used'),  -- 2, 'Card Game'
('user5@gmail.com','UFG','xxxx','Heavily Used'), -- 3, 'Jigsaw Puzzle'
('user5@gmail.com','UFG','xxxx','Heavily Used'),  -- 4, 'Computer Game'
('user7@gmail.com','UFG','xxxx','Heavily Used'),  -- 5, 'Video Game'
('user9@gmail.com','UFG','xxxx','Heavily Used'),  -- 6, 'Video Game'
('user11@gmail.com','UFO','xxxx','Lightly Used'),  -- 7, 'Board Game'
('user13@gmail.com','UFG','xxxx','Lightly Used'),  -- 8, 'Card Game'
('user15@gmail.com','UFG','xxxx','Heavily Used'),  -- 9, 'Jigsaw Puzzle'
('user15@gmail.com','UFG','xxxx','Heavily Used'),  -- 10, 'Computer Game'
('user17@gmail.com','UFG','xxxx','Heavily Used'),  -- 11, 'Video Game'
('user19@gmail.com','UFG','xxxx','Heavily Used');  -- 12, 'Video Game'
UNLOCK TABLES;




-- insert for each sub category
-- this part will be implemented using triggers later but here we need to manually input those additional attribute
-- insert data for board game
LOCK TABLES BoardGame WRITE, Item AS DATA_ITEM READ;
INSERT INTO gameswapDB.BoardGame(
    itemID
)
SELECT itemID
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=1 OR DATA_ITEM.itemID=7;
UNLOCK TABLES;


-- insert data for card game
LOCK TABLES CardGame WRITE, Item AS DATA_ITEM READ;
INSERT INTO gameswapDB.CardGame(
    itemID
)
SELECT itemID
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=2 OR DATA_ITEM.itemID=8;
UNLOCK TABLES;


-- insert data for jigsaw puzzle
LOCK TABLES JigsawPuzzle WRITE, Item AS DATA_ITEM READ;
INSERT INTO gameswapDB.JigsawPuzzle(
    itemID,piece_count
)
SELECT itemID, 10
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=3;
UNLOCK TABLES;

LOCK TABLES JigsawPuzzle WRITE, Item AS DATA_ITEM READ;
INSERT INTO gameswapDB.JigsawPuzzle(
    itemID,piece_count
)
SELECT itemID, 15
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=9;
UNLOCK TABLES;


-- insert data for computer game
LOCK TABLES ComputerGame WRITE, Item AS DATA_ITEM READ;
INSERT INTO gameswapDB.ComputerGame(
    itemID,computer_platform
)
SELECT itemID,'Linux'
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=4;
UNLOCK TABLES;

LOCK TABLES ComputerGame WRITE, Item AS DATA_ITEM READ;
INSERT INTO gameswapDB.ComputerGame(
    itemID,computer_platform
)
SELECT itemID,'macOS'
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=10;
UNLOCK TABLES;

-- insert data for video game
LOCK TABLES VideoGame WRITE, Item AS DATA_ITEM READ, VideoPlatform AS DATA_PLATFORM READ;
INSERT INTO gameswapDB.VideoGame(
    itemID,platformID,media
)
SELECT itemID, (SELECT PlatformID FROM gameswapDB.VideoPlatform AS DATA_PLATFORM WHERE DATA_PLATFORM.platform_name='Xbox'), 'optical disc'
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=5;
UNLOCK TABLES;

LOCK TABLES VideoGame WRITE, Item AS DATA_ITEM READ, VideoPlatform AS DATA_PLATFORM READ;
INSERT INTO gameswapDB.VideoGame(
    itemID,platformID,media
)
SELECT itemID, (SELECT PlatformID FROM gameswapDB.VideoPlatform AS DATA_PLATFORM WHERE DATA_PLATFORM.platform_name='Nintendo'), 'game card'
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=6;
UNLOCK TABLES;

LOCK TABLES VideoGame WRITE, Item AS DATA_ITEM READ, VideoPlatform AS DATA_PLATFORM READ;
INSERT INTO gameswapDB.VideoGame(
    itemID,platformID,media
)
SELECT itemID, (SELECT PlatformID FROM gameswapDB.VideoPlatform AS DATA_PLATFORM WHERE DATA_PLATFORM.platform_name='PlayStation'), 'cartridge'
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=11;
UNLOCK TABLES;

LOCK TABLES VideoGame WRITE, Item AS DATA_ITEM READ, VideoPlatform AS DATA_PLATFORM READ;
INSERT INTO gameswapDB.VideoGame(
    itemID,platformID,media
)
SELECT itemID, (SELECT PlatformID FROM gameswapDB.VideoPlatform AS DATA_PLATFORM WHERE DATA_PLATFORM.platform_name='Nintendo'), 'optical disc'
FROM gameswapDB.Item AS DATA_ITEM
WHERE DATA_ITEM.itemID=12;
UNLOCK TABLES;


-- insert for swap records
LOCK TABLES SwapRecord WRITE;
INSERT INTO gameswapDB.SwapRecord(
    proposedItemID,desiredItemID,status,propose_date,decide_date,proposer_rate,counterparty_rate
)
VALUES
(1,2,NULL,'2022-02-21',NULL,NULL,NULL), -- 'user1@gmail.com','user3@gmail.com', PENDING
(3,5,1,'2022-02-21','2022-02-25',4.5,4.7),  -- 'user5@gmail.com','user7@gmail.com', COMPLETED
(4,6,1,'2022-02-21','2022-02-25',NULL,4.8),  -- 'user5@gmail.com','user9@gmail.com', ACCEPTED
(7,8,0,'2022-02-21','2022-02-25',NULL,NULL),  -- 'user11@gmail.com','user13@gmail.com', REJECTED
(9,11,1,'2022-02-21','2022-02-25',4.8,4.5),  -- 'user15@gmail.com','user17@gmail.com', ACCEPTED
(12,10,1,'2022-02-21','2022-02-25',3.8,4.8);  -- 'user19@gmail.com','user15@gmail.com', COMPLETED
UNLOCK TABLES;


