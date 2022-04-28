--1--
WITH RECURSIVE cities AS 
(

SELECT destination_station_name,1 AS depth
FROM train_info
WHERE source_station_name='KURLA' AND train_no=97131

UNION 

SELECT train_info.destination_station_name,depth+1
FROM train_info,cities
WHERE source_station_name=cities.destination_station_name AND depth<=2
)
SELECT DISTINCT destination_station_name FROM cities ORDER BY destination_station_name;

--2--

WITH RECURSIVE cities AS 
(

SELECT destination_station_name,1 AS depth,day_of_arrival,day_of_departure
FROM train_info
WHERE source_station_name='KURLA' AND train_no=97131 AND day_of_arrival=day_of_departure

UNION 

SELECT train_info.destination_station_name,depth+1,train_info.day_of_arrival,train_info.day_of_departure
FROM train_info,cities
WHERE source_station_name=cities.destination_station_name AND depth<=2 AND train_info.day_of_arrival=cities.day_of_departure AND train_info.day_of_arrival=train_info.day_of_departure
)
SELECT destination_station_name FROM cities ORDER BY destination_station_name;


--3--

WITH RECURSIVE cities AS 
(

SELECT destination_station_name,1 AS depth,day_of_arrival,day_of_departure,train_info.distance
FROM train_info
WHERE source_station_name='DADAR' AND day_of_arrival=day_of_departure

UNION 

SELECT train_info.destination_station_name,depth+1,train_info.day_of_arrival,train_info.day_of_departure,train_info.distance+cities.distance
FROM train_info,cities
WHERE source_station_name=cities.destination_station_name AND depth<=2 AND train_info.day_of_arrival=cities.day_of_departure AND train_info.day_of_arrival=train_info.day_of_departure
)
SELECT DISTINCT destination_station_name,cities.distance AS distance,day_of_arrival AS day
FROM cities 
WHERE destination_station_name<>'DADAR'
ORDER BY destination_station_name;

--4--





--5--

SELECT SUM(ct1) AS count

FROM(


SELECT COUNT(destination_station_name) AS ct1
FROM train_info
WHERE train_info.source_station_name='CST-MUMBAI' AND destination_station_name='VASHI'

UNION

SELECT COUNT(train_1.destination_station_name) AS ct1
FROM train_info,train_info AS train_1
WHERE train_info.source_station_name='CST-MUMBAI' AND train_info.destination_station_name=train_1.source_station_name
AND train_info.destination_station_name<>'VASHI' AND train_1.destination_station_name='VASHI' 

UNION

SELECT COUNT(train_2.destination_station_name) AS ct1
FROM train_info,train_info AS train_1,train_info AS train_2
WHERE train_info.source_station_name='CST-MUMBAI' AND train_info.destination_station_name=train_1.source_station_name
AND train_info.destination_station_name<>'VASHI' AND train_1.destination_station_name=train_2.source_station_name 
AND train_1.destination_station_name<>'CST-MUMBAI'AND train_2.destination_station_name='VASHI'

) AS Table1;

--6--









--7--


WITH RECURSIVE cities AS 
(

SELECT source_station_name,destination_station_name,1 AS depth
FROM train_info


UNION 

SELECT cities.destination_station_name as source_station_name,train_info.destination_station_name,depth+1
FROM cities,train_info
WHERE train_info.source_station_name=cities.destination_station_name AND depth<=3
)

SELECT DISTINCT source_station_name, destination_station_name
FROM cities
ORDER BY source_station_name,destination_station_name;


--8--

WITH RECURSIVE cities AS 
(

SELECT destination_station_name,1 AS depth,day_of_arrival,day_of_departure
FROM train_info
WHERE source_station_name='SHIVAJINAGAR' AND day_of_arrival=day_of_departure

UNION 

SELECT train_info.destination_station_name,depth+1,train_info.day_of_arrival,train_info.day_of_departure
FROM train_info,cities
WHERE source_station_name=cities.destination_station_name AND train_info.day_of_arrival=cities.day_of_departure AND train_info.day_of_arrival=train_info.day_of_departure
)
SELECT destination_station_name,day_of_arrival AS day FROM cities ORDER BY destination_station_name;



--9--


