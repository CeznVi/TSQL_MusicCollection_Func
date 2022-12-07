USE	MusicStore
GO

--************************************************************************************************************************
/* Функція користувача повертає всі диски заданого року. 
Рік передається як параметр; */
------------------------Функція---------------------------
CREATE FUNCTION [dbo].GetDiscFromYear(@year int)
RETURNS TABLE
AS
	RETURN (SELECT [D].[Name] AS 'Назва диску',
					[A].[Name] AS 'Виконавець',
					[S].[Name] AS 'Стиль диску',
					[D].[DatePublish] AS 'Дата виходу'
			FROM [Disc] D, [Artist] A, [Style] S
			WHERE [D].[IdArtist] = [A].[Id] AND
			[D].[IdStyle] = [S].[Id] AND
			YEAR([D].[DatePublish]) = @year) 
			
GO
---------------------Кінець функції-----------------------
--********************************************************
--------------------Перевірка роботи----------------------
SELECT * FROM [dbo].GetDiscFromYear(2002)
SELECT * FROM [dbo].GetDiscFromYear(1965)
--------------------Кінець перевірки----------------------
--************************************************************************************************************************
--************************************************************************************************************************
--************************************************************************************************************************
/* Функція користувача повертає інформацію про диски з 
однаковою назвою альбому, але різними виконавцями; */
------------------------Функція---------------------------
GO
CREATE FUNCTION [dbo].GetDiskWithSameName()
RETURNS TABLE
AS
	RETURN (SELECT  [D].[Name] AS 'Назва диску',
					[A].[Name] AS 'Виконавець',
					[D].[DatePublish] AS 'Дата виходу',
					[P].[Name] AS 'Видавець',
					[S].[Name] AS 'Стиль диску'
			FROM [Disc] D, [Artist] A, [Publisher] P, [Style] S,
					(SELECT [D].[Name] AS 'Name',
						COUNT([D].[Name]) AS 'Co'
					FROM [Disc] D
					GROUP BY [D].[Name]
					HAVING COUNT([D].[Name]) > 1
					) AS [T]
WHERE [D].[IdArtist] = [A].[Id]
AND [D].[Name] = [T].[Name]
AND [D].[IdPublisher] = [P].[Id]
AND [D].[IdStyle] = [S].[Id])	
GO
---------------------Кінець функції-----------------------
--********************************************************
--------------------Перевірка роботи----------------------
SELECT * FROM [dbo].GetDiskWithSameName()

--------------------Кінець перевірки----------------------
--************************************************************************************************************************

/* Функція користувача повертає інформацію про всі пісні в 
чиїй назві зустрічається задане слово. Слово передається 
як параметр; */
------------------------Функція---------------------------
GO
CREATE FUNCTION [dbo].GetSongLike(@word nvarchar(100))
RETURNS TABLE
AS
	RETURN (SELECT 
				[S].[Name] AS 'Назва',
				[D].[Name] AS 'Диск',
				[A].[Name] AS 'Артист',
				[St].[Name] AS 'Стиль',
				[S].[Time] AS 'Тривалість пісні'
			FROM [Song] S, [Disc] D, [Artist] A, [Style] St
			WHERE [S].[Name] LIKE @word
			AND [S].[IdDisc] = [D].[Id]
			AND [S].[IdStyle] = [St].[Id]
			AND [S].[IdArtist] = [A].[Id]
			)
GO
---------------------Кінець функції-----------------------
--********************************************************
--------------------Перевірка роботи----------------------
SELECT * FROM [dbo].GetSongLike('%submarine%')
--------------------Кінець перевірки----------------------
--************************************************************************************************************************

/* Функція користувача повертає кількість альбомів у стилях
hard rock та heavy metal; */
------------------------Функція---------------------------
GO
CREATE FUNCTION [dbo].GetCountRockMetalDisc()
RETURNS @rezult TABLE (Style nvarchar(20) not null, AlbumCount int not null default(0))
AS
BEGIN
	INSERT INTO @rezult
		SELECT 'Hard rock', COUNT([D].[Name])
		FROM [Disc] D, [Style] S
		WHERE [D].[IdStyle] = [S].[Id]
		AND [S].[Name] = 'hard rock'
		UNION 
		SELECT 'Heavy metal', COUNT([D].[Name])
		FROM [Disc] D, [Style] S
		WHERE [D].[IdStyle] = [S].[Id]
		AND [S].[Name] = 'heavy metal'
	RETURN
END
GO
---------------------Кінець функції-----------------------
--********************************************************
--------------------Перевірка роботи----------------------
SELECT * FROM [dbo].GetCountRockMetalDisc()
--------------------Кінець перевірки----------------------
--************************************************************************************************************************

