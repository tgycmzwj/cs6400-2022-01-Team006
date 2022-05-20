SELECT itemID, game_type, title, game_condition 
FROM Item
WHERE ownerEmail = "user11@gmail.com" AND 
		(itemID NOT IN (SELECT proposedItemID 
                        FROM SwapRecord
                        WHERE status = 1 or status IS NULL)) AND 
		(itemID NOT IN (SELECT desiredItemID
                    FROM SwapRecord
                    WHERE status = 1 or status IS NULL));

-- Show items as radio check box
-- When user click Confirm button
    -- If check box is selected:
        -- If exists:
            SELECT COUNT(*)  
            FROM SwapRecord
            WHERE proposedItemID = itemID AND desiredItemID = "$itemID"; 
            -- Return error message “You cannot send the same swap request that was
            -- rejected before again”
        -- Else: 
            INSERT  INTO    SwapRecord (proposerEmail, counterpartyEmail, proposedItemID, 
                                        desiredItemID, status, propose_date, decide_date, 
                                        proposer_rate, counterparty_rate)
                    VALUES  (NULL, itemID, "$itemID", NULL, CURRENT_DATE, NULL, NULL, NULL);
    -- Else:
        -- Display error message “Please select an item to swap”



-- Accept/Reject Swaps
    -- Upon user click Unaccepted swaps
    -- Query swap_record in Swap_Record where swap_record.Counterparty=”$UserID” and
    -- swap_record.Status=”Pending”
    -- Query user in User where swap_record.Proposer=user.Email, calculate distance based on
    -- location where location.Postal_Code=user.Locate

        WITH UserItem AS (SELECT    email, postalCode, nick_name, itemID, title
                            FROM    User
                            JOIN    Item
                            ON      User.email = Item.ownerEmail)
        SELECT  SwapRecord.recordID, SwapRecord.propose_date AS Date, CUserItem.title AS "Desired Item", 
                PUserItem.nick_name AS "Proposer", SwapRecord.proposer_rate AS "Rating",
                cal_dist(PUserItem.postalCode, CUserItem.postalCode) AS Distance, 
                PUserItem.title AS "Proposed Item"
        FROM    SwapRecord
        JOIN    UserItem AS CUserItem
        ON      SwapRecord.desiredItemID = CUserItem.itemID
        JOIN    UserItem AS PUserItem
        ON      SwapRecord.proposedItemID = PUserItem.itemID
        WHERE   SwapRecord.status IS NULL
        ORDER BY SwapRecord.propose_date;
        -- *** return recordID for updating SwapRecored later ***
        
    -- Show swap_record and Accept and Reject buttons
    -- If user click Accept button
        -- Change swap_record.Status to “Accepted”, swap_record.Decide_Date to current date
            UPDATE  SwapRecord
            SET     status = 1, decide_date = CURRENT_DATE
            WHERE   recordID = "$recordID";
        -- Return contact information for swap proposer by query user in User where user.Email=swap_record.Proposer
            WITH UserItemPhone AS (SELECT   email, first_name, phone_number, phone_type, itemID
                                    FROM    User
                                    JOIN    Item
                                    ON      User.email = Item.ownerEmail
                                    JOIN    Phone
                                    ON      User.email = Phone.ownerEmail)
            SELECT  email, first_name, phone_number, phone_type
            FROM    UserItemPhone
            JOIN    (Select proposedItemID 
                    FROM    SwapRecord
                    WHERE   recordID = "$recordID") AS t1
            ON      UserItemPhone.itemID = t1.proposedItemID;
    -- If user click Reject button
        -- Change swap_record.Status to “Rejected”, swap_record.Decide_Date to current date
            UPDATE  SwapRecord
            SET     status = 0, decide_date = CURRENT_DATE
            WHERE   recordID = "$recordID";



