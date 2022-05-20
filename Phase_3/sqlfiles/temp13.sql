SELECT *
FROM gameswapDB.SwapRecord NATURAL JOIN (
     SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
     FROM gameswapDB.Item
     ) AS M;
     
	
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
    WHERE (PUserItem.email = "{}" OR CUserItem.email = "{}") AND status IS NOT NULL)
SELECT  CASE WHEN proposerEmail = "{}" THEN "Proposer"
             WHEN counterpartyEmail = "{}" THEN "Counterparty"
        END AS "My role", COUNT(*) AS Total, sum(status) AS Accepted, sum(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS Rejected,
        sum(CASE WHEN status = 0 THEN 1 ELSE 0 END) / count(*) AS "Rejected %"
FROM MySwapRecord
GROUP BY CASE WHEN proposerEmail = "{}" THEN "Proposer"
              WHEN counterpartyEmail = "{}" THEN "Counterparty"
END;