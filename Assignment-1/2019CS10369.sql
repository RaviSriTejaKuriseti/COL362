--1--

SELECT Table1.driverid,Table1.forename,Table1.surname,Table1.nationality,Table1.milliseconds AS time

FROM 


(SELECT drivers.driverid,forename,surname,nationality,milliseconds
FROM drivers,laptimes,circuits,races
WHERE laptimes.driverid=drivers.driverid AND laptimes.raceid=races.raceid  AND races.circuitId=circuits.circuitId AND circuits.country='Monaco' AND races.year=2017
ORDER BY laptimes.milliseconds DESC,forename,surname,nationality
LIMIT 1) AS Table1

INNER JOIN 

(SELECT drivers.driverid,forename,surname,nationality,milliseconds
FROM drivers,laptimes,circuits,races
WHERE laptimes.driverid=drivers.driverid AND laptimes.raceid=races.raceid  AND races.circuitId=circuits.circuitId AND circuits.country='Monaco' AND races.year=2017
ORDER BY laptimes.milliseconds DESC,forename,surname,nationality
) AS Table2


ON Table1.milliseconds=Table2.milliseconds;

--2--


SELECT constructors.name AS constructor_name,constructors.constructorid,constructors.nationality,SUM(constructorresults.points) AS Points
FROM constructors,constructorResults,races
WHERE constructors.constructorid=constructorResults.constructorid AND races.raceid=constructorResults.raceid AND races.year=2012
GROUP BY constructors.constructorid
ORDER BY Points DESC,constructors.name,nationality,constructors.constructorid
LIMIT 5;


--3--

SELECT Table1.driverid,Table1.forename,Table1.surname,Table1.Points

FROM 


(SELECT drivers.driverid,forename,surname, SUM(results.points) AS Points
FROM drivers,results,races
WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid AND races.year<=2020 AND races.year>=2001 
GROUP BY drivers.driverid
ORDER BY Points DESC,forename,surname,drivers.driverid
LIMIT 1) AS Table1

INNER JOIN 

(SELECT drivers.driverid,forename,surname, SUM(results.points) AS Points
FROM drivers,results,races
WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid AND races.year<=2020 AND races.year>=2001 
GROUP BY drivers.driverid
ORDER BY Points DESC,forename,surname,drivers.driverid
) AS Table2


ON Table1.Points=Table2.Points;




--4--

SELECT Table1.constructorid,Table1.name,Table1.nationality,Table1.Points

FROM 


(SELECT constructors.name,constructors.constructorid,constructors.nationality,SUM(constructorresults.points) AS Points
FROM constructors,constructorResults,races
WHERE constructors.constructorid=constructorResults.constructorid AND races.raceid=constructorResults.raceid AND races.year<=2020 and races.year>=2010
GROUP BY constructors.constructorid
ORDER BY Points DESC,constructors.name,nationality,constructors.constructorid
LIMIT 1) AS Table1

INNER JOIN 

(SELECT constructors.name,constructors.constructorid,constructors.nationality,SUM(constructorresults.points) AS Points
FROM constructors,constructorResults,races
WHERE constructors.constructorid=constructorResults.constructorid AND races.raceid=constructorResults.raceid AND races.year<=2020 and races.year>=2010
GROUP BY constructors.constructorid
ORDER BY Points DESC,constructors.name,nationality,constructors.constructorid
) AS Table2


ON Table1.Points=Table2.Points;



--5--

SELECT Table1.driverid,Table1.forename,Table1.surname,Table1.race_wins

FROM 


(SELECT drivers.driverid,forename,surname,SUM(results.positionorder) AS race_wins
FROM drivers,results
WHERE drivers.driverid=results.driverid AND results.positionorder=1
GROUP BY drivers.driverid
ORDER BY race_wins DESC,forename,surname,driverid
LIMIT 1
) AS Table1

INNER JOIN 

