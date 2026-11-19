-- Run after selecting the target Snowflake database, schema, and warehouse.
-- Snowflake constraints are informational unless separately enforced by the application.

CREATE TABLE IF NOT EXISTS patient (
    patient_id VARCHAR(36) NOT NULL,
    patient_number VARCHAR(30) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    sex_at_birth VARCHAR(20),
    gender VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(255),
    preferred_language VARCHAR(50),
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP_TZ NOT NULL,
    updated_at TIMESTAMP_TZ NOT NULL,
    PRIMARY KEY (patient_id),
    UNIQUE (patient_number)
);

CREATE TABLE IF NOT EXISTS patient_account (
    account_id VARCHAR(36) NOT NULL PRIMARY KEY,
    patient_id VARCHAR(36) NOT NULL UNIQUE,
    identity_provider_id VARCHAR(255) NOT NULL UNIQUE,
    login_identifier VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL,
    last_login_at TIMESTAMP_TZ,
    created_at TIMESTAMP_TZ NOT NULL
);

CREATE TABLE IF NOT EXISTS account_session (
    session_id VARCHAR(36) NOT NULL PRIMARY KEY,
    account_id VARCHAR(36) NOT NULL,
    started_at TIMESTAMP_TZ NOT NULL,
    expires_at TIMESTAMP_TZ NOT NULL,
    revoked_at TIMESTAMP_TZ,
    ip_address VARCHAR(45),
    device_context VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS patient_address (
    address_id VARCHAR(36) NOT NULL PRIMARY KEY,
    patient_id VARCHAR(36) NOT NULL,
    address_type VARCHAR(30) NOT NULL,
    line1 VARCHAR(255) NOT NULL,
    line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(30),
    country VARCHAR(100) NOT NULL,
    is_primary BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS consent (
    consent_id VARCHAR(36) NOT NULL PRIMARY KEY,
    patient_id VARCHAR(36) NOT NULL,
    consent_type VARCHAR(50) NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    granted BOOLEAN NOT NULL,
    granted_at TIMESTAMP_TZ,
    expires_at TIMESTAMP_TZ,
    revoked_at TIMESTAMP_TZ
);

CREATE TABLE IF NOT EXISTS specialty (
    specialty_id VARCHAR(36) NOT NULL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS doctor (
    doctor_id VARCHAR(36) NOT NULL PRIMARY KEY,
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(255),
    qualifications TEXT,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS doctor_specialty (
    doctor_specialty_id VARCHAR(36) NOT NULL PRIMARY KEY,
    doctor_id VARCHAR(36) NOT NULL,
    specialty_id VARCHAR(36) NOT NULL,
    is_primary BOOLEAN NOT NULL,
    UNIQUE (doctor_id, specialty_id)
);

CREATE TABLE IF NOT EXISTS facility (
    facility_id VARCHAR(36) NOT NULL PRIMARY KEY,
    facility_code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    facility_type VARCHAR(50) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(255),
    is_active BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS service_category (
    category_id VARCHAR(36) NOT NULL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS health_service (
    service_id VARCHAR(36) NOT NULL PRIMARY KEY,
    category_id VARCHAR(36) NOT NULL,
    facility_id VARCHAR(36),
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    base_price NUMBER(12, 2),
    currency_code CHAR(3),
    duration_minutes NUMBER(10, 0),
    preparation_required BOOLEAN NOT NULL,
    preparation_instructions TEXT,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS doctor_service (
    doctor_service_id VARCHAR(36) NOT NULL PRIMARY KEY,
    doctor_id VARCHAR(36) NOT NULL,
    service_id VARCHAR(36) NOT NULL,
    is_active BOOLEAN NOT NULL,
    UNIQUE (doctor_id, service_id)
);

CREATE TABLE IF NOT EXISTS doctor_availability (
    availability_id VARCHAR(36) NOT NULL PRIMARY KEY,
    doctor_id VARCHAR(36) NOT NULL,
    facility_id VARCHAR(36) NOT NULL,
    available_date DATE,
    start_time TIME,
    end_time TIME,
    slot_duration_minutes NUMBER(10, 0) NOT NULL,
    recurrence_rule VARCHAR(255),
    is_active BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS service_request (
    request_id VARCHAR(36) NOT NULL PRIMARY KEY,
    patient_id VARCHAR(36) NOT NULL,
    service_id VARCHAR(36) NOT NULL,
    doctor_id VARCHAR(36),
    appointment_id VARCHAR(36),
    request_number VARCHAR(40) NOT NULL UNIQUE,
    request_type VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    reason TEXT,
    requested_at TIMESTAMP_TZ NOT NULL,
    expires_at TIMESTAMP_TZ
);

CREATE TABLE IF NOT EXISTS appointment (
    appointment_id VARCHAR(36) NOT NULL PRIMARY KEY,
    patient_id VARCHAR(36) NOT NULL,
    doctor_id VARCHAR(36),
    facility_id VARCHAR(36),
    originating_request_id VARCHAR(36),
    booking_reference VARCHAR(40) NOT NULL UNIQUE,
    appointment_mode VARCHAR(20) NOT NULL,
    status VARCHAR(30) NOT NULL,
    start_at TIMESTAMP_TZ NOT NULL,
    end_at TIMESTAMP_TZ NOT NULL,
    timezone VARCHAR(100) NOT NULL,
    notes TEXT,
    cancellation_reason TEXT,
    booked_at TIMESTAMP_TZ NOT NULL,
    updated_at TIMESTAMP_TZ NOT NULL
);

CREATE TABLE IF NOT EXISTS appointment_service (
    appointment_service_id VARCHAR(36) NOT NULL PRIMARY KEY,
    appointment_id VARCHAR(36) NOT NULL,
    service_id VARCHAR(36) NOT NULL,
    quantity NUMBER(10, 0) NOT NULL,
    status VARCHAR(20) NOT NULL,
    UNIQUE (appointment_id, service_id)
);

CREATE TABLE IF NOT EXISTS appointment_status_history (
    status_history_id VARCHAR(36) NOT NULL PRIMARY KEY,
    appointment_id VARCHAR(36) NOT NULL,
    status VARCHAR(30) NOT NULL,
    reason TEXT,
    changed_at TIMESTAMP_TZ NOT NULL,
    changed_by_account_id VARCHAR(36)
);

CREATE TABLE IF NOT EXISTS appointment_action (
    action_id VARCHAR(36) NOT NULL PRIMARY KEY,
    appointment_id VARCHAR(36) NOT NULL,
    account_id VARCHAR(36),
    action_type VARCHAR(50) NOT NULL,
    old_status VARCHAR(30),
    new_status VARCHAR(30),
    action_at TIMESTAMP_TZ NOT NULL,
    metadata VARIANT
);

CREATE TABLE IF NOT EXISTS service_request_status_history (
    status_history_id VARCHAR(36) NOT NULL PRIMARY KEY,
    request_id VARCHAR(36) NOT NULL,
    status VARCHAR(30) NOT NULL,
    reason TEXT,
    changed_at TIMESTAMP_TZ NOT NULL
);

CREATE TABLE IF NOT EXISTS request_result (
    result_id VARCHAR(36) NOT NULL PRIMARY KEY,
    request_id VARCHAR(36) NOT NULL,
    result_status VARCHAR(30) NOT NULL,
    summary TEXT,
    reported_at TIMESTAMP_TZ,
    is_released_to_patient BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS result_document (
    document_id VARCHAR(36) NOT NULL PRIMARY KEY,
    result_id VARCHAR(36) NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    storage_key VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100),
    original_name VARCHAR(255),
    file_size NUMBER(38, 0),
    uploaded_at TIMESTAMP_TZ NOT NULL
);
