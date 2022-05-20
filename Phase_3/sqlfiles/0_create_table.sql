-- create new database
-- Note: we directly include foreign key constraint at the time
--       of creating tables. The table creation follows the designed
--       order so that the reference table is always created before 
--       the table that refers to it
-- Note: We use the system default handler for data deletion involving
--       foreign key (i.e. prohibited unless remove remove the entity
--       that refers to it first) since the entire project does not 
--       have deletion operation at all 
DROP DATABASE IF EXISTS gameswapDB;
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
    title VARCHAR(50) NOT NULL,
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
);