(SELECT drivers.driverid,forename,surname,SUM(results.positionorder) AS race_wins
FROM drivers,results
WHERE drivers.driverid=results.driverid AND results.positionorder=1
GROUP BY drivers.driverid
ORDER BY race_wins DESC,forename,surname,driverid
) AS Table2


ON Table1.race_wins=Table2.race_wins;



--6--



SELECT Table11.constructorid,Table11.Name,Table11.num_wins

FROM 


(SELECT Table1.constructorid as constructorid,Table1.Name,COUNT(Table1.constructorid) AS num_wins

FROM
(SELECT constructors.constructorid,name,constructorresults.points,DENSE_RANK() OVER (
PARTITION BY raceid ORDER BY constructorresults.points DESC) AS rankings,raceid
FROM constructors,constructorresults
WHERE constructors.constructorid=constructorresults.constructorid
GROUP BY constructors.constructorid,raceid,constructorresults.points
ORDER BY constructorresults.points DESC,name,constructors.constructorid) AS Table1


WHERE Table1.rankings=1
GROUP BY Table1.constructorid,Table1.Name
ORDER BY num_wins DESC,name,Table1.constructorid

LIMIT 1
) AS Table11

INNER JOIN 

(SELECT Table1.constructorid as constructorid,Table1.Name,COUNT(Table1.constructorid) AS num_wins

FROM
(SELECT constructors.constructorid,name,constructorresults.points,DENSE_RANK() OVER (
PARTITION BY raceid ORDER BY constructorresults.points DESC) AS rankings,raceid
FROM constructors,constructorresults
WHERE constructors.constructorid=constructorresults.constructorid
GROUP BY constructors.constructorid,raceid,constructorresults.points
ORDER BY constructorresults.points DESC,name,constructors.constructorid) AS Table1


WHERE Table1.rankings=1
GROUP BY Table1.constructorid,Table1.Name
ORDER BY num_wins DESC,name,Table1.constructorid

) AS Table2


ON Table11.num_wins=Table2.num_wins;


--7--


SELECT drivers.driverid AS driverid , forename,surname,SUM(results.points) AS points
FROM drivers,results
WHERE drivers.driverid=results.driverid AND drivers.driverid NOT IN (

 SELECT drivers.driverid

FROM 

    drivers,(
    SELECT drivers.driverid AS id ,SUM(results.points) AS S,races.year,DENSE_RANK() OVER (
    PARTITION BY races.year ORDER BY SUM(results.points) DESC,drivers.driverid,races.year) AS rankings
    FROM drivers,results,races
    WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid
    GROUP BY drivers.driverid,races.year
    ORDER BY races.year DESC,S DESC,drivers.driverid
    ) AS Table1

WHERE drivers.driverid=Table1.id AND Table1.rankings=1

GROUP BY Table1.id,drivers.driverid


)
GROUP BY drivers.driverid
ORDER BY points DESC,forename,surname,drivers.driverid
LIMIT 3;




--8--

SELECT Table11.driverid,Table11.forename,Table11.surname,Table11.num_countries

FROM 


(SELECT drivers.driverid,forename,surname,COUNT(DISTINCT circuits.country) AS num_countries
FROM drivers,results,races,circuits
WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid AND races.circuitid=circuits.circuitid AND results.positionorder=1
GROUP BY drivers.driverid
ORDER BY num_countries DESC,forename,surname,drivers.driverid
LIMIT 1
) AS Table11

INNER JOIN 

(

SELECT drivers.driverid,forename,surname,COUNT(DISTINCT circuits.country) AS num_countries
FROM drivers,results,races,circuits
WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid AND races.circuitid=circuits.circuitid AND results.positionorder=1
GROUP BY drivers.driverid
ORDER BY num_countries DESC,forename,surname,drivers.driverid

) AS Table2


ON Table11.num_countries=Table2.num_countries;


--9--