-- Swap History
-- Upon user click Swap history button
-- Query swap_record in Swap_Record where (swap_record.Counterparty=”$UserID” or swap_record.Proposer=”$UserID”) and (swap_record.Status!=”Pending”)
-- If swap_record.Status=”Accepted” and ((swap_record.Counterparty=”$UserID” and
-- swap_record.Counterparty_Rate is NULL) or ((swap_record.Proposer=”$UserID” and
-- swap_record.Proposer_Rate is NULL)):
    -- Show rating check box
        WITH UserItem AS (SELECT    email, postalCode, first_name, last_name, nick_name, itemID, title, game_type, description, game_condition
                            FROM    User
                            JOIN    Item
                            ON      User.email = Item.ownerEmail),
			MySwapRecord AS (SELECT    recordID, PUserItem.email AS proposerEmail, CUserItem.email AS counterpartyEmail, 
                                        proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, 
                                        counterparty_rate, PUserItem.title, CUserItem.title, PUserItem.nick_name, CUserItem.nick_name
                                FROM    SwapRecord
                                JOIN    UserItem AS PUserItem
                                ON      SwapRecord.proposedItemID = PUserItem.itemID
                                JOIN    UserItem AS CUserItem
                                ON      SwapRecord.desiredItemID = CUserItem.itemID
                                WHERE   (PUserItem.email = "$Email" OR CUserItem.email = "$Email") AND status IS NOT NULL)
        SELECT  propose_date AS "Proposed Date", decide_date AS "Accepted/Rejected Date", status AS "Swap Status",       
                CASE 
                    WHEN MySwapRecord.proposerEmail = "$Email" THEN "Proposer"
                    WHEN MySwapRecord.counterpartyEmail = "$Email" THEN "Counterparty"
                END AS "My Role",
                PUserItem.title AS "Proposed Item", CUserItem.title AS "Desired Item", 
                CASE
                    WHEN MySwapRecord.proposerEmail != "$Email" THEN PUserItem.nick_name
                    WHEN MySwapRecord.counterpartyEmail != "$Email" THEN CUserItem.nick_name
                END AS "Other User",
                CASE
                    WHEN (status = 1) AND MySwapRecord.proposerEmail = "$Email" THEN
                        CASE 
                            WHEN proposer_rate IS NOT NULL THEN proposer_rate
                            WHEN proposer_rate IS NULL THEN "$Rating"
                        END
                    WHEN (status = 1) AND MySwapRecord.counterpartyEmail = "Email" THEN
                        CASE 
                            WHEN counterparty_rate IS NOT NULL THEN counterparty_rate
                            WHEN counterparty_rate IS NULL THEN "$Rating"
                        END
                END AS "Rating"
        FROM    MySwapRecord
        ORDER BY decide_date DESC, propose_date;

-- Count swap_record where swap_record.Counterparty==”$UserID”
    -- Count swap_record where swap_record.Counterparty==”$UserID” and swap_record.Status=”Accepted” or “Completed”
    -- Calculate rate of rejection and change background color according to this rate
-- Count swap_record where swap_record.Proposer==”$UserID”
    -- Count swap_record where swap_record.Proposer==”$UserID” and swap_record.Status=”Accepted” or “Completed”
    -- Calculate rate of rejection and change background color according to this rate
        -- *** Use above MySwapRecord table ***
        SELECT  CASE
                    WHEN proposerEmail = "$Email" THEN "Proposer"
                    WHEN counterpartyEmail = "$Email" THEN "Counterparty"
                END AS "My role",
                COUNT(*) AS Total, sum(status) AS Accepted, sum(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS Rejected, 
                sum(CASE WHEN status = 0 THEN 1 ELSE 0 END) / count(*) AS "Rejected %"
        FROM    MySwapRecord
        GROUP BY    CASE
                        WHEN proposerEmail = "$Email" THEN "Proposer"
                        WHEN counterpartyEmail = "$Email" THEN "Counterparty"
                    END;

-- If swap_record.Status=”Accepted” and swap_record.Counterparty=”$UserID” and swap_record.Counterparty_Rate is NULL:
    -- When user select rating
        -- Change swap_record.Counterparty_Rate=“$Rating”
            UPDATE  SwapRecord
            SET     counterparty_rate = "$Rating"
            WHERE   recordID = "$recordID";

-- If swap_record.Status=”Accepted” and swap_record.Proposer=”$UserID” and swap_record.Proposer_Rate is NULL:
    -- When user select rating
        -- Change swap_record.Proposer_Rate=“$Rating”
            UPDATE  SwapRecord
            SET     proposer_rate = "$Rating"
            WHERE   recordID = "$recordID";



-- Rate Swap
-- Upon user click Unrated swaps link 
-- Query swap_record in Swap_Record where (swap_record.Counterparty=”$UserID” and
-- swap_record.status==”Accepted” and swap_record.Counterparty_Rate=NULL) or
-- (swap_record.Proposer=”$UserID” and swap_record.Status==”Accepted” and
-- swap_record.Proposer=NULL)
    WITH UserItem AS (SELECT    email, postalCode, first_name, last_name, nick_name, itemID, title, game_type, description, game_condition
                                FROM    User
                                JOIN    Item
                                ON      User.email = Item.ownerEmail),
		 MySwapRecord AS (SELECT    recordID, PUserItem.email AS proposerEmail, CUserItem.email AS counterpartyEmail, 
                                    proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, 
                                    counterparty_rate, PUserItem.title, CUserItem.title, PUserItem.nick_name, CUserItem.nick_name
                            FROM    SwapRecord
                            JOIN    UserItem AS PUserItem
                            ON      SwapRecord.proposedItemID = PUserItem.itemID
                            JOIN    UserItem AS CUserItem
                            ON      SwapRecord.desiredItemID = CUserItem.itemID
                            WHERE   (PUserItem.email = "$Email" OR CUserItem.email = "$Email") AND status IS NOT NULL)
    SELECT  decide_date AS "Accepted/Rejected Date",       
            CASE 
                WHEN MySwapRecord.proposerEmail = "$Email" THEN "Proposer"
                WHEN MySwapRecord.counterpartyEmail = "$Email" THEN "Counterparty"
            END AS "My Role",
            PUserItem.title AS "Proposed Item", CUserItem.title AS "Desired Item", 
            CASE
                WHEN MySwapRecord.proposerEmail != "$Email" THEN PUserItem.nick_name
                WHEN MySwapRecord.counterpartyEmail != "$Email" THEN CUserItem.nick_name
            END AS "Other User",
            CASE
                WHEN MySwapRecord.proposerEmail = "$Email" AND proposer_rate IS NULL THEN "$Rating"                       
                WHEN MySwapRecord.counterpartyEmail = "Email" AND counterparty_rate IS NULL THEN "$Rating"
            END AS "Rating"
    FROM    MySwapRecord
    WHERE   status = 1
    ORDER BY decide_date DESC;

-- While number of query results is greater than 0
    -- Show unrated swaps and rating dropdown menu
    -- If user select “$Rate”
        -- If swap_record.Counterparty=”$UserID”
            -- Change swap_record.Counterparty_Rate=”$Rate”
                UPDATE  SwapRecord
                SET     counterparty_rate = "$Rating"
                WHERE   recordID = "$recordID";
        -- Else
            -- Change swap_record.Proposer_Rate=”$Rate”
                UPDATE  SwapRecord
                SET     proposer_rate = "$Rating"
                WHERE   recordID = "$recordID";

    -- (*** Repeat above steps ***) Query swap_record in Swap_Record where (swap_record.Counterparty=”$UserID” and
    -- swap_record.status==”Accepted” and swap_record.Counterparty_Rate=NULL) or
    -- (swap_record.Proposer=”$UserID” and swap_record.Status==”Accepted” and
    -- swap_record.Proposer=NULL)

-- Return to main menu



-- Swap Details
-- Upon user click Detail button in swap history form
-- query swap_record in Swap_Record
-- query item in Item for swap_record.Proposed_Item and swap_record.Desired_Item
-- query user in User for (swap_record.Proposer and swap_record.Counterparty) and (user.Email!=”$UserID”)
    WITH TargetSwapRecord AS (SELECT    recordID, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate
                                FROM    SwapRecord
                                WHERE   recordID = "$recordID"),
		 UserItemPhone AS  (SELECT  email, postalCode, first_name, last_name, nick_name, phone_number, phone_type
                                    itemID, title, game_type, description, game_condition
                            FROM    User
                            JOIN    Item
                            ON      User.email = Item.ownerEmail
                            JOIN    Phone
                            ON      User.email = Phone.ownerEmail),
		 TargetSwapAllInfo AS (SELECT   recordID, PUserItemPhone.email AS proposerEmail, CUserItemPhone.email AS counterpartyEmail, 
                                        proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, 
                                        counterparty_rate, PUserItemPhone.title, CUserItemPhone.title, 
                                        PUserItemPhone.game_type, CUserItemPhone.game_type,
                                        PUserItemPhone.game_condition, CUserItemPhone.game_condition,
                                        PUserItemPhone.description, PUserItemPhone.nick_name, CUserItemPhone.nick_name, 
                                        PUserItemPhone.postalCode, CUserItemPhone.postalCode, PUserItemPhone.phone_number, 
                                        CUserItemPhone.phone_number, PUserItemPhone.phone_type, CUserItemPhone.phone_type
                                FROM    TargetSwapRecord
                                JOIN    UserItemPhone AS PUserItemPhone
                                ON      TargetSwapRecord.proposedItemID = PUserItemPhone.itemID
                                JOIN    UserItemPhone AS CUserItemPhone
                                ON      TargetSwapRecord.desiredItemID = CUserItemPhone.itemID)
-- *** TargetSwapAllInfo contains all the required information in Swap Details form ("distance"
-- *** can be calculated with PUserItemPhone.postalCode and CUserItemPhone.postalCode).
-- *** The following quiries are for displaying the information, which may also be accomplished 
-- *** by the frontend programming language.

-- Display Swap Details
    SELECT  propose_date AS Proposed, decide_date AS "Accepted/Rejected", status AS Status,
            CASE 
                WHEN TargetSwapAllInfo.proposerEmail = "$Email" THEN "Proposer"
                WHEN TargetSwapAllInfo.counterpartyEmail = "$Email" THEN "Counterparty"
            END AS "My Role", 
            CASE 
                WHEN TargetSwapAllInfo.proposerEmail = "$Email" THEN 
                    CASE
                        WHEN proposer_rate IS NOT NULL THEN proposer_rate
                        Else "$Rating"
                    END
                WHEN TargetSwapAllInfo.counterpartyEmail = "$Email" THEN 
                    CASE
                        WHEN counterparty_rate IS NOT NULL THEN counterparty_rate
                        Else "$Rating"
                    END      
            END AS "Rating left"
    FROM    TargetSwapAllInfo;

-- Display Other User details
    SELECT  CASE
                WHEN proposerEmail = "$userEmail" THEN CUserItem.nick_name
                WHEN counterpartyEmail = "$userEmail" THEN PUserItem.nick_name
            END AS "Nickname",
            cal_dist(PUserItem.postalCode, CUserItem.postalCode) AS Distance,
            CASE
                WHEN status = 1 THEN
                    CASE 
                        WHEN proposerEmail = "$userEmail" THEN CUserItem.first_name
                        WHEN counterpartyEmail = "$userEmail" THEN PUserItem.first_name
                    END
                ELSE NULL
            END AS "Name",
            CASE
                WHEN status = 1 THEN
                    CASE 
                        WHEN proposerEmail = "$userEmail" THEN CUserItem.email
                        WHEN counterpartyEmail = "$userEmail" THEN PUserItem.email
                    END
                ELSE NULL
            END AS "Email",
            CASE
                WHEN status = 1 THEN
                    CASE 
                        WHEN proposerEmail = "$userEmail" THEN CUserItem.phone_number
                        WHEN counterpartyEmail = "$userEmail" THEN PUserItem.phone_number
                    END
                ELSE NULL
            END AS "Phone Number",
			CASE
                WHEN status = 1 THEN
                    CASE 
                        WHEN proposerEmail = "$userEmail" THEN CUserItem.phone_type
                        WHEN counterpartyEmail = "$userEmail" THEN PUserItem.phone_type
                    END
                ELSE NULL
            END AS "Phone Type"
    FROM    TargetSwapAllInfo;

    -- Display Proposed Item
    SELECT  proposedItemID AS "Item #", PUserItemPhone.title AS "Title", PUserItemPhone.game_type AS "Game type",
            PUserItemPhone.game_condition AS "Condition", PUserItemPhone.description AS "Description"
    FROM    TargetSwapAllInfo;

    -- Display Desired Item
    SELECT  desiredItemID AS "Item #", CUserItemPhone.title AS "Title", CUserItemPhone.game_type AS "Game type",
            CUserItemPhone.game_condition AS "Condition"
    FROM    TargetSwapAllInfo;