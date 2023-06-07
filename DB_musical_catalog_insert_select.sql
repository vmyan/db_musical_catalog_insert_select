--CREATE запросы (предыдущая домашняя работа)

CREATE TABLE IF NOT EXISTS genres (
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) unique NOT NULL
);

CREATE TABLE IF NOT EXISTS artists (
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT NULL
);

-- многие ко многим (genres_artists)
CREATE TABLE IF NOT EXISTS genres_artists (
	genre_id INTEGER REFERENCES genres(id),
	artist_id INTEGER REFERENCES artists(id),
	CONSTRAINT pk_genres_artists PRIMARY KEY (genre_id, artist_id)
);

CREATE TABLE IF NOT EXISTS albums(
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT null,
	year date NOT NULL CHECK (year > '1960-01-01')
);

-- многие ко многим (artists_albums)
CREATE TABLE IF NOT EXISTS artists_albums (
	artist_id INTEGER REFERENCES artists(id),
	album_id INTEGER REFERENCES albums(id),
	CONSTRAINT pk_artists_albums PRIMARY KEY (artist_id, album_id)
);

CREATE TABLE IF NOT EXISTS tracks (
	id SERIAL PRIMARY KEY,
	album_id INTEGER NOT NULL REFERENCES albums(id),
	name VARCHAR(40) NOT null,
	duration INTEGER NOT null --in seconds
);

CREATE TABLE IF NOT EXISTS collections(
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT null,
	year date
);

-- многие ко многим (tracks_collections)
CREATE TABLE IF NOT EXISTS tracks_collections (
	track_id INTEGER REFERENCES tracks(id),
	collection_id INTEGER REFERENCES collections(id),
	CONSTRAINT pk_tracks_collections PRIMARY KEY (track_id, collection_id)
);

--INSERT запросы
--Задание 1
insert into genres
values(1,'Поп'),
(2,'Этно'),
(3,'Соул'),
(4, 'Хип-Хоп'),
(5,'Шансон');

insert into artists
values(1,'Zivert'),
(2,'Manizha'),
(3,'Aretha Franklin'),
(4,'Алла Пугачева'),
(5, 'Noize MC');

insert into genres_artists
values(1,1),
(1,3),
(1,4),
(2,2),
(3,2),
(3,3),
(4,5),
(5,4);

insert into albums
values(1,'WAKE UP!', '2022-01-01'),
(2,'Сияй', '2018-01-01'),
(3,'ЯIAM', '2018-01-01'),
(4,'This Christmas', '2008-01-01'),
(5,'30 Greatest Hits', '1985-01-01'),
(6,'Зеркало души', '1977-01-01'),
(7,'XV Live', '2019-01-01');

insert into artists_albums
values (1,1),
(1,2),
(2,3),
(3,4),
(3,5),
(4,6),
(5,7);

insert into tracks
values(1,1,'WAKE UP!',212),
(2,2,'Ещё хочу',196),
(3,2,'Зелёные волны',206),
(4,3,'Изумруд',248),
(5,5,'I Say a Little Prayer',199),
(6,4,'Silent Night',300),
(7,6,'Куда уходит детство',270),
(8,6,'Если долго мучаться',146),
(9,7,'Вселенная бесконечна?',248),
(10,7,'myself',150),
(11,7,'by myself',150),
(12,7,'bemy self',150),
(13,7,'myself by',150),
(14,7,'by myself by',150),
(15,7,'beemy',150),
(16,7,'premyne',150),
(17,7,'my darling',150),
(18,7,'own my',150),
(19,7,'my own',150),
(20,7,'oh my God',150),
(21,7,'my',150),
(22,7,'мой друг',150),
(23,7,'мой',150),
(24,7,'мойдодыр',150),
(25,7,'ах мой друг',150);

insert into collections
values(1,'Zivert: лучшее','2022-11-26'),
(2,'Песни для тренировок','2021-04-23'),
(3,'Manizha','2018-04-12'),
(4,'Aretha Franklin: лучшее','2018-08-16'),
(5,'Алла Пугачёва','2019-04-15'),
(6,'Noize MC: лучшее','2023-01-16');

insert into tracks_collections 
values (1,1),
(2,2),
(3,1),
(4,3),
(5,4),
(6,4),
(7,5),
(8,5),
(9,6);

--SELECT запросы
--Задание 2
--Название и продолжительность самого длительного трека.
select name, duration
from tracks
where duration = (select max(duration) from tracks);

--Название треков, продолжительность которых не менее 3,5 минут.
select name, duration
from tracks 
where duration >= 210;

--Названия сборников, вышедших в период с 2018 по 2020 год включительно.
select name,year
from collections
where date(year) between '2018-01-01' and '2021-01-01';

--Исполнители, чьё имя состоит из одного слова.
select name
from artists
where name not like '% %';

--Название треков, которые содержат слово «мой» или «my»
select name
from tracks
where name ilike 'my %'
or name ilike '% my'
or name ilike '% my %'
or name ilike 'my'
or name ilike 'мой %'
or name ilike '% мой'
or name ilike '% мой %'
or name ilike 'мой';

--Задание 3
--Количество исполнителей в каждом жанре.
select genre_id, count(artist_id)
from genres_artists
group by genre_id;

--Количество треков, вошедших в альбомы 2019–2020 годов.
select count(tracks.id) from tracks
join albums on tracks.album_id = albums.id 
where albums.year between '2019-01-01' and '2021-01-01';

--Средняя продолжительность треков по каждому альбому.
select albums.name, avg(tracks.duration)
from albums 
join tracks on albums.id = tracks.album_id
group by albums.name;

--Все исполнители, которые не выпустили альбомы в 2020 году.
select artists.name
from artists
where artists.name not in (select artists.name
						   from artists
						   join artists_albums on artists.id = artists_albums.artist_id
						   join albums on artists_albums.album_id = albums.id
						   where albums.year = '2020-01-01');

--Названия сборников, в которых присутствует конкретный исполнитель (выберите его сами).
select distinct collections.name
from collections
join tracks_collections on collections.id = tracks_collections.collection_id 
join tracks on tracks_collections.track_id = tracks.id
join albums on tracks.album_id = albums.id 
join artists_albums on albums.id = artists_albums.album_id
join artists on artists_albums.artist_id = artists.id
where artists.name like 'Manizha';

--Задание 4
--Названия альбомов, в которых присутствуют исполнители более чем одного жанра.
select albums.name, artists.name
from albums
join artists_albums on albums.id = artists_albums.album_id 
join artists on artists_albums.artist_id = artists.id 
join genres_artists on artists.id = genres_artists.artist_id 
group by artists.name, albums.name
having count(genres_artists.genre_id) > 1

--Наименования треков, которые не входят в сборники.
select tracks.name
from tracks
left join tracks_collections on tracks.id = tracks_collections.track_id 
where tracks_collections.track_id is null

--Исполнитель или исполнители, написавшие самый короткий по продолжительности трек, 
--— теоретически таких треков может быть несколько.
select artists.name, tracks.duration
from artists
join artists_albums on artists.id = artists_albums.artist_id 
join albums on artists_albums.album_id = albums.id 
join tracks on albums.id = tracks.album_id 
where tracks.duration in (select min(duration) from tracks)

--Названия альбомов, содержащих наименьшее количество треков.
select albums.name
from albums
join tracks on albums.id = tracks.album_id 
group by albums.name 
having count(tracks.id) in (select count(tracks.id) 
							from albums
							join tracks on albums.id = tracks.album_id
							group by albums.name
							order by count(tracks.id)
							limit 1);



