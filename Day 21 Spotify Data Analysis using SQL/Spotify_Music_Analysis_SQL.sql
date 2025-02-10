
-- EDA

Select * 
From project..spotify_data;


Select COUNT(*) as total_data
From project..spotify_data;
-- We have 20594 rows in our dataset.


Select COUNT(Distinct Artist) as artist
From project..spotify_data
-- There are 2074 individual artist in this dataset


Select COUNT(Distinct Album) as Album
From project..spotify_data
-- We have 11798 unique album for our listener


Select Distinct(Album_type), COUNT(Album) as no_of_album
From project..spotify_data
group by Album_type;
-- The dataset has large number of albums(14832) than single(4973) and compilation(4973).


Select MAX(Duration_min) As Max_Duration,
		MIN(Duration_min) As Min_Duration,
		AVG(Duration_min) As Avg_Duration
From project..spotify_data
-- While Min_Duration is 0 minute for some music, which is not possible for music. Let see what's going there

Select *
From project..spotify_data
Where Duration_min = 0;
-- Not only Duration, all other elements are 0 for this track(2 rows) which means the following data are not correct. Now we delete them.

Delete from project..spotify_data
Where Duration_min = 0;  -- 2 rows affected


Select Album_type,AVG(Danceability) Danceability,
				AVG(Energy) As Energy_level,
				AVG(Loudness) As Loudness,
				AVG(Acousticness) As Acousticness,
				AVG(Instrumentalness) As Instrument
From project..spotify_data
Group By Album_type;


Select most_playedon, SUM(Views) Total_Views
From project..spotify_data
Group By most_playedon;
-- Youtube(1,179,996,161,076) has more views compared to Spotify(715,400,473,308)


----------------------------------------------------------------------------------------------------
-- Easy Level

-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.
Select Track, Stream
From project..spotify_data
Where Stream >= 1000000000
Order BY Stream DESC;


-- Q2. List all albums along with their respective artists.
Select Distinct Album, Artist
From project..spotify_data;


-- Q3. Get the total number of comments for tracks where licensed = TRUE.
Select Track, SUM(Comments) as total_comment
From project..spotify_data
Where Licensed = 1
Group By Track;

Select SUM(Comments) as total_comment
From project..spotify_data
Where Licensed = 1;


-- Q4. Find all tracks that belong to the album type single.
Select Distinct Track
From project..spotify_data
Where Album_type = 'single';


-- Q5. Count the total number of tracks by each artist.
Select Artist, COUNT(Track) as total_tracks
From project..spotify_data
Group By Artist
Order By total_tracks;


------------------------------------------------------------------------------------------------------
-- Medium Level Questions

-- Q1. Calculate the average danceability of tracks in each album.
Select Album,
			Track,
			AVG(Danceability) As Avg_Danceabiltiy
From project..spotify_data
Group By Album,Track
Order By Avg_Danceabiltiy DESC;


-- Q2. Find the top 5 tracks with the highest energy values.
	Select Top 5 Track,
		MAX(Energy) As Energy_level
	From project..spotify_data
	Group By Track
	Order By Energy_level DESC;


-- Q3. List all tracks along with their views and likes where official_video = TRUE.
Select Track, 
		SUM(Views) As total_views,
		SUM(Likes) As total_likes
From project..spotify_data
Where official_video = 1
Group By Track
Order by total_views DESC, total_likes DESC

-- Q4. For each album, calculate the total views of all associated tracks.
Select Album, 
			Track,
			SUM(Views) as total_views
From project..spotify_data
Group By Album, Track
Order By total_views DESC

-- Q5.Retrieve the track names that have been streamed on Spotify more than YouTube.

Select * 
From 
(
	Select Track,
		-- most_playedon, 
		coalesce(sum(Case when most_playedon = 'Youtube' Then Stream End),0) as youtube_stream,
		Coalesce(sum(Case when most_playedon = 'Spotify' Then Stream End),0) as spotify_stream
From project..spotify_data
Group by Track
) As track_name
Where spotify_stream > youtube_stream
		And youtube_stream <>0


----------------------------------------------------------------------------------------------------------
-- Advanced Level Question

-- Q1. Find the top 3 most-viewed tracks for each artist using window functions.
With most_view_tranks As(
Select *, 
		Dense_Rank() over(Partition By Artist Order By total_views DESC) as view_rank
From (
	Select Artist, Track, sum(Views) as total_views
	From project..spotify_data
	Group By Artist, Track
	-- Order by Artist, total_views DESC 
	) As track_view
)
Select *
	 --Artist, Track, total_views
From most_view_tranks
Where view_rank <=3;


-- Q2. Write a query to find tracks where the liveness score is above the average.
Select Track, Liveness
From project..spotify_data
Where Liveness >
		(Select Avg(Liveness) as avg_liveness
				From project..spotify_data)		-- AVG: 0.1936
Order By Liveness;


-- Q4. Calculate the cumulative sum of likes for track ordered by the number of views, using window function
	
Select *,
		SUM(Likes) over(Order By Views) as cumulative_likes
From (
	Select Track, Likes, Views
	From project..spotify_data
		) As a
Where Likes> 0;


-- Q4. Find the tracks where the enegy-to-liveness ratio is greater than 1.2
Select * 
From (
Select Track, 
		Energy, 
		Liveness, 
		Round((Energy / Liveness),2) As Energy_Liveness_Ratio
From project..spotify_data
) As ratio
Where Energy_Liveness_Ratio > 1.2
Order By Energy_Liveness_Ratio;



-- Q3. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

With energy_difference As(
Select Album,
		MAX(Energy) Max_Energy, 
		MIN(Energy) As Min_Energy
From project..spotify_data
Group by Album
-- Order by Album
)
Select *,
	(Max_Energy - Min_Energy) as energy_diff
From energy_difference
Order By energy_diff DESC;