SELECT DISTINCT drivers.driverid,forename,surname, SUM(results.positionorder) AS num_wins
FROM drivers,results
WHERE drivers.driverid=results.driverid AND results.grid=1 AND results.positionorder=1
GROUP BY drivers.driverid
ORDER BY num_wins DESC,forename,surname,drivers.driverid
LIMIT 3;



--10--



SELECT Table11.raceid,Table11.num_stops,Table11.driverid,Table11.forename,Table11.surname,Table11.circuitid,Table11.name

FROM 


(SELECT Table1.Rid as raceid, Table1.num_stops AS num_stops,Table1.Did AS driverid,Table1.forename,Table1.surname,Table1.cid as circuitid,Table1.cname AS name

FROM

(SELECT races.raceid AS Rid,COUNT(pitstops.driverid) AS num_stops,pitstops.driverid AS Did,forename,surname,circuits.circuitid as Cid,circuits.name as Cname
FROM races,pitstops,drivers,circuits
WHERE pitstops.raceid=races.raceid  AND pitstops.driverid=drivers.driverid AND races.circuitid=circuits.circuitid
GROUP BY pitstops.driverid,races.raceid,forename,surname,Cid,Cname
ORDER BY num_stops DESC) AS Table1,


(SELECT results.raceid AS Rid,results.driverid as Did
FROM results
WHERE results.positionOrder=1
) AS Table2

WHERE Table1.Rid=Table2.Rid AND Table1.Did=Table2.Did

ORDER BY num_stops DESC,forename,surname,Table1.cname,Table1.cid,Table2.Did

LIMIT 1
) AS Table11

INNER JOIN 

(

SELECT Table1.Rid as raceid, Table1.num_stops AS num_stops,Table1.Did AS driverid,Table1.forename,Table1.surname,Table1.cid as circuitid,Table1.cname AS name

FROM

(SELECT races.raceid AS Rid,COUNT(pitstops.driverid) AS num_stops,pitstops.driverid AS Did,forename,surname,circuits.circuitid as Cid,circuits.name as Cname
FROM races,pitstops,drivers,circuits
WHERE pitstops.raceid=races.raceid  AND pitstops.driverid=drivers.driverid AND races.circuitid=circuits.circuitid
GROUP BY pitstops.driverid,races.raceid,forename,surname,Cid,Cname
ORDER BY num_stops DESC) AS Table1,


(SELECT results.raceid AS Rid,results.driverid as Did
FROM results
WHERE results.positionOrder=1
) AS Table2

WHERE Table1.Rid=Table2.Rid AND Table1.Did=Table2.Did

ORDER BY num_stops DESC,forename,surname,Table1.cname,Table1.cid,Table2.Did


) AS Table22


ON Table11.num_stops=Table22.num_stops;




--11--

SELECT Table11.raceid,Table11.name,Table11.location,Table11.num_collisions

FROM 


(
SELECT races.raceid,circuits.name AS name,location, COUNT(status.statusid) AS num_collisions
FROM races,status,circuits,results
WHERE races.circuitid=circuits.circuitid AND status.statusid=results.statusid AND results.raceid=races.raceid AND status.statusid=4
GROUP BY races.raceid,circuits.name,circuits.location
ORDER BY num_collisions DESC, circuits.name,location,races.raceid
) AS Table11

INNER JOIN 

(

SELECT races.raceid,circuits.name AS name,location, COUNT(status.statusid) AS num_collisions
FROM races,status,circuits,results
WHERE races.circuitid=circuits.circuitid AND status.statusid=results.statusid AND results.raceid=races.raceid AND status.statusid=4
GROUP BY races.raceid,circuits.name,circuits.location
ORDER BY num_collisions DESC, circuits.name,location,races.raceid
LIMIT 1

) AS Table22


ON Table11.num_collisions=Table22.num_collisions;



--12--

SELECT Table11.driverid,Table11.forename,Table11.surname,Table11.count

FROM 


