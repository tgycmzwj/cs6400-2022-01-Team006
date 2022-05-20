-- queries for view my item
-- define some test cases
SET @UserID='user3@gmail.com';


-- lower table
SELECT itemID, CASE 
WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
ELSE 'Error Type'
END AS Game_Type, title, game_condition, description, ' ' AS 'Detail'
FROM Item WHERE Item.ownerEmail=@UserID;

-- upper table --- need to update to word file
SELECT 
(SELECT COUNT(*) FROM Item WHERE Item.ownerEmail=@UserID AND Item.itemID IN (SELECT itemID FROM BoardGame)) AS BoardGame, 
(SELECT COUNT(*) FROM Item WHERE Item.ownerEmail=@UserID AND Item.itemID IN (SELECT itemID FROM CardGame)) AS CardGame, 
(SELECT COUNT(*) FROM Item WHERE Item.ownerEmail=@UserID AND Item.itemID IN (SELECT itemID FROM ComputerGame)) AS ComputerGame, 
(SELECT COUNT(*) FROM Item WHERE Item.ownerEmail=@UserID AND Item.itemID IN (SELECT itemID FROM JigsawPuzzle)) AS JigsawPuzzle, 
(SELECT COUNT(*) FROM Item WHERE Item.ownerEmail=@UserID AND Item.itemID IN (SELECT itemID FROM VideoGame)) AS VideoGame,
(SELECT COUNT(*) FROM Item WHERE Item.ownerEmail=@UserID) AS Total;
