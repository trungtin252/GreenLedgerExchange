CREATE TABLE organization_snapshot (
    id UUID PRIMARY KEY,
    registry_reference VARCHAR(128) NOT NULL UNIQUE,
    display_name VARCHAR(256) NOT NULL,
    observed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_record (
    id UUID PRIMARY KEY,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actor_subject VARCHAR(256),
    correlation_id UUID NOT NULL,
    action VARCHAR(128) NOT NULL,
    subject_type VARCHAR(128) NOT NULL,
    subject_id VARCHAR(256) NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE idempotency_record (
    scope VARCHAR(128) NOT NULL,
    idempotency_key VARCHAR(256) NOT NULL,
    request_fingerprint VARCHAR(128) NOT NULL,
    first_seen_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (scope, idempotency_key)
);

CREATE TABLE outbox_event (
    id UUID PRIMARY KEY,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(256) NOT NULL,
    aggregate_reference VARCHAR(256) NOT NULL,
    correlation_id UUID NOT NULL,
    payload JSONB NOT NULL,
    published_at TIMESTAMPTZ
);

CREATE TABLE inbox_message (
    message_id UUID PRIMARY KEY,
    received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(256) NOT NULL,
    correlation_id UUID NOT NULL,
    payload JSONB NOT NULL
);

CREATE TABLE job_execution (
    id UUID PRIMARY KEY,
    job_type VARCHAR(128) NOT NULL,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    state VARCHAR(32) NOT NULL,
    correlation_id UUID NOT NULL,
    details JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX outbox_event_unpublished_idx ON outbox_event (occurred_at) WHERE published_at IS NULL;