(
SELECT drivers.driverid,forename,surname,COUNT(results.positionorder) AS count
FROM drivers,results
WHERE drivers.driverid=results.driverid AND results.positionorder=1 AND results.rank=1
GROUP BY drivers.driverid
ORDER BY count DESC,forename,surname,drivers.driverid
) AS Table11

INNER JOIN 

(

SELECT drivers.driverid,forename,surname,COUNT(results.positionorder) AS count
FROM drivers,results
WHERE drivers.driverid=results.driverid AND results.positionorder=1 AND results.rank=1
GROUP BY drivers.driverid
ORDER BY count DESC,forename,surname,drivers.driverid
LIMIT 1



) AS Table22


ON Table11.count=Table22.count;



--13--

SELECT Table11.year,Table11.point_diff,Table11.constructor1_id, Table11.constructor1_name,Table11.constructor2_id, Table11.constructor2_name

FROM 


(
SELECT Table1.Y as year,Table1.S-Table2.S as point_diff,Table1.id as constructor1_id, A.name as constructor1_name,Table2.id as constructor2_id, B.name as constructor2_name

FROM constructors A,constructors B, 
(SELECT constructors.constructorid AS id ,SUM(constructorresults.points) AS S,races.year AS Y,DENSE_RANK() OVER (
PARTITION BY races.year ORDER BY SUM(constructorresults.points) DESC) AS rankings
FROM constructors,constructorresults,races
WHERE constructors.constructorid=constructorresults.constructorid AND constructorresults.raceid=races.raceid 
GROUP BY constructors.constructorid,races.year
ORDER BY races.year DESC,S DESC,constructors.constructorid) AS Table1,

(SELECT constructors.constructorid AS id ,SUM(constructorresults.points) AS S,races.year AS Y,DENSE_RANK() OVER (
PARTITION BY races.year ORDER BY SUM(constructorresults.points) DESC) AS rankings
FROM constructors,constructorresults,races
WHERE constructors.constructorid=constructorresults.constructorid AND constructorresults.raceid=races.raceid 
GROUP BY constructors.constructorid,races.year
ORDER BY races.year DESC,S DESC,constructors.constructorid) AS Table2

WHERE Table1.id=A.constructorid AND Table2.id=B.constructorid AND Table1.Y=Table2.Y AND Table1.rankings=1 AND Table2.rankings=2

GROUP BY Table1.Y,Table1.id,Table2.id,A.name,B.name,Table1.S,Table2.S

ORDER BY point_diff DESC,A.name,B.name,Table1.id,Table2.id

) AS Table11

INNER JOIN 

(

SELECT Table1.Y as year,Table1.S-Table2.S as point_diff,Table1.id as constructor1_id, A.name as constructor1_name,Table2.id as constructor2_id, B.name as constructor2_name

FROM constructors A,constructors B, 
(SELECT constructors.constructorid AS id ,SUM(constructorresults.points) AS S,races.year AS Y,DENSE_RANK() OVER (
PARTITION BY races.year ORDER BY SUM(constructorresults.points) DESC) AS rankings
FROM constructors,constructorresults,races
WHERE constructors.constructorid=constructorresults.constructorid AND constructorresults.raceid=races.raceid 
GROUP BY constructors.constructorid,races.year
ORDER BY races.year DESC,S DESC,constructors.constructorid) AS Table1,

(SELECT constructors.constructorid AS id ,SUM(constructorresults.points) AS S,races.year AS Y,DENSE_RANK() OVER (
PARTITION BY races.year ORDER BY SUM(constructorresults.points) DESC) AS rankings
FROM constructors,constructorresults,races
WHERE constructors.constructorid=constructorresults.constructorid AND constructorresults.raceid=races.raceid 
GROUP BY constructors.constructorid,races.year
ORDER BY races.year DESC,S DESC,constructors.constructorid) AS Table2

WHERE Table1.id=A.constructorid AND Table2.id=B.constructorid AND Table1.Y=Table2.Y AND Table1.rankings=1 AND Table2.rankings=2

GROUP BY Table1.Y,Table1.id,Table2.id,A.name,B.name,Table1.S,Table2.S

ORDER BY point_diff DESC,A.name,B.name,Table1.id,Table2.id
LIMIT 1



) AS Table22


