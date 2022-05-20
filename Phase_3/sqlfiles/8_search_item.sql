-- queries for searching items
USE gameswapDB;
-- define some test cases
SET @UserID='user3@gmail.com';
SET @Distance=2700;
SET @PostalCode='00670';
SET @StringSearch='%xxx%';

-- searching by keyword
SELECT Item.itemID AS 'Item', CASE
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
       cal_dist((SELECT User.postalCode FROM User WHERE User.email =@UserID), User.postalCode) AS 'Distance'
FROM Item INNER JOIN User ON User.Email = Item.ownerEmail
WHERE User.Email != @UserID
  AND (Item.Description LIKE @StringSearch OR Item.Title LIKE @StringSearch)
  AND (Item.itemID NOT IN (
    SELECT proposedItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
  AND (Item.itemID NOT IN (
    SELECT desiredItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
ORDER BY Distance ASC, Item.itemID ASC;


-- searching in my postal code
SELECT Item.itemID AS 'Item', CASE
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
       cal_dist((SELECT User.postalCode FROM User WHERE User.email = @UserID), User.postalCode) AS 'Distance'
FROM Item INNER JOIN User ON User.Email = Item.ownerEmail
WHERE User.postalCode = (SELECT User.postalCode FROM User WHERE User.email = @UserID)
   AND User.Email != @UserID
   AND (Item.itemID NOT IN (
     SELECT proposedItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
   AND (Item.itemID NOT IN (
     SELECT desiredItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
ORDER BY Distance ASC, Item.itemID ASC;


-- searching in the postal code of $target_postal_code
SELECT Item.itemID AS 'Item', CASE
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
       cal_dist((SELECT User.postalCode FROM User WHERE User.email = @UserID), User.postalCode) AS 'Distance'
FROM Item INNER JOIN User ON User.Email = Item.ownerEmail
WHERE User.postalCode =@PostalCode AND User.Email != @UserID
  AND (Item.itemID NOT IN (
     SELECT proposedItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
  AND (Item.itemID NOT IN (
     SELECT desiredItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
ORDER BY Distance ASC, Item.itemID ASC;


-- queries used for searching within $x_miles miles of me:
SELECT Item.itemID AS 'Item',CASE
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
       cal_dist((SELECT User.postalCode FROM User WHERE User.email = @UserID), User.postalCode) AS 'Distance'
FROM Item INNER JOIN User ON User.Email = Item.ownerEmail
WHERE User.postalCode IN (
    SELECT User.postalCode
    FROM User INNER JOIN Item ON User.Email = Item.ownerEmail
    WHERE cal_dist((SELECT User.postalCode FROM User WHERE User.email = @UserID), User.postalCode) <= @Distance
)
AND User.Email != @UserID
AND (Item.itemID NOT IN (
  SELECT proposedItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
AND (Item.itemID NOT IN (
  SELECT desiredItemID FROM SwapRecord WHERE status = 1 OR status IS NULL))
ORDER BY Distance ASC, Item.itemID ASC;
