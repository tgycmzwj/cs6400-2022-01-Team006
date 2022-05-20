-- queries used for registration
USE gameswapDB;
-- define some test cases
SET @Email='user100@gmail.com';
SET @Password='aaaaaaaa';
SET @First_Name='first_name100';
SET @Last_Name='last_name100';
SET @Nick_Name='nick_name100';
SET @Postal_Code='02241';
SET @Phone_Number='0000000100';
SET @Phone_Type='home';
SET @Share_Phone=True;


-- check if the email exists
SELECT COUNT(*)
FROM gameswapDB.User
WHERE User.email=@Email;
-- check if the phone number exists
SELECT COUNT(*)
FROM gameswapDB.Phone
WHERE Phone.phoneNumber=@Phone_Number;
-- check if the postal code is valid
SELECT COUNT(*)
FROM gameswapDB.Location
WHERE Location.postalCode=@Postal_Code;
-- check if city and state are correct
SELECT city, state
FROM gameswapDB.Location
WHERE Location.postalCode=@Postal_Code;
-- insert this new user to User
INSERT INTO gameswapDB.User(
  email,postalCode,password,first_name,last_name,nick_name
)
VALUES
(@Email,@Postal_Code,@Password,@First_Name,@Last_Name,@Nick_Name);
-- insert this new user to Phone
INSERT INTO gameswapDB.Phone(
    phoneNumber,ownerEmail,phone_type,share_phone
)
VALUES
(@Phone_Number,@Email,@Phone_Type,@Share_Phone);