ON Table11.point_diff=Table22.point_diff;


--14--


SELECT Table11.driverid,Table11.forename,Table11.surname,Table11.circuitid,Table11.country,Table11.pos

FROM 


(
SELECT drivers.driverid,forename,surname,circuits.circuitid,circuits.country,MAX(results.grid) AS pos
FROM drivers,results,races,circuits
WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid AND races.circuitid=circuits.circuitid AND races.year=2018 AND results.positionorder=1
GROUP BY drivers.driverid,races.raceid,results.resultid,circuits.circuitid
ORDER BY pos DESC,forename DESC,surname,circuits.country,drivers.driverid,races.circuitid
LIMIT 1

) AS Table11

INNER JOIN 

(

SELECT drivers.driverid,forename,surname,circuits.circuitid,circuits.country,MAX(results.grid) AS pos
FROM drivers,results,races,circuits
WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid AND races.circuitid=circuits.circuitid AND races.year=2018 AND results.positionorder=1
GROUP BY drivers.driverid,races.raceid,results.resultid,circuits.circuitid
ORDER BY pos DESC,forename DESC,surname,circuits.country,drivers.driverid,races.circuitid

) AS Table22


ON Table11.pos=Table22.pos;





--15--


SELECT Table11.constructorid,Table11.name,Table11.num

FROM 


(
SELECT constructors.constructorid,constructors.name, COUNT(status.statusid) AS num
FROM constructors,results,status,races
WHERE constructors.constructorid=results.constructorid AND results.raceid=races.raceid AND results.statusid=status.statusid AND status.statusid=5  
    AND races.year>=2000 AND races.year<=2021
GROUP BY constructors.constructorid
ORDER BY num DESC,constructors.name,constructors.constructorid
LIMIT 1

) AS Table11

INNER JOIN 

(

SELECT constructors.constructorid,constructors.name, COUNT(status.statusid) AS num
FROM constructors,results,status,races
WHERE constructors.constructorid=results.constructorid AND results.raceid=races.raceid AND results.statusid=status.statusid AND status.statusid=5  
    AND races.year>=2000 AND races.year<=2021
GROUP BY constructors.constructorid
ORDER BY num DESC,constructors.name,constructors.constructorid

) AS Table22


ON Table11.num=Table22.num;



--16--

SELECT DISTINCT drivers.driverid,forename,surname
FROM drivers,results,races,circuits
WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid AND races.circuitid=circuits.circuitid AND drivers.nationality='American' AND results.positionorder=1 AND circuits.country='USA'
ORDER BY forename,surname,driverid
LIMIT 5;



--17--


SELECT Table11.constructorid,Table11.name,Table11.count

FROM 


(
SELECT Table3.Id AS constructorid,Table3.Name AS name,COUNT(Table3.rid) AS count

FROM(
    SELECT Table1.Id,Table1.Name,Table1.Rid

    FROM

    (SELECT constructors.constructorid AS Id,constructors.name AS Name,races.raceid AS Rid
    FROM constructors,results,races
    WHERE constructors.constructorid=results.constructorid AND races.raceid=results.raceid AND results.positionorder=1 AND races.year>=2014) AS Table1,
    (SELECT constructors.constructorid AS Id,constructors.name AS Name,races.raceid AS Rid
    FROM constructors,results,races
    WHERE constructors.constructorid=results.constructorid AND races.raceid=results.raceid AND results.positionorder=2  AND races.year>=2014) AS Table2

    WHERE Table1.Id=Table2.Id AND Table1.Rid=Table2.Rid

    ORDER BY Table1.Id,Table1.Name,Table1.Rid
) AS Table3

GROUP BY Table3.Id,Table3.Name


ORDER BY count DESC,name,constructorid


) AS Table11

