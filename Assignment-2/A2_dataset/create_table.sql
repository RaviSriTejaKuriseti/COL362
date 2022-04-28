
CREATE table IF NOT EXISTS train_info(
    train_no bigint NOT NULL,
    train_name text,
    distance bigint,
    source_station_name text,
    day_of_departure text,
    destination_station_name text,
    day_of_arrival text,
    departure_time time,
    arrival_time time,
    CONSTRAINT train_key PRIMARY KEY (train_no)
);

CREATE table IF NOT EXISTS games (
    gameid  bigint NOT NULL,
    leagueid bigint ,
    hometeamid bigint ,
    awayteamid bigint ,
    year bigint ,
    homegoals bigint,
    awaygoals bigint,
    CONSTRAINT game_key PRIMARY KEY (gameid)
);

CREATE table IF NOT EXISTS appearances (
    gameid bigint,
    playerid bigint,
    leagueid bigint,
    goals bigint,
    owngoals bigint,
    assists bigint,
    keypasses bigint,
    shots bigint

);
CREATE table IF NOT EXISTS leagues (
    leagueid bigint NOT NULL,
    name text,
    CONSTRAINT league_key PRIMARY KEY (leagueid)

);
CREATE table IF NOT EXISTS players (
    playerid bigint NOT NULL,
    name text,
    CONSTRAINT player_key PRIMARY KEY (playerid)

);
CREATE table IF NOT EXISTS teams (
    teamid bigint NOT NULL,
    name text,
    CONSTRAINT team_key PRIMARY KEY (teamid)

);

