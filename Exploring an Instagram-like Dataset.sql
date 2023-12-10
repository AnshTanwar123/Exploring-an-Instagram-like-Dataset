use ig_clone;
select * from photos;
#query1

SELECT
    AVG(post_count)  as avg_post_per_user
FROM (
    SELECT
        user_id,
        COUNT(*) AS post_count
    FROM
        photos p
    GROUP BY
        user_id 
) post_counts;



##query2

SELECT
    rank_,
    tag_name,
    hashtag_count
FROM (
    SELECT
        t.tag_name,
        COUNT(*) AS hashtag_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_
    FROM
        tags AS t
    JOIN
        photo_tags AS pt ON t.id = pt.tag_id
    GROUP BY
        t.tag_name
) ranked_hashtags
WHERE
    rank_ <= 5;



###query3

SELECT u.username , u.id as user_id
FROM users u
WHERE (
    SELECT COUNT(DISTINCT id)
    FROM photos
) = (
    SELECT COUNT(DISTINCT l.photo_id)
    FROM likes l
    WHERE l.user_id = u.id
)
order by u.id;


####query4
-- Retrieve a list of users along with their usernames and the rank of their account creation, ordered by the creation date in ascending order.

select username, created_at, rank() over(order by created_at) as account_date
from users
order by created_at;


#####query5
##List the comments made on photos with their comment texts, photo URLs, and usernames of users who posted the comments. Include the comment count for each photo

SELECT
    p.image_url,
    u.username,
    c.comment_text,
    COUNT(*) OVER (PARTITION BY c.photo_id) AS comment_count
FROM
    photos p
JOIN
    comments c ON p.id = c.photo_id
JOIN
    users u ON c.user_id = u.id

ORDER BY
    c.photo_id, c.id;

######query6
##For each tag, show the tag name and the number of photos associated with that tag. Rank the tags by the number of photos in descending order.
select tag_name, num_photos, rank() over(order by num_photos desc) as rank_of_tags
from (
select tag_name, count(p.id) num_photos from tags t
  join  photo_tags pt on t.id = pt.tag_id
  join photos p on p.id = pt.photo_id
group by tag_name , t.id) as tagcount;

#######Query7
----  -- List the usernames of users who have posted photos along with the count of photos they have posted. Rank them by the number of photos in descending order.
select username, photo_count, rank() over(order by photo_count) rank_of_photos from 
(
select username, count(p.id) as photo_count 
from photos p  join users u on p.user_id = u.id
group by username) as rank_of_user;

########query8
-- Display the username of each user along with the creation date of their first posted photo and the creation date of their next posted photo.
SELECT
    u.username,
    MIN(p.created_at) AS first_photo_creation_date,
    LEAD(p.created_at) over( ORDER BY p.created_at) AS next_photo_creation_date
FROM
    users u
JOIN
    photos p ON u.id = p.user_id
GROUP BY
    u.username, p.created_at, p.user_id 
ORDER BY
    u.username;

#query 9
-- For each comment, show the comment text, the username of the commenter, and the comment text of the previous comment made on the same photo. 
SELECT
    c.comment_text,
    u.username AS commenter_username,
    LAG(c.comment_text) OVER (PARTITION BY c.photo_id ORDER BY c.created_at) AS previous_comment_text
FROM comments c
JOIN users u ON c.user_id = u.id
ORDER BY c.photo_id, c.created_at;


##########query10
-- Show the username of each user along with the number of photos they have posted and the number of photos posted by the user before them and after them, based on the creation date.
SELECT
    u.username,
    COUNT(p.id) AS num_photos_posted,
    LAG(COUNT(p.id)) OVER (ORDER BY min(p.created_at)) AS num_photos_before,
    LEAD(COUNT(p.id)) OVER (ORDER BY min(p.created_at)) AS num_photos_after
FROM
    users u
  left JOIN
    photos p ON u.id = p.user_id
GROUP BY
    u.id, u.username
ORDER BY
    min(p.created_at);



select * from actor_award