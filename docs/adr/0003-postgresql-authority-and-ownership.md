# ADR 0003: PostgreSQL authority and ownership

PostgreSQL is the authoritative system of record. Registry and Exchange have
separate databases, Flyway histories, migrator roles, and least-privilege
runtime roles so that a service cannot create schema or read the other service's data.
