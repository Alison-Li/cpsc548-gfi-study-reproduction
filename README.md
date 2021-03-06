# Replication Study: A First Look at Good First Issues on GitHub

A repository containing the tooling used and data produced for my reproduction of experiment methodology and results from Tan et al.'s "A First Look at Good First Issues on GitHub" (2020).

## SQL Workspace

Contact me if you would like access to the Google BigQuery project and dataset I created for this study. 

Alternatively, you can access the GHTorrent dataset via  Google BigQuery and use `data_collection.sql` to create initial views and follow the comments and queries in `rq1.sql` and `rq2.sql`. All SQL files can be found in the `sql` folder at root level of the repository. **Feedback is welcome and highly encouraged** if you happen to spot any mistakes in any of the SQL queries I used.

## Resources

* [GHTorrent Google BigQuery](https://t.co/k8Oq1oD8uV?amp=1): Publicly available GHTorrent dump, dated "2019-06-01."

* [GHTorrent Relational Schema](https://ghtorrent.org/relational.html): Useful for interpreting tables and querying them on the GHTorrent dataset.