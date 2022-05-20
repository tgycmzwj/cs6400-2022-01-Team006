-- queries used for list an item
USE gameswapDB;
-- define some test cases
-- item 1 is a board game
SET @Email1='user3@gmail.com';
SET @Title1='UGG1';
SET @Description1='xxx';
SET @Game_Condition1='Lightly Used';
-- item 2 is a card game
SET @Email2='user7@gmail.com';
SET @Title2='UGG2';
SET @Description2='xxx';
SET @Game_Condition2='Lightly Used';
-- item 3 is a computer game
SET @Email3='user9@gmail.com';
SET @Title3='UGG3';
SET @Description3='xxx';
SET @Game_Condition3='Lightly Used';
SET @Computer_Platform3='macOS';
-- item 4 is a jigsaw puzzle
SET @Email4='user11@gmail.com';
SET @Title4='UGG4';
SET @Description4='xxx';
SET @Game_Condition4='Lightly Used';
SET @Piece_Count4=15;
-- item 5 is a video game
SET @Email5='user13@gmail.com';
SET @Title5='UGG5';
SET @Description5='xxx';
SET @Game_Condition5='Lightly Used';
SET @Video_Platform5='Nintendo';
SET @Media5='optical disc';

-- insert board game
INSERT INTO Item(ownerEmail, title, description, game_condition)
VALUES (@Email1,@Title1,@Description1,@Game_Condition1);
INSERT INTO Boardgame(itemID) VALUES (LAST_INSERT_ID());
-- insert card game
INSERT INTO Item(ownerEmail, title, description, game_condition)
VALUES (@Email2,@Title2,@Description2,@Game_Condition2);
INSERT INTO Cardgame(itemID) VALUES (LAST_INSERT_ID());
-- insert video game
INSERT INTO Item(ownerEmail, title, description, game_condition)
VALUES (@Email5,@Title5,@Description5,@Game_Condition5);
INSERT INTO Videogame(itemID, platformID, media) 
VALUES (LAST_INSERT_ID(), 
       (SELECT PlatformID FROM VideoPlatform WHERE platform_name=@Video_Platform5), @Media5);
-- insert computer game
INSERT INTO Item(ownerEmail, title, description, game_condition)
VALUES (@Email3,@Title3,@Description3,@Game_Condition3);
INSERT INTO Computergame(itemID, computer_platform) VALUES (LAST_INSERT_ID(),@Computer_Platform3);
-- insert Jigsaw puzzle
INSERT INTO Item(ownerEmail, title, description, game_condition)
VALUES (@Email4,@Title4,@Description4,@Game_Condition4);
INSERT INTO Jigsawpuzzle(itemID, piece_count) VALUES (LAST_INSERT_ID(),@Piece_Count4);