WITH RECURSIVE cities AS 
(

SELECT source_station_name,destination_station_name,1 AS depth,day_of_arrival,day_of_departure,distance
FROM train_info
WHERE source_station_name='LONAVLA'  AND day_of_arrival=day_of_departure


UNION 

SELECT cities.destination_station_name as source_station_name,train_info.destination_station_name,depth+1,train_info.day_of_arrival,train_info.day_of_departure,
cities.distance+train_info.distance
FROM cities,train_info
WHERE train_info.source_station_name=cities.destination_station_name AND cities.source_station_name<>train_info.destination_station_name AND train_info.day_of_arrival=cities.day_of_departure AND
 train_info.day_of_arrival=train_info.day_of_departure
)



SELECT destination_station_name,MIN(distance) AS distance,day_of_arrival AS day
FROM cities
GROUP BY destination_station_name,day_of_arrival
ORDER BY distance,destination_station_name;




--10--






--11--
WITH RECURSIVE cities AS 
(

SELECT source_station_name,destination_station_name,1 AS depth
FROM train_info


UNION 

SELECT cities.destination_station_name as source_station_name,train_info.destination_station_name,depth+1
FROM cities,train_info
WHERE train_info.source_station_name=cities.destination_station_name AND depth<=1 
)

SELECT Table1.source_station_name

FROM(

(

SELECT COUNT(Names) AS count

FROM(
    
SELECT DISTINCT destination_station_name AS Names
FROM cities

UNION 

SELECT DISTINCT source_station_name AS Names
FROM cities) AS C
) AS T1

INNER JOIN 

(SELECT cities.source_station_name,COUNT(DISTINCT destination_station_name) AS count
FROM cities
GROUP BY cities.source_station_name) AS T2

ON T1.count=T2.count


) AS Table1 


ORDER BY source_station_name;

--12--

SELECT DISTINCT teams.name AS teamnames
FROM teams,games,
(SELECT games.awayteamid,teams.name
FROM games,teams
WHERE teams.teamid=games.awayteamid AND games.hometeamid=
(SELECT teamid FROM teams WHERE name='Arsenal')) AS Table1

WHERE Table1.awayteamid=games.awayteamid AND games.hometeamid=teams.teamid AND teams.name<>'Arsenal'

ORDER BY teams.name;


--13--

SELECT name AS teamnames,goals,year

FROM(


(SELECT teams.teamid,teams.name,games.year
FROM teams,games,
(SELECT games.awayteamid,teams.name
FROM games,teams
WHERE teams.teamid=games.awayteamid AND games.hometeamid=
(SELECT teamid FROM teams WHERE name='Arsenal')) AS Table1
WHERE Table1.awayteamid=games.awayteamid AND games.hometeamid=teams.teamid AND teams.name<>'Arsenal') AS Table11

INNER JOIN 

(SELECT T1.ID AS ID ,T1.goals+T2.goals AS goals
FROM(
    SELECT SUM(homegoals) AS goals,hometeamid AS ID FROM games GROUP BY hometeamid
) AS T1,
(
SELECT SUM(awaygoals) AS goals,awayteamid AS ID FROM games GROUP BY awayteamid

) AS T2

WHERE T1.ID=T2.ID) AS Table22

ON

Table11.teamid=Table22.ID

) AS Tablef



ORDER BY goals DESC,year
LIMIT 1;


--14--

SELECT teams.name AS teamnames, games.homegoals-games.awaygoals AS goaldiff

FROM (SELECT DISTINCT teams.teamid
FROM teams,games,
(SELECT games.awayteamid,teams.name
FROM games,teams
WHERE teams.teamid=games.awayteamid AND games.hometeamid=
(SELECT teamid FROM teams WHERE name='Leicester')) AS Table1

WHERE Table1.awayteamid=games.awayteamid AND games.hometeamid=teams.teamid AND teams.name<>'Leicester') AS Table2,games,teams

WHERE teams.teamid=Table2.teamid AND Table2.teamid=games.hometeamid AND games.year=2015 AND games.homegoals-games.awaygoals>3

ORDER BY goaldiff,name;



--15--

SELECT name AS playernames,goals

