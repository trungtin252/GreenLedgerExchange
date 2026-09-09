# ADR 0005: Outbox and inbox delivery

Cross-runtime domain events use a transactional outbox and idempotent inboxes.
Delivery is at least once, while consumers make repeat delivery safe with
deduplication and recorded processing state.