INNER JOIN 

(

SELECT Table3.Id AS constructorid,Table3.Name AS name,COUNT(Table3.rid) AS count

FROM(
    SELECT Table1.Id,Table1.Name,Table1.Rid

    FROM

    (SELECT constructors.constructorid AS Id,constructors.name AS Name,races.raceid AS Rid
    FROM constructors,results,races
    WHERE constructors.constructorid=results.constructorid AND races.raceid=results.raceid AND results.positionorder=1 AND races.year>=2014) AS Table1,
    (SELECT constructors.constructorid AS Id,constructors.name AS Name,races.raceid AS Rid
    FROM constructors,results,races
    WHERE constructors.constructorid=results.constructorid AND races.raceid=results.raceid AND results.positionorder=2  AND races.year>=2014) AS Table2

    WHERE Table1.Id=Table2.Id AND Table1.Rid=Table2.Rid

    ORDER BY Table1.Id,Table1.Name,Table1.Rid
) AS Table3

GROUP BY Table3.Id,Table3.Name


ORDER BY count DESC,name,constructorid
LIMIT 1

) AS Table22


ON Table11.count=Table22.count;




--18--

SELECT Table11.driverid,Table11.forename,Table11.surname,Table11.num_laps

FROM 


(
SELECT drivers.driverid,forename,surname,SUM(laptimes.position) AS num_laps
FROM drivers,laptimes
WHERE drivers.driverid=laptimes.driverid AND laptimes.position=1
GROUP BY drivers.driverid
ORDER BY num_laps DESC,forename,surname,driverid

) AS Table11

INNER JOIN 

(

SELECT drivers.driverid,forename,surname,SUM(laptimes.position) AS num_laps
FROM drivers,laptimes
WHERE drivers.driverid=laptimes.driverid AND laptimes.position=1
GROUP BY drivers.driverid
ORDER BY num_laps DESC,forename,surname,driverid
LIMIT 1

) AS Table22


ON Table11.num_laps=Table22.num_laps;

--19--

SELECT Table11.driverid,Table11.forename,Table11.surname,Table11.count

FROM 


(
SELECT drivers.driverid,forename,surname,COUNT(results.positionorder) AS count
FROM drivers,results
WHERE drivers.driverid=results.driverid AND results.positionorder>=1 AND results.positionOrder<=3
GROUP BY drivers.driverid
ORDER BY count DESC,forename,surname,driverid

) AS Table11

INNER JOIN 

(

SELECT drivers.driverid,forename,surname,COUNT(results.positionorder) AS count
FROM drivers,results
WHERE drivers.driverid=results.driverid AND results.positionorder>=1 AND results.positionOrder<=3
GROUP BY drivers.driverid
ORDER BY count DESC,forename,surname,driverid
LIMIT 1

) AS Table22


ON Table11.count=Table22.count;


--20--

SELECT drivers.driverid,forename,surname,COUNT(Table1.id) as num_champs

FROM 

    drivers,(
    SELECT drivers.driverid AS id ,SUM(results.points) AS S,races.year,DENSE_RANK() OVER (
    PARTITION BY races.year ORDER BY SUM(results.points) DESC,drivers.driverid,races.year) AS rankings
    FROM drivers,results,races
    WHERE drivers.driverid=results.driverid AND results.raceid=races.raceid
    GROUP BY drivers.driverid,races.year
    ORDER BY races.year DESC,S DESC,drivers.driverid
    ) AS Table1

WHERE drivers.driverid=Table1.id AND Table1.rankings=1

GROUP BY Table1.id,drivers.driverid

ORDER BY num_champs DESC,forename,surname DESC,Table1.id
LIMIT 5;



