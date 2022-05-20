-- queries for swap history

-- define some test cases
SET @UserID1="user11@gmail.com";
SET @UserID2="user15@gmail.com";
SET @Rating=4;
SET @RecordID=1;

-- show swap history lower table
WITH
UserItem AS (
    SELECT  email, postalCode, first_name, last_name, nick_name, itemID, title, description, game_condition
	  FROM User JOIN Item ON User.email = Item.ownerEmail),
MySwapRecord AS (
    SELECT  recordID, PUserItem.email AS proposerEmail, CUserItem.email AS counterpartyEmail, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate, PUserItem.title AS Ptitle, CUserItem.title AS Ctitle, PUserItem.nick_name AS Pnick_name, CUserItem.nick_name AS Cnick_name
	  FROM SwapRecord
    JOIN UserItem AS PUserItem ON SwapRecord.proposedItemID = PUserItem.itemID
	  JOIN UserItem AS CUserItem ON SwapRecord.desiredItemID = CUserItem.itemID
    WHERE   (PUserItem.email = @UserID1 OR CUserItem.email = @UserID1) AND status IS NOT NULL)
SELECT  propose_date AS "Proposed Date", decide_date AS "Accepted/Rejected Date", status AS "Swap Status",
	CASE WHEN MySwapRecord.proposerEmail = @UserID1 THEN "Proposer"
       WHEN MySwapRecord.counterpartyEmail = @UserID1 THEN "Counterparty"
	END AS "My Role",
  Ptitle AS "Proposed Item", Ctitle AS "Desired Item",
  CASE WHEN MySwapRecord.proposerEmail != @UserID1 THEN Pnick_name
		   WHEN MySwapRecord.counterpartyEmail != @UserID1 THEN Cnick_name
  END AS "Other User",
  CASE WHEN (status = 1) AND MySwapRecord.proposerEmail = @UserID1 THEN
			 CASE WHEN proposer_rate IS NOT NULL THEN proposer_rate
				    WHEN proposer_rate IS NULL THEN "$Rating"
       END
       WHEN (status = 1) AND MySwapRecord.counterpartyEmail = @UserID1 THEN
			 CASE WHEN counterparty_rate IS NOT NULL THEN counterparty_rate
            WHEN counterparty_rate IS NULL THEN "$Rating"
       END
  END AS "Rating"
FROM MySwapRecord ORDER BY decide_date DESC, propose_date;


-- show swap history upper table
WITH
UserItem AS (
    SELECT email, postalCode, first_name, last_name, nick_name, itemID, title, description, game_condition
	  FROM User
    JOIN Item ON User.email = Item.ownerEmail),
MySwapRecord AS (
    SELECT recordID, PUserItem.email AS proposerEmail, CUserItem.email AS counterpartyEmail, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate, PUserItem.title AS Ptitle, CUserItem.title AS Ctitle, PUserItem.nick_name AS Pnick_name, CUserItem.nick_name AS Cnick_name
	  FROM SwapRecord
    JOIN UserItem AS PUserItem ON SwapRecord.proposedItemID = PUserItem.itemID
	  JOIN UserItem AS CUserItem ON SwapRecord.desiredItemID = CUserItem.itemID
    WHERE (PUserItem.email = @UserID2 OR CUserItem.email = @UserID2) AND status IS NOT NULL)
SELECT  CASE WHEN proposerEmail = @UserID2 THEN "Proposer"
             WHEN counterpartyEmail = @UserID2 THEN "Counterparty"
        END AS "My role", COUNT(*) AS Total, sum(status) AS Accepted, sum(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS Rejected,
        sum(CASE WHEN status = 0 THEN 1 ELSE 0 END) / count(*) AS "Rejected %"
FROM MySwapRecord
GROUP BY CASE WHEN proposerEmail = @UserID2 THEN "Proposer"
              WHEN counterpartyEmail = @UserID2 THEN "Counterparty"
END;


-- change rating: when user is the counterparty
UPDATE  SwapRecord
SET counterparty_rate = @Rating
WHERE recordID = @RecordID;
-- change rating: when user is the proposer
UPDATE  SwapRecord
SET     proposer_rate = @Rating
WHERE   recordID = @RecordID;
