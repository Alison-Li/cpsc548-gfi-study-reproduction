-- DATA COLLECTION:

-- Top 500 most starred repositories in a specified language,
-- e.g. C/C++.
SELECT
  w.repo_id,
  p.name,
  COUNT(*) AS num_stars
FROM
  `ghtorrentmysql1906.MySQL1906.watchers` w,
  `ghtorrentmysql1906.MySQL1906.projects` p,
  `ghtorrentmysql1906.MySQL1906.project_languages` pl
WHERE
  w.repo_id = p.id
  AND p.id = pl.project_id
  AND (pl.language = "c"
  OR pl.language = "c++")
GROUP BY
  repo_id,
  p.name
ORDER BY
  num_stars DESC
LIMIT
  500

-- The top 500 most starred repositories in each of the following languages:
-- Java, JavaScript, C/C++, Python, Ruby, PHP.
-- Stored as a view called `initial_projects`.
(SELECT
    w.repo_id,
    p.name,
    COUNT(*) AS num_stars
  FROM
    `ghtorrentmysql1906.MySQL1906.watchers` w,
    `ghtorrentmysql1906.MySQL1906.projects` p,
    `ghtorrentmysql1906.MySQL1906.project_languages` pl
  WHERE
    w.repo_id = p.id
    AND p.id = pl.project_id
    AND pl.LANGUAGE = "python"
  GROUP BY
    repo_id,
    p.name
  ORDER BY
    num_stars DESC
  LIMIT
    500)
UNION DISTINCT (
  SELECT
    w.repo_id,
    p.name,
    COUNT(*) AS num_stars
  FROM
    `ghtorrentmysql1906.MySQL1906.watchers` w,
    `ghtorrentmysql1906.MySQL1906.projects` p,
    `ghtorrentmysql1906.MySQL1906.project_languages` pl
  WHERE
    w.repo_id = p.id
    AND p.id = pl.project_id
    AND pl.LANGUAGE = "java"
  GROUP BY
    repo_id,
    p.name
  ORDER BY
    num_stars DESC
  LIMIT
    500)
UNION DISTINCT (
  SELECT
    w.repo_id,
    p.name,
    COUNT(*) AS num_stars
  FROM
    `ghtorrentmysql1906.MySQL1906.watchers` w,
    `ghtorrentmysql1906.MySQL1906.projects` p,
    `ghtorrentmysql1906.MySQL1906.project_languages` pl
  WHERE
    w.repo_id = p.id
    AND p.id = pl.project_id
    AND pl.LANGUAGE = "javascript"
  GROUP BY
    repo_id,
    p.name
  ORDER BY
    num_stars DESC
  LIMIT
    500 )
UNION DISTINCT (
  SELECT
    w.repo_id,
    p.name,
    COUNT(*) AS num_stars
  FROM
    `ghtorrentmysql1906.MySQL1906.watchers` w,
    `ghtorrentmysql1906.MySQL1906.projects` p,
    `ghtorrentmysql1906.MySQL1906.project_languages` pl
  WHERE
    w.repo_id = p.id
    AND p.id = pl.project_id
    AND pl.LANGUAGE = "php"
  GROUP BY
    repo_id,
    p.name
  ORDER BY
    num_stars DESC
  LIMIT
    500)
UNION DISTINCT (
  SELECT
    w.repo_id,
    p.name,
    COUNT(*) AS num_stars
  FROM
    `ghtorrentmysql1906.MySQL1906.watchers` w,
    `ghtorrentmysql1906.MySQL1906.projects` p,
    `ghtorrentmysql1906.MySQL1906.project_languages` pl
  WHERE
    w.repo_id = p.id
    AND p.id = pl.project_id
    AND pl.LANGUAGE = "ruby"
  GROUP BY
    repo_id,
    p.name
  ORDER BY
    num_stars DESC
  LIMIT
    500)
UNION DISTINCT (
  SELECT
    w.repo_id,
    p.name,
    COUNT(*) AS num_stars
  FROM
    `ghtorrentmysql1906.MySQL1906.watchers` w,
    `ghtorrentmysql1906.MySQL1906.projects` p,
    `ghtorrentmysql1906.MySQL1906.project_languages` pl
  WHERE
    w.repo_id = p.id
    AND p.id = pl.project_id
    AND (pl.LANGUAGE = "c"
      OR pl.LANGUAGE = "c++")
  GROUP BY
    repo_id,
    p.name
  ORDER BY
    num_stars DESC
  LIMIT
    500)

-- From `initial_projects` view, get all the repositories with at least 50 issues.
-- Stored as a view called `filtered_projects`.
SELECT
  p.repo_id,
  COUNT(*) AS num_issues
FROM
  `gfi-replication-study.gfi_dataset.initial_projects` p,
  `ghtorrentmysql1906.MySQL1906.issues` i
WHERE
  p.repo_id = i.repo_id
GROUP BY
  p.repo_id
HAVING
  COUNT(*) >= 50
ORDER BY
  num_issues

-- From `filtered_projects` view, get all issues tagged with a GFI-synonymous label.
-- Stored as a view called `gfi_issues`.
SELECT
  i.id,
  i.issue_id AS gh_id,
  rl.name AS label,
  p.repo_id,
FROM
  `gfi-replication-study.gfi_dataset.filtered_projects` p,
  `ghtorrentmysql1906.MySQL1906.issues` i,
  `ghtorrentmysql1906.MySQL1906.issue_labels` il,
  `ghtorrentmysql1906.MySQL1906.repo_labels` rl
WHERE
  p.repo_id = i.repo_id
  AND i.id = il.issue_id
  AND il.label_id = rl.id_
  AND LOWER(rl.name) IN ("good first issue",
    "good-first-issue",
    "good first bug",
    "good-first-bug",
    "good first contribution",
    "good first task",
    "minor bug",
    "minor feature",
    "starter bug",
    "easy-pick",
    "easy to fix",
    "low hanging fruit",
    "first timers only",
    "easy",
    "newbie",
    "beginner",
    "beginner-task",
    "up-for-grabs",
    "help wanted (easy)")
  
-- From `gfi_issues`, find issues that have been closed.
-- Saved as `csv/closed_gfi_issues.csv`
SELECT
  *
FROM
  `gfi-replication-study.gfi_dataset.gfi_issues` i,
  `ghtorrentmysql1906.MySQL1906.issue_events` ie
WHERE
  i.id = ie.issue_id
  AND ie.action = "closed"

-- Distribution of issues per distinct raw GFI-synonymous label.
-- Saved as `csv/gfi_label_distribution_raw.csv`
SELECT
  i.label AS label,
  COUNT(*) AS num_issues
FROM
  `gfi-replication-study.gfi_dataset.gfi_issues` i
GROUP BY
  label
ORDER BY 
  num_issues DESC

-- Distribution of issues per (sanitized) GFI-synonymous label.
-- Similar to previous query but label string is converted to lowercase.
-- Saved as `csv/gfi_label_distribution_lowercase.csv`
SELECT
  LOWER(i.label) AS label,
  COUNT(*) AS num_issues
FROM
  `gfi-replication-study.gfi_dataset.gfi_issues` i
GROUP BY
  label
ORDER BY 
  num_issues DESC