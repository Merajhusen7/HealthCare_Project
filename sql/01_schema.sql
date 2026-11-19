CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE patient (
    patient_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_number VARCHAR(30) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    sex_at_birth VARCHAR(20),
    gender VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(255),
    preferred_language VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'MERGED', 'DECEASED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE patient_account (
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL UNIQUE REFERENCES patient(patient_id),
    identity_provider_id VARCHAR(255) NOT NULL UNIQUE,
    login_identifier VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE account_session (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES patient_account(account_id),
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    ip_address VARCHAR(45),
    device_context VARCHAR(255)
);

CREATE TABLE patient_address (
    address_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patient(patient_id),
    address_type VARCHAR(30) NOT NULL,
    line1 VARCHAR(255) NOT NULL,
    line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(30),
    country VARCHAR(100) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE consent (
    consent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patient(patient_id),
    consent_type VARCHAR(50) NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    granted BOOLEAN NOT NULL,
    granted_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ
);

CREATE TABLE specialty (
    specialty_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE doctor (
    doctor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(255),
    qualifications TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE doctor_specialty (
    doctor_specialty_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id UUID NOT NULL REFERENCES doctor(doctor_id),
    specialty_id UUID NOT NULL REFERENCES specialty(specialty_id),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (doctor_id, specialty_id)
);

CREATE TABLE facility (
    facility_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    facility_code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    facility_type VARCHAR(50) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE service_category (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT
);

CREATE TABLE health_service (
    service_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES service_category(category_id),
    facility_id UUID REFERENCES facility(facility_id),
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    base_price NUMERIC(12, 2),
    currency_code CHAR(3),
    duration_minutes INTEGER CHECK (duration_minutes IS NULL OR duration_minutes > 0),
    preparation_required BOOLEAN NOT NULL DEFAULT FALSE,
    preparation_instructions TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE doctor_service (
    doctor_service_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id UUID NOT NULL REFERENCES doctor(doctor_id),
    service_id UUID NOT NULL REFERENCES health_service(service_id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (doctor_id, service_id)
);

CREATE TABLE doctor_availability (
    availability_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id UUID NOT NULL REFERENCES doctor(doctor_id),
    facility_id UUID NOT NULL REFERENCES facility(facility_id),
    available_date DATE,
    start_time TIME,
    end_time TIME,
    slot_duration_minutes INTEGER NOT NULL CHECK (slot_duration_minutes > 0),
    recurrence_rule VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (available_date IS NOT NULL OR recurrence_rule IS NOT NULL)
);

CREATE TABLE service_request (
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patient(patient_id),
    service_id UUID NOT NULL REFERENCES health_service(service_id),
    doctor_id UUID REFERENCES doctor(doctor_id),
    appointment_id UUID,
    request_number VARCHAR(40) NOT NULL UNIQUE,
    request_type VARCHAR(30) NOT NULL
        CHECK (request_type IN ('TEST', 'CHECKUP', 'CONSULTATION', 'IMAGING', 'PROCEDURE')),
    status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED'
        CHECK (status IN ('SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'SCHEDULED',
                          'COMPLETED', 'CANCELLED', 'REJECTED')),
    priority VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    reason TEXT,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ
);

CREATE TABLE appointment (
    appointment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patient(patient_id),
    doctor_id UUID REFERENCES doctor(doctor_id),
    facility_id UUID REFERENCES facility(facility_id),
    originating_request_id UUID REFERENCES service_request(request_id),
    booking_reference VARCHAR(40) NOT NULL UNIQUE,
    appointment_mode VARCHAR(20) NOT NULL
        CHECK (appointment_mode IN ('ONLINE', 'IN_PERSON')),
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT'
        CHECK (status IN ('DRAFT', 'PENDING_CONFIRMATION', 'CONFIRMED', 'CHECKED_IN',
                          'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    timezone VARCHAR(100) NOT NULL,
    notes TEXT,
    cancellation_reason TEXT,
    booked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_at > start_at)
);

ALTER TABLE service_request
    ADD CONSTRAINT fk_request_appointment
    FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id);

CREATE UNIQUE INDEX uq_request_appointment
    ON service_request (appointment_id)
    WHERE appointment_id IS NOT NULL;

CREATE TABLE appointment_service (
    appointment_service_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES appointment(appointment_id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES health_service(service_id),
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    UNIQUE (appointment_id, service_id)
);

CREATE TABLE appointment_status_history (
    status_history_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES appointment(appointment_id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL,
    reason TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_account_id UUID REFERENCES patient_account(account_id)
);

CREATE TABLE appointment_action (
    action_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES appointment(appointment_id) ON DELETE CASCADE,
    account_id UUID REFERENCES patient_account(account_id),
    action_type VARCHAR(50) NOT NULL,
    old_status VARCHAR(30),
    new_status VARCHAR(30),
    action_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

CREATE TABLE service_request_status_history (
    status_history_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES service_request(request_id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL,
    reason TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE request_result (
    result_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES service_request(request_id),
    result_status VARCHAR(30) NOT NULL
        CHECK (result_status IN ('PENDING', 'PRELIMINARY', 'FINAL', 'AMENDED', 'CORRECTED')),
    summary TEXT,
    reported_at TIMESTAMPTZ,
    is_released_to_patient BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE result_document (
    document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    result_id UUID NOT NULL REFERENCES request_result(result_id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    storage_key VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100),
    original_name VARCHAR(255),
    file_size BIGINT CHECK (file_size IS NULL OR file_size >= 0),
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_appointment_patient ON appointment(patient_id);
CREATE INDEX idx_appointment_doctor_start ON appointment(doctor_id, start_at);
CREATE INDEX idx_appointment_facility_start ON appointment(facility_id, start_at);
CREATE INDEX idx_request_patient ON service_request(patient_id);
CREATE INDEX idx_request_status ON service_request(status);
CREATE INDEX idx_availability_doctor_date ON doctor_availability(doctor_id, available_date);
