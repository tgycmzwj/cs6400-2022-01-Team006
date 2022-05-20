USE gameswapDB;

-- insert data for Location: need to put postal_codes.csv in /tmp folder
LOCK TABLES Location WRITE;
LOAD DATA INFILE '/tmp/data/postal_codes.csv'
INTO TABLE Location
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for user
LOCK TABLES User WRITE;
LOAD DATA INFILE '/tmp/data/users.csv'
INTO TABLE User
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for phone
LOCK TABLES Phone WRITE;
LOAD DATA INFILE '/tmp/data/phone.csv'
INTO TABLE Phone
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;


-- insert data for video platform
LOCK TABLES VideoPlatform WRITE;
INSERT INTO gameswapDB.VideoPlatform(
    platform_name
)
VALUES
('Nintendo'),
('PlayStation'),
('Xbox');
UNLOCK TABLES;


-- insert data for item
LOCK TABLES Item WRITE;
LOAD DATA INFILE '/tmp/data/items.csv'
INTO TABLE Item
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for board game
LOCK TABLES BoardGame WRITE;
LOAD DATA INFILE '/tmp/data/board_game.csv'
INTO TABLE BoardGame
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for card game
LOCK TABLES CardGame WRITE;
LOAD DATA INFILE '/tmp/data/card_game.csv'
INTO TABLE CardGame
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for computer game
LOCK TABLES ComputerGame WRITE;
LOAD DATA INFILE '/tmp/data/computer_game.csv'
INTO TABLE ComputerGame
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for video game
LOCK TABLES VideoGame WRITE;
LOAD DATA INFILE '/tmp/data/video_game.csv'
INTO TABLE VideoGame
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for jigsaw puzzle
LOCK TABLES JigsawPuzzle WRITE;
LOAD DATA INFILE '/tmp/data/jigsaw_puzzle.csv'
INTO TABLE JigsawPuzzle
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;

-- insert data for swap record
LOCK TABLES SwapRecord WRITE;
LOAD DATA INFILE '/tmp/data/swap_record.csv'
INTO TABLE SwapRecord
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UNLOCK TABLES;