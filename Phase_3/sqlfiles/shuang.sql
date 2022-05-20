-- queries used for searching
USE gameswapDB;

-- run the query to get $current_user_postal_code
SELECT User.postalCode AS 'current_user_postal_code'
FROM User
WHERE User.email = '$Email';


-- queries used for searching by keyword
SELECT Item.itemID                                            AS 'Item',
       Item.Game_Type                                         AS 'Game type',
       Item.Title                                             AS 'Title',
       Item.game_condition                                    AS 'Condition',
       Item.Description                                       AS 'Description',
       cal_dist('$current_user_postal_code', User.postalCode) AS 'Distance'
FROM Item
         INNER JOIN User
                    ON User.Email = Item.ownerEmail
WHERE User.Email != '$Email'
  AND (Item.Description LIKE '%$keyword%' OR Item.Title LIKE '%$keyword%')
ORDER BY Distance ASC, Item.itemID ASC;


-- queries used for searching in my postal code

SELECT Item.itemID                                            AS 'Item',
       Item.Game_Type                                         AS 'Game type',
       Item.Title                                             AS 'Title',
       Item.game_condition                                    AS 'Condition',
       Item.Description                                       AS 'Description',
       cal_dist('$current_user_postal_code', User.postalCode) AS 'Distance'
FROM Item
         INNER JOIN User
                    ON User.Email = Item.ownerEmail
WHERE User.postalCode = '$current_user_postal_code'
  AND User.Email != '$Email'
ORDER BY Distance ASC, Item.itemID ASC;

-- queries used for searching in the postal code of $target_postal_code

SELECT Item.itemID                                            AS 'Item',
       Item.Game_Type                                         AS 'Game type',
       Item.Title                                             AS 'Title',
       Item.game_condition                                    AS 'Condition',
       Item.Description                                       AS 'Description',
       cal_dist('$current_user_postal_code', User.postalCode) AS 'Distance'
FROM Item
         INNER JOIN User
                    ON User.Email = Item.ownerEmail
WHERE User.postalCode = '$target_postal_code'
  AND User.Email != '$Email'
ORDER BY Distance ASC, Item.itemID ASC;


-- queries used for searching within $x_miles miles of me:

SELECT Item.itemID                                            AS 'Item',
       Item.Game_Type                                         AS 'Game type',
       Item.Title                                             AS 'Title',
       Item.game_condition                                    AS 'Condition',
       Item.Description                                       AS 'Description',
       cal_dist('$current_user_postal_code', User.postalCode) AS 'Distance'
FROM Item
         INNER JOIN User
                    ON User.Email = Item.ownerEmail
WHERE User.postalCode IN (
    SELECT User.postalCode
    FROM User
             INNER JOIN Item
                        ON User.Email = Item.ownerEmail
    WHERE cal_dist('$current_user_postal_code', User.postalCode) <= '$x_miles'
)
  AND User.Email != '$Email'
ORDER BY Distance ASC, Item.itemID ASC;