/* Функція користувача повертає інформацію про середню
тривалість пісні заданого виконавця. Назва виконавця
передається як параметр; */
------------------------Функція---------------------------
GO
CREATE FUNCTION [dbo].GetAvarageLenghtSongArtist(@artist nvarchar(100))
RETURNS @rezult TABLE (Artist nvarchar(100) not null, AvarageLenghtSong time(7) not null)
AS
BEGIN
	INSERT INTO @rezult
		SELECT @artist, cast(cast(avg(cast(CAST([S].[Time] as datetime) as float)) as datetime) as time)
		FROM [Song] S, [Artist] A
		WHERE [S].[IdArtist] = [A].[Id]
		AND [A].[Name] = @artist
	RETURN
END
GO
---------------------Кінець функції-----------------------
--********************************************************
--------------------Перевірка роботи----------------------
SELECT * FROM [dbo].GetAvarageLenghtSongArtist('The Beatles')
UNION
SELECT * FROM [dbo].GetAvarageLenghtSongArtist('test')
--------------------Кінець перевірки----------------------

--************************************************************************************************************************

/* Функція користувача повертає інформацію про найдовшу
та найкоротшу пісню; */
------------------------Функція---------------------------
GO
CREATE FUNCTION [dbo].GetSongWithMaxAndMinLengh()
RETURNS TABLE
AS
	RETURN (SELECT 
				[S].[Name] AS 'Назва',
				[D].[Name] AS 'Диск',
				[A].[Name] AS 'Артист',
				[St].[Name] AS 'Стиль',
				[S].[Time] AS 'Тривалість пісні'
			FROM [Song] S, [Disc] D, [Artist] A, [Style] St
			WHERE [S].[IdDisc] = [D].[Id]
			AND [S].[IdStyle] = [St].[Id]
			AND [S].[IdArtist] = [A].[Id]
			AND [S].[Time] = (SELECT cast(cast(MIN(cast(CAST([Song].[Time] as datetime) as float)) as datetime) as time)
									FROM [Song])
			UNION
			SELECT 
				[S].[Name] AS 'Назва',
				[D].[Name] AS 'Диск',
				[A].[Name] AS 'Артист',
				[St].[Name] AS 'Стиль',
				[S].[Time] AS 'Тривалість пісні'
			FROM [Song] S, [Disc] D, [Artist] A, [Style] St
			WHERE [S].[IdDisc] = [D].[Id]
			AND [S].[IdStyle] = [St].[Id]
			AND [S].[IdArtist] = [A].[Id]
			AND [S].[Time] = (SELECT cast(cast(MAX(cast(CAST([Song].[Time] as datetime) as float)) as datetime) as time)
									FROM [Song])
			)
GO
---------------------Кінець функції-----------------------
--********************************************************
--------------------Перевірка роботи----------------------
SELECT * FROM [dbo].GetSongWithMaxAndMinLengh()
-----Перевірка перевірки функції
SELECT TOP(1)
				[S].[Name] AS 'Назва',
				[S].[Time] AS 'Тривалість пісні'
			FROM [Song] S
			ORDER BY [S].[Time] DESC
SELECT TOP(1)
				[S].[Name] AS 'Назва',
				[S].[Time] AS 'Тривалість пісні'
			FROM [Song] S
			ORDER BY [S].[Time] ASC
--------------------Кінець перевірки----------------------
--************************************************************************************************************************

/* Функція користувача повертає інформацію про виконавців,
які створили альбоми в двох і більше стилях. */
------------------------Функція---------------------------
GO
CREATE FUNCTION [dbo].GetArtistWhichHaveDiscInManyStyle()
RETURNS TABLE
AS
	RETURN ( 
			SELECT [A].[Name] AS 'Артист, який має диск з різними стилями музики',
				[D].[Name] AS 'Диск',
				[T].[Count] AS 'Кількість поєднаних стилів'
			FROM [Artist] A, [Song] S, [Disc] D,
												(SELECT [TEMP].[IdD] AS 'IdDisc',
													COUNT([TEMP].[IdS]) AS 'Count'
												FROM
													(SELECT [S].[IdDisc] AS 'IdD', [S].[IdStyle] AS 'IdS'
													FROM [Song] S
													GROUP BY [S].[IdDisc], [S].[IdStyle]) AS [TEMP]
												GROUP BY [TEMP].[IdD]	
												HAVING COUNT([TEMP].[IdS]) > 1) AS [T]
			WHERE [A].[Id] = [S].[IdArtist]
			AND [D].[IdArtist] = [A].[Id]
			AND [S].[IdDisc] = [T].[IdDisc]
			GROUP BY [A].[Name], [D].[Name], [T].[Count]
			)
GO
---------------------Кінець функції-----------------------
--********************************************************
--------------------Перевірка роботи----------------------
SELECT * FROM [dbo].GetArtistWhichHaveDiscInManyStyle()
--------------------Кінець перевірки----------------------
--************************************************************************************************************************