FROM
(

(SELECT name AS name1,SUM(goals) AS goals1
FROM 

    (

        (SELECT DISTINCT games.gameid

        FROM games,

       

        (SELECT DISTINCT teams.teamid,games.gameid
        FROM teams,games,
        (SELECT games.awayteamid,teams.name
        FROM games,teams
        WHERE teams.teamid=games.awayteamid AND games.hometeamid=
        (SELECT teamid FROM teams WHERE name='Valencia')) AS Table1

        WHERE Table1.awayteamid=games.awayteamid AND games.hometeamid=teams.teamid AND teams.name<>'Valencia') AS Table0

          WHERE (games.hometeamid=Table0.teamid)) AS Table11

        



INNER JOIN 


(SELECT SUM(goals) AS goals,gameid,name FROM appearances,players WHERE players.playerid=appearances.playerid GROUP BY appearances.playerid,gameid,name)
 AS Table22


ON 

Table11.gameid=Table22.gameid

)

AS Tablef

GROUP BY name1
ORDER BY goals1 DESC,name1
) AS T1

INNER JOIN 

(SELECT name AS name,SUM(goals) AS goals
FROM 

    (

        (SELECT DISTINCT games.gameid

        FROM games,

       

        (SELECT DISTINCT teams.teamid,games.gameid
        FROM teams,games,
        (SELECT games.awayteamid,teams.name
        FROM games,teams
        WHERE teams.teamid=games.awayteamid AND games.hometeamid=
        (SELECT teamid FROM teams WHERE name='Valencia')) AS Table1

        WHERE Table1.awayteamid=games.awayteamid AND games.hometeamid=teams.teamid AND teams.name<>'Valencia') AS Table0

          WHERE (games.hometeamid=Table0.teamid)) AS Table11

        



INNER JOIN 


(SELECT SUM(goals) AS goals,gameid,name FROM appearances,players WHERE players.playerid=appearances.playerid GROUP BY appearances.playerid,gameid,name)
 AS Table22


ON 

Table11.gameid=Table22.gameid

)

AS Tablef

GROUP BY name
ORDER BY goals DESC,name
LIMIT 1) AS T2

ON T1.goals1=T2.goals
) AS T3

ORDER BY goals DESC,name;





--16--
SELECT name AS playernames,assists AS assistscount

FROM 
(

(SELECT name AS name,SUM(assists) AS assists
FROM 

    (

        (SELECT DISTINCT games.gameid

        FROM games,

        (SELECT DISTINCT teams.teamid,games.gameid
        FROM teams,games,
        (SELECT games.awayteamid,teams.name
        FROM games,teams
        WHERE teams.teamid=games.awayteamid AND games.hometeamid=
        (SELECT teamid FROM teams WHERE name='Everton')) AS Table1

        WHERE Table1.awayteamid=games.awayteamid AND games.hometeamid=teams.teamid AND teams.name<>'Everton') AS Table0

        WHERE (games.hometeamid=Table0.teamid)) AS Table11



INNER JOIN 


(SELECT SUM(assists) AS assists,gameid,name FROM appearances,players WHERE players.playerid=appearances.playerid GROUP BY appearances.playerid,gameid,name)
 AS Table22


ON 

Table11.gameid=Table22.gameid

)

AS Tablef

GROUP BY name
ORDER BY assists DESC,name
) AS T1 

INNER JOIN 

(
    SELECT name AS name1,SUM(assists) AS assists1
FROM 

    (

        (SELECT DISTINCT games.gameid

        FROM games,

        (SELECT DISTINCT teams.teamid,games.gameid
        FROM teams,games,
        (SELECT games.awayteamid,teams.name
        FROM games,teams
        WHERE teams.teamid=games.awayteamid AND games.hometeamid=
        (SELECT teamid FROM teams WHERE name='Everton')) AS Table1

        WHERE Table1.awayteamid=games.awayteamid AND games.hometeamid=teams.teamid AND teams.name<>'Everton') AS Table0

        WHERE (games.hometeamid=Table0.teamid)) AS Table11



INNER JOIN 


(SELECT SUM(assists) AS assists,gameid,name FROM appearances,players WHERE players.playerid=appearances.playerid GROUP BY appearances.playerid,gameid,name)
 AS Table22


ON 

Table11.gameid=Table22.gameid

)

AS Tablef

GROUP BY name1
ORDER BY assists1 DESC,name1
LIMIT 1
) AS T2

ON T1.name=T2.name1
)

ORDER BY assists DESC,name;



