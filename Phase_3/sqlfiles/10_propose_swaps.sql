-- queries for proposing swaps

-- define some test cases
SET @UserID='user13@gmail.com';
SET @ProposedItemID=15;
SET @DesiredItemID=16;

-- obtain my own items that are available for swap
SELECT itemID, CASE 
WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
ELSE 'Error Type'
END AS Game_Type
, title, game_condition 
FROM Item
WHERE ownerEmail = @UserID AND 
		(itemID NOT IN (SELECT proposedItemID 
                        FROM SwapRecord
                        WHERE status = 1 or status IS NULL)) AND 
		(itemID NOT IN (SELECT desiredItemID
                    FROM SwapRecord
                    WHERE status = 1 or status IS NULL));
                    
-- check if the same swap has been submitted before
SELECT COUNT(*)  
FROM SwapRecord
WHERE proposedItemID = @ProposedItemID AND desiredItemID = @DesiredItemID; 

-- insert a new swap: don't do this 
INSERT INTO SwapRecord (proposedItemID,desiredItemID,status,propose_date,decide_date,proposer_rate,counterparty_rate)
VALUES  (@ProposedItemID,@DesiredItemID,NULL,CURDATE(),NULL,NULL,NULL);

