-- RQ2: HOW ARE GFIs SOLVED?

-- Randomly select 13,452 closed issues tagged with non-GFI labels 
-- for forming a comparison dataset.
-- Stored as a view called `closed_non_gfi_issues`
-- Note that if you try executing this query, you will get a different random
-- set of non-GFI issues. If you wish to repeat my replication study using my
-- random set, create a table in your SQL workspace using `closed_non_gfi_issues.csv`
SELECT
  p.repo_id,
  i.id
FROM
  `gfi-replication-study.gfi_dataset.filtered_projects` p,
  `ghtorrentmysql1906.MySQL1906.issues` i,
  `ghtorrentmysql1906.MySQL1906.issue_events` ie
WHERE
  p.repo_id = i.repo_id
  AND i.id = ie.issue_id
  AND ie.action = "closed"
  AND i.id NOT IN (SELECT id FROM `gfi-replication-study.gfi_dataset.gfi_issues`)
ORDER BY
  RAND() -- non-deterministic, no seeding
LIMIT
  13452

-- Find the frequency of labels used for tagging the issues in the set of 
-- randomly selected non-GFIs.
SELECT
  rl.name,
  COUNT(i.id) AS num_issues
FROM
  `gfi-replication-study.gfi_dataset.closed_non_gfi_issues` i,
  `ghtorrentmysql1906.MySQL1906.issue_labels` il,
  `ghtorrentmysql1906.MySQL1906.repo_labels` rl
WHERE
  i.id = il.issue_id
  AND il.label_id = rl.id_
GROUP BY
  rl.name
ORDER BY
  num_issues DESC

-- The following set of queries are for collecting statistics for the GFI and non-GFIs using the 
-- datasets stored in the views `closed_gfi_issues` and `closed_non_gfi_issues`
-- Replace the corresponding table name in the query for getting the result set for either.

-- Number of days of resolution for a GFI.
SELECT
  ci.id,
  i.created_at AS date_created,
  ie.created_at AS date_resolved,
  TIMESTAMP_DIFF(ie.created_at, i.created_at, DAY) AS days_resolution
FROM (`gfi-replication-study.gfi_dataset.closed_gfi_issues` ci
  INNER JOIN
    `ghtorrentmysql1906.MySQL1906.issues` i
  ON
    i.id = ci.id)
LEFT JOIN
  `ghtorrentmysql1906.MySQL1906.issue_events` ie
ON
  ci.id = ie.issue_id
WHERE
  ie.action = "closed"
  AND ie.action_specific IS NOT NULL

-- Number of developers subscribed to a GFI.
SELECT
  id1 AS issue_id, 
  COALESCE(num_subscribed, 0) AS num_subscribed
FROM (
  SELECT
    i.id AS id1
  FROM
    `gfi-replication-study.gfi_dataset.closed_gfi_issues` i)
LEFT JOIN (
  SELECT
    i.id AS id2,
    COUNT(DISTINCT ie.actor_id) AS num_subscribed
  FROM
    `gfi-replication-study.gfi_dataset.closed_gfi_issues` i
  LEFT JOIN
    `ghtorrentmysql1906.MySQL1906.issue_events` ie
  ON
    i.id = ie.issue_id
  WHERE
    ie.action = "subscribed"
  GROUP BY
    i.id )
ON
  id1 = id2

-- Number of times developers are mentioned in GFI body.
SELECT
  id1 AS issue_id, 
  COALESCE(num_mentioned, 0) AS num_mentioned
FROM (
  SELECT
    i.id AS id1
  FROM
    `gfi-replication-study.gfi_dataset.closed_gfi_issues` i)
LEFT JOIN (
  SELECT
    i.id AS id2,
    COUNT(*) AS num_mentioned
  FROM
    `gfi-replication-study.gfi_dataset.closed_gfi_issues` i
  LEFT JOIN
    `ghtorrentmysql1906.MySQL1906.issue_events` ie
  ON
    i.id = ie.issue_id
  WHERE
    ie.action = "mentioned"
  GROUP BY
    i.id )
ON
  id1 = id2

-- Number of times a GFI has been referenced in a commit.
SELECT
  id1 AS issue_id, 
  COALESCE(num_reference, 0) AS num_reference
FROM (
  SELECT
    i.id AS id1
  FROM
    `gfi-replication-study.gfi_dataset.closed_gfi_issues` i)
LEFT JOIN (
  SELECT
    i.id AS id2,
    COUNT(*) AS num_reference
  FROM
    `gfi-replication-study.gfi_dataset.closed_gfi_issues` i
  LEFT JOIN
    `ghtorrentmysql1906.MySQL1906.issue_events` ie
  ON
    i.id = ie.issue_id
  WHERE
    ie.action = "referenced"
  GROUP BY
    i.id )
ON
  id1 = id2

-- Number of developers who comment on each GFI and number of comments on each GFI.
SELECT
  i.id,
  COUNT(DISTINCT ic.user_id) AS num_devs,
  COUNT(ic.comment_id) AS num_comments
FROM
  `gfi-replication-study.gfi_dataset.closed_gfi_issues` i
LEFT JOIN
  `ghtorrentmysql1906.MySQL1906.issue_comments` ic
ON
  i.id = ic.issue_id
GROUP BY
  i.id