--17--

SELECT name AS playernames,shots AS shotscount

FROM 
(

(
    SELECT name AS name1,SUM(shots) AS shots1
FROM 

    (

        (SELECT DISTINCT games.gameid

        FROM games,

        (SELECT DISTINCT teams.teamid,games.gameid
        FROM teams,games,
        (SELECT games.hometeamid,teams.name
        FROM games,teams
        WHERE teams.teamid=games.hometeamid AND games.awayteamid=
        (SELECT teamid FROM teams WHERE name='AC Milan')) AS Table1

        WHERE Table1.hometeamid=games.hometeamid AND games.awayteamid=teams.teamid  AND teams.name<>'AC Milan' AND games.year=2016) AS Table0

        WHERE (games.awayteamid=Table0.teamid) AND games.year=2016) AS Table11



INNER JOIN 


(SELECT SUM(shots) AS shots,gameid,name FROM appearances,players WHERE players.playerid=appearances.playerid GROUP BY appearances.playerid,gameid,name)
 AS Table22


ON 

Table11.gameid=Table22.gameid

)

AS Tablef

GROUP BY name1
ORDER BY shots1 DESC,name1
LIMIT 1
) AS T1

INNER JOIN 

(
    SELECT name AS name,SUM(shots) AS shots
FROM 

    (

        (SELECT DISTINCT games.gameid

        FROM games,

        (SELECT DISTINCT teams.teamid,games.gameid
        FROM teams,games,
        (SELECT games.hometeamid,teams.name
        FROM games,teams
        WHERE teams.teamid=games.hometeamid AND games.awayteamid=
        (SELECT teamid FROM teams WHERE name='AC Milan')) AS Table1

        WHERE Table1.hometeamid=games.hometeamid AND games.awayteamid=teams.teamid  AND teams.name<>'AC Milan' AND games.year=2016) AS Table0

        WHERE (games.awayteamid=Table0.teamid) AND games.year=2016) AS Table11



INNER JOIN 


(SELECT SUM(shots) AS shots,gameid,name FROM appearances,players WHERE players.playerid=appearances.playerid GROUP BY appearances.playerid,gameid,name)
 AS Table22


ON 

Table11.gameid=Table22.gameid

)

AS Tablef

GROUP BY name
ORDER BY shots DESC,name) AS T2

ON T1.shots1=T2.shots

)

ORDER BY shots DESC,name;




--18--

SELECT *

FROM(

SELECT DISTINCT teams.name AS teamname,year

FROM (SELECT DISTINCT teams.teamid
FROM teams,games,
(SELECT games.awayteamid,teams.name
FROM games,teams
WHERE teams.teamid=games.awayteamid AND games.hometeamid=
(SELECT teamid FROM teams WHERE name='AC Milan')) AS Table1

WHERE Table1.awayteamid=games.awayteamid AND games.hometeamid=teams.teamid AND teams.name<>'AC Milan'

) AS Table2,games,teams,

(SELECT teams.teamid,SUM(games.awaygoals) AS S FROM teams,games WHERE teams.teamid=games.awayteamid GROUP BY teams.teamid) AS Table3


WHERE teams.teamid=Table2.teamid AND Table2.teamid=games.hometeamid AND games.year=2020 AND Table3.teamid=teams.teamid AND Table3.S=0


UNION


SELECT DISTINCT teams.name AS teamname,year

FROM (SELECT DISTINCT teams.teamid
FROM teams,games,
(SELECT games.hometeamid,teams.name
FROM games,teams
WHERE teams.teamid=games.hometeamid AND games.awayteamid=
(SELECT teamid FROM teams WHERE name='AC Milan')) AS Table1

WHERE Table1.hometeamid=games.hometeamid AND games.awayteamid=teams.teamid AND teams.name<>'AC Milan'

) AS Table2,games,teams,

(SELECT teams.teamid,SUM(games.awaygoals) AS S FROM teams,games WHERE teams.teamid=games.awayteamid GROUP BY teams.teamid) AS Table3


WHERE teams.teamid=Table2.teamid AND Table2.teamid=games.hometeamid AND games.year=2020 AND Table3.teamid=teams.teamid AND Table3.S=0

) AS Tablef





ORDER BY teamname
LIMIT 5;



--19--

--20--

--21--

--22--



