# Database Migrations with Docker Compose

Database migrations are very useful, it's basically a sequential changelog of your database schema, but how do you handle db migrations with Compose? many developers add migrations as a pre-start step on their application, which is a great pattern if you're writing a monolith, but if you have a application with 150 replicas, for every update on your app you will have one pod doing a succesful migration and 149 pods doing an empty migration.

Database migrations should be idempotent, this is, it doesn't matter how many times you execute the migration, the result should be the same. However, doing 149 attempts is not ideal (also, be aware of race conditions... this is, make sure your scripts are truly idempotent).

What we're going to see here is a slightlt different model: we will run migrations on start (or on compose up), but we will decide when we want to do it (yes, we run migrations manually). This approach is good when we still want to use migrations, but we do not use them in every release: when our software is stable enough that migrations become a not-very-common task: you still want the safeguards and guarantees that a migration provides, but you don't want to pay the start-up tax to check migrations.

The patter is very similar to the other Compose-DB examples: 

- An application API
- A Database
- A Migration script that depends on the DB