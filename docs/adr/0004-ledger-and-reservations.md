# ADR 0004: Double-entry ledger and reservations

When accounting flows are introduced, durable movements will be represented by
balanced journal postings and in-flight commitments by explicit reservations.
This separates available quantity or value from settled accounting truth.
