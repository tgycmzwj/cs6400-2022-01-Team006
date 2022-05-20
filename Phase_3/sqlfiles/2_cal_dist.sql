USE gameswapDB;

DROP FUNCTION IF EXISTS cal_dist;
DELIMITER $$
CREATE FUNCTION cal_dist(
    zip1 CHAR(5),
    zip2 CHAR(5)
) RETURNS float
READS SQL DATA
BEGIN
    DECLARE lat1,lon1,lat2,lon2 FLOAT DEFAULT 0;
	DECLARE delta_lat FLOAT DEFAULT 0;
    DECLARE delta_lon FLOAT DEFAULT 0;
    DECLARE a FLOAT DEFAULT 0;
    DECLARE c FLOAT DEFAULT 0;
    
    SELECT latitude,longitude
    INTO lat1,lon1
    FROM gameswapDB.Location
    WHERE postalCode=zip1;
    
    SELECT latitude,longitude
    INTO lat2,lon2
    FROM gameswapDB.Location
    WHERE postalCode=zip2;
    

    SELECT pi()*lat1/180-pi()*lat2/180 INTO delta_lat;
    SELECT pi()*lon1/180-pi()*lon2/180 INTO delta_lon;
    SELECT power(sin(delta_lat/2),2)+cos(pi()*lat1/180)*cos(pi()*lat2/180)
           *power(sin(delta_lon/2),2) INTO a;
    SELECT 2*atan2(sqrt(a),sqrt(1-a)) INTO c;
    RETURN c*6371;
END$$
DELIMITER ;