--
-- PostgreSQL database dump
--

\restrict O2p3hzEmUqpW1U5Drpe70u6khurFHt2KWKRBbnIQaUUUqxINhjLMFg5nlmQaQDw

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.submissions DROP CONSTRAINT IF EXISTS submissions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submissions DROP CONSTRAINT IF EXISTS submissions_reviewer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submissions DROP CONSTRAINT IF EXISTS submissions_modification_class_fkey;
ALTER TABLE IF EXISTS ONLY public.post_market_monitoring DROP CONSTRAINT IF EXISTS post_market_monitoring_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.post_market_monitoring DROP CONSTRAINT IF EXISTS post_market_monitoring_reported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.modification_risk_scores DROP CONSTRAINT IF EXISTS modification_risk_scores_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.modification_risk_scores DROP CONSTRAINT IF EXISTS modification_risk_scores_modification_class_fkey;
ALTER TABLE IF EXISTS ONLY public.governance_evidence DROP CONSTRAINT IF EXISTS governance_evidence_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.governance_evidence DROP CONSTRAINT IF EXISTS governance_evidence_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.governance_approvals DROP CONSTRAINT IF EXISTS governance_approvals_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.governance_approvals DROP CONSTRAINT IF EXISTS governance_approvals_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.governance_approvals DROP CONSTRAINT IF EXISTS governance_approvals_approver_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.conformity_assessments DROP CONSTRAINT IF EXISTS conformity_assessments_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.comments DROP CONSTRAINT IF EXISTS comments_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.comments DROP CONSTRAINT IF EXISTS comments_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.artifacts DROP CONSTRAINT IF EXISTS artifacts_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_reviews DROP CONSTRAINT IF EXISTS ai_reviews_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_incidents DROP CONSTRAINT IF EXISTS ai_incidents_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_incidents DROP CONSTRAINT IF EXISTS ai_incidents_reported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_incidents DROP CONSTRAINT IF EXISTS ai_incidents_assigned_to_fkey;
DROP INDEX IF EXISTS public.idx_submissions_user_id;
DROP INDEX IF EXISTS public.idx_submissions_status;
DROP INDEX IF EXISTS public.idx_submissions_modification_class;
DROP INDEX IF EXISTS public.idx_submissions_created_at;
DROP INDEX IF EXISTS public.idx_submissions_conformity_status;
DROP INDEX IF EXISTS public.idx_post_market_monitoring_submission;
DROP INDEX IF EXISTS public.idx_modification_risk_scores_submission;
DROP INDEX IF EXISTS public.idx_governance_evidence_submission;
DROP INDEX IF EXISTS public.idx_governance_approvals_submission;
DROP INDEX IF EXISTS public.idx_governance_approvals_status;
DROP INDEX IF EXISTS public.idx_conformity_assessments_submission;
DROP INDEX IF EXISTS public.idx_comments_submission_id;
DROP INDEX IF EXISTS public.idx_audit_log_submission_id;
DROP INDEX IF EXISTS public.idx_artifacts_submission_id;
DROP INDEX IF EXISTS public.idx_ai_reviews_submission_id;
DROP INDEX IF EXISTS public.idx_ai_incidents_submission;
DROP INDEX IF EXISTS public.idx_ai_incidents_severity;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.submissions DROP CONSTRAINT IF EXISTS submissions_pkey;
ALTER TABLE IF EXISTS ONLY public.ref_vendors DROP CONSTRAINT IF EXISTS ref_vendors_pkey;
ALTER TABLE IF EXISTS ONLY public.ref_vendors DROP CONSTRAINT IF EXISTS ref_vendors_name_key;
ALTER TABLE IF EXISTS ONLY public.ref_use_cases DROP CONSTRAINT IF EXISTS ref_use_cases_pkey;
ALTER TABLE IF EXISTS ONLY public.ref_safety_features DROP CONSTRAINT IF EXISTS ref_safety_features_pkey;
ALTER TABLE IF EXISTS ONLY public.ref_regulatory_frameworks DROP CONSTRAINT IF EXISTS ref_regulatory_frameworks_pkey;
ALTER TABLE IF EXISTS ONLY public.ref_models DROP CONSTRAINT IF EXISTS ref_models_pkey;
ALTER TABLE IF EXISTS ONLY public.ref_deployment_platforms DROP CONSTRAINT IF EXISTS ref_deployment_platforms_pkey;
ALTER TABLE IF EXISTS ONLY public.ref_data_sources DROP CONSTRAINT IF EXISTS ref_data_sources_pkey;
ALTER TABLE IF EXISTS ONLY public.post_market_monitoring DROP CONSTRAINT IF EXISTS post_market_monitoring_pkey;
ALTER TABLE IF EXISTS ONLY public.modification_risk_scores DROP CONSTRAINT IF EXISTS modification_risk_scores_pkey;
ALTER TABLE IF EXISTS ONLY public.modification_classes DROP CONSTRAINT IF EXISTS modification_classes_pkey;
ALTER TABLE IF EXISTS ONLY public.modification_classes DROP CONSTRAINT IF EXISTS modification_classes_class_number_key;
ALTER TABLE IF EXISTS ONLY public.governance_roles DROP CONSTRAINT IF EXISTS governance_roles_role_name_key;
ALTER TABLE IF EXISTS ONLY public.governance_roles DROP CONSTRAINT IF EXISTS governance_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.governance_evidence DROP CONSTRAINT IF EXISTS governance_evidence_pkey;
ALTER TABLE IF EXISTS ONLY public.governance_approvals DROP CONSTRAINT IF EXISTS governance_approvals_pkey;
ALTER TABLE IF EXISTS ONLY public.conformity_assessments DROP CONSTRAINT IF EXISTS conformity_assessments_pkey;
ALTER TABLE IF EXISTS ONLY public.comments DROP CONSTRAINT IF EXISTS comments_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
ALTER TABLE IF EXISTS ONLY public.artifacts DROP CONSTRAINT IF EXISTS artifacts_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_reviews DROP CONSTRAINT IF EXISTS ai_reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_incidents DROP CONSTRAINT IF EXISTS ai_incidents_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.submissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ref_vendors ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ref_use_cases ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ref_safety_features ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ref_regulatory_frameworks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ref_models ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ref_deployment_platforms ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ref_data_sources ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.post_market_monitoring ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.modification_risk_scores ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.modification_classes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.governance_roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.governance_evidence ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.governance_approvals ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.conformity_assessments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.comments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.audit_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.artifacts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ai_reviews ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ai_incidents ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.submissions_id_seq;
DROP TABLE IF EXISTS public.submissions;
DROP SEQUENCE IF EXISTS public.ref_vendors_id_seq;
DROP TABLE IF EXISTS public.ref_vendors;
DROP SEQUENCE IF EXISTS public.ref_use_cases_id_seq;
DROP TABLE IF EXISTS public.ref_use_cases;
DROP SEQUENCE IF EXISTS public.ref_safety_features_id_seq;
DROP TABLE IF EXISTS public.ref_safety_features;
DROP SEQUENCE IF EXISTS public.ref_regulatory_frameworks_id_seq;
DROP TABLE IF EXISTS public.ref_regulatory_frameworks;
DROP SEQUENCE IF EXISTS public.ref_models_id_seq;
DROP TABLE IF EXISTS public.ref_models;
DROP SEQUENCE IF EXISTS public.ref_deployment_platforms_id_seq;
DROP TABLE IF EXISTS public.ref_deployment_platforms;
DROP SEQUENCE IF EXISTS public.ref_data_sources_id_seq;
DROP TABLE IF EXISTS public.ref_data_sources;
DROP SEQUENCE IF EXISTS public.post_market_monitoring_id_seq;
DROP TABLE IF EXISTS public.post_market_monitoring;
DROP SEQUENCE IF EXISTS public.modification_risk_scores_id_seq;
DROP TABLE IF EXISTS public.modification_risk_scores;
DROP SEQUENCE IF EXISTS public.modification_classes_id_seq;
DROP TABLE IF EXISTS public.modification_classes;
DROP SEQUENCE IF EXISTS public.governance_roles_id_seq;
DROP TABLE IF EXISTS public.governance_roles;
DROP SEQUENCE IF EXISTS public.governance_evidence_id_seq;
DROP TABLE IF EXISTS public.governance_evidence;
DROP SEQUENCE IF EXISTS public.governance_approvals_id_seq;
DROP TABLE IF EXISTS public.governance_approvals;
DROP SEQUENCE IF EXISTS public.conformity_assessments_id_seq;
DROP TABLE IF EXISTS public.conformity_assessments;
DROP SEQUENCE IF EXISTS public.comments_id_seq;
DROP TABLE IF EXISTS public.comments;
DROP SEQUENCE IF EXISTS public.audit_log_id_seq;
DROP TABLE IF EXISTS public.audit_log;
DROP SEQUENCE IF EXISTS public.artifacts_id_seq;
DROP TABLE IF EXISTS public.artifacts;
DROP SEQUENCE IF EXISTS public.ai_reviews_id_seq;
DROP TABLE IF EXISTS public.ai_reviews;
DROP SEQUENCE IF EXISTS public.ai_incidents_id_seq;
DROP TABLE IF EXISTS public.ai_incidents;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_incidents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_incidents (
    id integer NOT NULL,
    submission_id integer,
    incident_date timestamp without time zone NOT NULL,
    incident_type character varying(100) NOT NULL,
    severity character varying(50),
    description text NOT NULL,
    affected_users integer,
    harm_caused text,
    root_cause text,
    corrective_actions text,
    preventive_actions text,
    reported_to_authorities boolean DEFAULT false,
    authority_notification_date timestamp without time zone,
    authority_response text,
    status character varying(50),
    reported_by integer,
    assigned_to integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ai_incidents_severity_check CHECK (((severity)::text = ANY ((ARRAY['minor'::character varying, 'major'::character varying, 'critical'::character varying])::text[]))),
    CONSTRAINT ai_incidents_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'investigating'::character varying, 'resolved'::character varying, 'closed'::character varying])::text[])))
);


--
-- Name: TABLE ai_incidents; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ai_incidents IS 'EU AI Act Article 62 serious incident reporting';


--
-- Name: ai_incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_incidents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_incidents_id_seq OWNED BY public.ai_incidents.id;


--
-- Name: ai_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_reviews (
    id integer NOT NULL,
    submission_id integer,
    review_type character varying(50) NOT NULL,
    risk_score integer,
    risk_level character varying(20),
    approval_recommendation character varying(50),
    findings jsonb NOT NULL,
    regulatory_concerns jsonb,
    security_concerns jsonb,
    data_privacy_concerns jsonb,
    bias_concerns jsonb,
    recommendations jsonb,
    required_actions jsonb,
    pii_detected boolean,
    pii_details jsonb,
    vendor_evaluation jsonb,
    full_review text,
    reviewed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ai_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_reviews_id_seq OWNED BY public.ai_reviews.id;


--
-- Name: artifacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artifacts (
    id integer NOT NULL,
    submission_id integer,
    file_name character varying(255) NOT NULL,
    file_path character varying(500) NOT NULL,
    file_type character varying(100),
    file_size integer,
    artifact_type character varying(100),
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: artifacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artifacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artifacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artifacts_id_seq OWNED BY public.artifacts.id;


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log (
    id integer NOT NULL,
    submission_id integer,
    user_id integer,
    action character varying(100) NOT NULL,
    details jsonb,
    ip_address character varying(45),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    submission_id integer,
    user_id integer,
    comment text NOT NULL,
    is_internal boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: conformity_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conformity_assessments (
    id integer NOT NULL,
    submission_id integer,
    assessment_type character varying(50),
    assessment_date timestamp without time zone,
    assessor_name character varying(255),
    assessor_organization character varying(255),
    general_description text,
    intended_purpose text,
    risk_management_system jsonb,
    data_governance_measures jsonb,
    technical_documentation jsonb,
    transparency_provisions jsonb,
    human_oversight_measures jsonb,
    accuracy_robustness_measures jsonb,
    conformity_status character varying(50),
    non_conformities text[],
    remediation_plan text,
    next_assessment_date date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT conformity_assessments_assessment_type_check CHECK (((assessment_type)::text = ANY ((ARRAY['self_assessment'::character varying, 'third_party'::character varying, 'notified_body'::character varying])::text[]))),
    CONSTRAINT conformity_assessments_conformity_status_check CHECK (((conformity_status)::text = ANY ((ARRAY['conformant'::character varying, 'non_conformant'::character varying, 'conditional'::character varying, 'pending'::character varying])::text[])))
);


--
-- Name: TABLE conformity_assessments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.conformity_assessments IS 'EU AI Act Annex IV conformity assessment documentation';


--
-- Name: conformity_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conformity_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conformity_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conformity_assessments_id_seq OWNED BY public.conformity_assessments.id;


--
-- Name: governance_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.governance_approvals (
    id integer NOT NULL,
    submission_id integer,
    role_id integer,
    approver_user_id integer,
    approval_status character varying(50),
    approval_date timestamp without time zone,
    comments text,
    evidence_reviewed text[],
    conditions text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT governance_approvals_approval_status_check CHECK (((approval_status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying, 'needs_info'::character varying])::text[])))
);


--
-- Name: TABLE governance_approvals; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.governance_approvals IS 'Tracks multi-stakeholder approval workflow based on modification class';


--
-- Name: governance_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.governance_approvals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: governance_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.governance_approvals_id_seq OWNED BY public.governance_approvals.id;


--
-- Name: governance_evidence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.governance_evidence (
    id integer NOT NULL,
    submission_id integer,
    evidence_type character varying(100) NOT NULL,
    evidence_category character varying(100),
    file_path character varying(500),
    metadata jsonb,
    uploaded_by integer,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: governance_evidence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.governance_evidence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: governance_evidence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.governance_evidence_id_seq OWNED BY public.governance_evidence.id;


--
-- Name: governance_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.governance_roles (
    id integer NOT NULL,
    role_name character varying(100) NOT NULL,
    role_description text,
    responsibilities text[],
    required_for_classes integer[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: governance_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.governance_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: governance_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.governance_roles_id_seq OWNED BY public.governance_roles.id;


--
-- Name: modification_classes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modification_classes (
    id integer NOT NULL,
    class_number integer NOT NULL,
    class_name character varying(100) NOT NULL,
    risk_level character varying(50) NOT NULL,
    eu_ai_act_category character varying(100),
    iso_42001_focus text,
    description text NOT NULL,
    obligations jsonb NOT NULL,
    approval_requirements jsonb NOT NULL,
    required_evidence text[],
    monitoring_requirements text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT modification_classes_class_number_check CHECK (((class_number >= 0) AND (class_number <= 6))),
    CONSTRAINT modification_classes_risk_level_check CHECK (((risk_level)::text = ANY ((ARRAY['Low'::character varying, 'Medium'::character varying, 'Medium-High'::character varying, 'High'::character varying, 'Very High'::character varying])::text[])))
);


--
-- Name: TABLE modification_classes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.modification_classes IS 'ISO/IEC 42001 + EU AI Act aligned model modification classification system';


--
-- Name: modification_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modification_classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modification_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modification_classes_id_seq OWNED BY public.modification_classes.id;


--
-- Name: modification_risk_scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modification_risk_scores (
    id integer NOT NULL,
    submission_id integer,
    modification_class integer,
    licensing_risk integer,
    data_governance_risk integer,
    safety_alignment_risk integer,
    transparency_risk integer,
    security_risk integer,
    compliance_risk integer,
    overall_risk_score integer,
    risk_factors jsonb,
    calculated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT modification_risk_scores_compliance_risk_check CHECK (((compliance_risk >= 0) AND (compliance_risk <= 100))),
    CONSTRAINT modification_risk_scores_data_governance_risk_check CHECK (((data_governance_risk >= 0) AND (data_governance_risk <= 100))),
    CONSTRAINT modification_risk_scores_licensing_risk_check CHECK (((licensing_risk >= 0) AND (licensing_risk <= 100))),
    CONSTRAINT modification_risk_scores_overall_risk_score_check CHECK (((overall_risk_score >= 0) AND (overall_risk_score <= 100))),
    CONSTRAINT modification_risk_scores_safety_alignment_risk_check CHECK (((safety_alignment_risk >= 0) AND (safety_alignment_risk <= 100))),
    CONSTRAINT modification_risk_scores_security_risk_check CHECK (((security_risk >= 0) AND (security_risk <= 100))),
    CONSTRAINT modification_risk_scores_transparency_risk_check CHECK (((transparency_risk >= 0) AND (transparency_risk <= 100)))
);


--
-- Name: TABLE modification_risk_scores; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.modification_risk_scores IS 'Risk scoring tied to modification class requirements';


--
-- Name: modification_risk_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modification_risk_scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modification_risk_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modification_risk_scores_id_seq OWNED BY public.modification_risk_scores.id;


--
-- Name: post_market_monitoring; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_market_monitoring (
    id integer NOT NULL,
    submission_id integer,
    monitoring_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    monitoring_type character varying(100),
    performance_metrics jsonb,
    drift_detected boolean DEFAULT false,
    drift_details text,
    safety_incidents integer DEFAULT 0,
    incident_details jsonb,
    bias_metrics jsonb,
    bias_concerns text,
    user_complaints integer DEFAULT 0,
    complaint_summary text,
    actions_required boolean DEFAULT false,
    actions_taken text,
    reported_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE post_market_monitoring; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.post_market_monitoring IS 'ISO 42001 + EU AI Act post-deployment monitoring requirements';


--
-- Name: post_market_monitoring_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_market_monitoring_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_market_monitoring_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_market_monitoring_id_seq OWNED BY public.post_market_monitoring.id;


--
-- Name: ref_data_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ref_data_sources (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sensitivity character varying(50),
    pii boolean,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ref_data_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ref_data_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ref_data_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ref_data_sources_id_seq OWNED BY public.ref_data_sources.id;


--
-- Name: ref_deployment_platforms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ref_deployment_platforms (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    provider character varying(100),
    type character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ref_deployment_platforms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ref_deployment_platforms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ref_deployment_platforms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ref_deployment_platforms_id_seq OWNED BY public.ref_deployment_platforms.id;


--
-- Name: ref_models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ref_models (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    vendor character varying(255),
    type character varying(100),
    version character varying(100),
    category character varying(50),
    parameters character varying(50),
    description text,
    use_cases text,
    license character varying(100),
    documentation_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ref_models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ref_models_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ref_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ref_models_id_seq OWNED BY public.ref_models.id;


--
-- Name: ref_regulatory_frameworks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ref_regulatory_frameworks (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    applies_to jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ref_regulatory_frameworks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ref_regulatory_frameworks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ref_regulatory_frameworks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ref_regulatory_frameworks_id_seq OWNED BY public.ref_regulatory_frameworks.id;


--
-- Name: ref_safety_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ref_safety_features (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ref_safety_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ref_safety_features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ref_safety_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ref_safety_features_id_seq OWNED BY public.ref_safety_features.id;


--
-- Name: ref_use_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ref_use_cases (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    category character varying(100),
    risk_level character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ref_use_cases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ref_use_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ref_use_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ref_use_cases_id_seq OWNED BY public.ref_use_cases.id;


--
-- Name: ref_vendors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ref_vendors (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    industry character varying(100),
    website character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ref_vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ref_vendors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ref_vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ref_vendors_id_seq OWNED BY public.ref_vendors.id;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id integer NOT NULL,
    user_id integer,
    project_name character varying(255) NOT NULL,
    model_name character varying(255) NOT NULL,
    model_type character varying(100) NOT NULL,
    model_type_other character varying(255),
    model_origin character varying(50) NOT NULL,
    model_origin_name character varying(255),
    model_origin_version character varying(100),
    model_origin_url text,
    vendor_name character varying(255),
    intended_purpose text NOT NULL,
    business_impact_category character varying(50) NOT NULL,
    regulated_decisions jsonb DEFAULT '[]'::jsonb,
    human_in_loop boolean NOT NULL,
    data_sources text NOT NULL,
    contains_customer_data character varying(20),
    labels_modified boolean,
    labels_description text,
    modifications jsonb DEFAULT '[]'::jsonb,
    training_config_location text,
    deployment_location character varying(100) NOT NULL,
    deployment_location_other character varying(255),
    access_teams text,
    input_format character varying(255),
    output_format character varying(255),
    sees_sensitive_data character varying(20),
    safety_features jsonb DEFAULT '[]'::jsonb,
    known_risks text,
    status character varying(50) DEFAULT 'submitted'::character varying,
    submitted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reviewed_at timestamp without time zone,
    reviewer_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    modification_class integer,
    governance_data jsonb DEFAULT '{}'::jsonb,
    conformity_status character varying(50) DEFAULT 'pending'::character varying,
    iso_42001_compliant boolean DEFAULT false,
    eu_ai_act_compliant boolean DEFAULT false
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    role character varying(50) DEFAULT 'user'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: ai_incidents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_incidents ALTER COLUMN id SET DEFAULT nextval('public.ai_incidents_id_seq'::regclass);


--
-- Name: ai_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_reviews ALTER COLUMN id SET DEFAULT nextval('public.ai_reviews_id_seq'::regclass);


--
-- Name: artifacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artifacts ALTER COLUMN id SET DEFAULT nextval('public.artifacts_id_seq'::regclass);


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: conformity_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conformity_assessments ALTER COLUMN id SET DEFAULT nextval('public.conformity_assessments_id_seq'::regclass);


--
-- Name: governance_approvals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_approvals ALTER COLUMN id SET DEFAULT nextval('public.governance_approvals_id_seq'::regclass);


--
-- Name: governance_evidence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_evidence ALTER COLUMN id SET DEFAULT nextval('public.governance_evidence_id_seq'::regclass);


--
-- Name: governance_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_roles ALTER COLUMN id SET DEFAULT nextval('public.governance_roles_id_seq'::regclass);


--
-- Name: modification_classes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modification_classes ALTER COLUMN id SET DEFAULT nextval('public.modification_classes_id_seq'::regclass);


--
-- Name: modification_risk_scores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modification_risk_scores ALTER COLUMN id SET DEFAULT nextval('public.modification_risk_scores_id_seq'::regclass);


--
-- Name: post_market_monitoring id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_market_monitoring ALTER COLUMN id SET DEFAULT nextval('public.post_market_monitoring_id_seq'::regclass);


--
-- Name: ref_data_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_data_sources ALTER COLUMN id SET DEFAULT nextval('public.ref_data_sources_id_seq'::regclass);


--
-- Name: ref_deployment_platforms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_deployment_platforms ALTER COLUMN id SET DEFAULT nextval('public.ref_deployment_platforms_id_seq'::regclass);


--
-- Name: ref_models id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_models ALTER COLUMN id SET DEFAULT nextval('public.ref_models_id_seq'::regclass);


--
-- Name: ref_regulatory_frameworks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_regulatory_frameworks ALTER COLUMN id SET DEFAULT nextval('public.ref_regulatory_frameworks_id_seq'::regclass);


--
-- Name: ref_safety_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_safety_features ALTER COLUMN id SET DEFAULT nextval('public.ref_safety_features_id_seq'::regclass);


--
-- Name: ref_use_cases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_use_cases ALTER COLUMN id SET DEFAULT nextval('public.ref_use_cases_id_seq'::regclass);


--
-- Name: ref_vendors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_vendors ALTER COLUMN id SET DEFAULT nextval('public.ref_vendors_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: ai_incidents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_incidents (id, submission_id, incident_date, incident_type, severity, description, affected_users, harm_caused, root_cause, corrective_actions, preventive_actions, reported_to_authorities, authority_notification_date, authority_response, status, reported_by, assigned_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ai_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_reviews (id, submission_id, review_type, risk_score, risk_level, approval_recommendation, findings, regulatory_concerns, security_concerns, data_privacy_concerns, bias_concerns, recommendations, required_actions, pii_detected, pii_details, vendor_evaluation, full_review, reviewed_at, created_at) FROM stdin;
1	6	automated	85	HIGH	REQUIRES_REVIEW	[{"category": "Model-Use Case Mismatch", "severity": "HIGH", "regulation": "SR 11-7", "description": "ALBERT XXL is designed for NLP classification tasks, not AML transaction monitoring. Using a text classification model for financial transaction analysis creates significant model risk."}, {"category": "Regulatory Decision Making", "severity": "CRITICAL", "regulation": "ECOA, BSA/AML", "description": "Model makes regulated decisions under ECOA/Reg B and AML/BSA without human oversight, creating significant compliance risk."}, {"category": "Data Privacy Violation", "severity": "HIGH", "regulation": "GLBA, CCPA", "description": "Multiple PII-rich data sources processed without adequate privacy controls for financial services."}, {"category": "Model Risk Management", "severity": "HIGH", "regulation": "SR 11-7", "description": "Significant modifications (RAG + fine-tuning) to open-source model without proper validation framework."}, {"category": "AML Compliance Gap", "severity": "HIGH", "regulation": "BSA/AML, USA PATRIOT Act", "description": "AML transaction monitoring requires specialized models trained on financial crime patterns, not general NLP models."}]	["ECOA/Reg B compliance for credit decisions without human review", "BSA/AML requirements for transaction monitoring accuracy and completeness", "GLBA privacy requirements for customer financial data", "SR 11-7 model risk management for high-risk deployment", "FFIEC guidance on AI/ML governance and validation", "Potential fair lending violations due to model limitations"]	["On-premises GPU deployment security controls undefined", "RAG system introduces additional attack vectors", "Model fine-tuning data security during training process", "Access controls for sensitive financial data processing", "Model artifact security and version control"]	["Customer financial statements contain extensive PII/PHI", "Email communications likely contain personal identifiers", "Contract documents may include SSNs, account numbers", "Customer support tickets contain personal information", "Cross-border data transfer implications unclear", "Data retention and deletion policies not specified"]	["ALBERT training data may not represent diverse financial populations", "Fine-tuning data could introduce demographic biases", "AML false positive rates may disproportionately affect protected classes", "Model may exhibit bias against non-English communications", "Lack of bias testing framework for financial decisions"]	["Implement comprehensive model validation program per SR 11-7", "Establish human oversight for all regulated decisions", "Conduct thorough bias testing across protected classes", "Implement data minimization and privacy-by-design principles", "Develop AML-specific model performance benchmarks", "Create incident response plan for model failures", "Establish ongoing monitoring and model drift detection", "Implement explainability framework for regulatory compliance"]	["MANDATORY: Implement human-in-the-loop for all credit and AML decisions", "MANDATORY: Complete comprehensive model validation including bias testing", "MANDATORY: Establish data privacy impact assessment and controls", "MANDATORY: Develop AML-specific performance validation framework", "MANDATORY: Create detailed model documentation per SR 11-7", "MANDATORY: Implement ongoing monitoring and governance framework", "MANDATORY: Obtain legal review for ECOA/Reg B compliance", "MANDATORY: Establish vendor risk assessment for Hugging Face dependency"]	t	{"pii_types": ["SSN/TIN", "Account Numbers", "Email Addresses", "Names and Addresses", "Financial Account Information", "Transaction Details"], "risk_level": "HIGH", "high_risk_sources": ["Financial Statements", "Contract Documents", "Email Communications", "Customer Support Tickets"]}	\N	```json\n{\n  "risk_score": 85,\n  "risk_level": "HIGH",\n  "approval_recommendation": "REQUIRES_REVIEW",\n  "findings": [\n    {\n      "category": "Model-Use Case Mismatch",\n      "severity": "HIGH",\n      "description": "ALBERT XXL is designed for NLP classification tasks, not AML transaction monitoring. Using a text classification model for financial transaction analysis creates significant model risk.",\n      "regulation": "SR 11-7"\n    },\n    {\n      "category": "Regulatory Decision Making",\n      "severity": "CRITICAL",\n      "description": "Model makes regulated decisions under ECOA/Reg B and AML/BSA without human oversight, creating significant compliance risk.",\n      "regulation": "ECOA, BSA/AML"\n    },\n    {\n      "category": "Data Privacy Violation",\n      "severity": "HIGH",\n      "description": "Multiple PII-rich data sources processed without adequate privacy controls for financial services.",\n      "regulation": "GLBA, CCPA"\n    },\n    {\n      "category": "Model Risk Management",\n      "severity": "HIGH",\n      "description": "Significant modifications (RAG + fine-tuning) to open-source model without proper validation framework.",\n      "regulation": "SR 11-7"\n    },\n    {\n      "category": "AML Compliance Gap",\n      "severity": "HIGH",\n      "description": "AML transaction monitoring requires specialized models trained on financial crime patterns, not general NLP models.",\n      "regulation": "BSA/AML, USA PATRIOT Act"\n    }\n  ],\n  "regulatory_concerns": [\n    "ECOA/Reg B compliance for credit decisions without human review",\n    "BSA/AML requirements for transaction monitoring accuracy and completeness",\n    "GLBA privacy requirements for customer financial data",\n    "SR 11-7 model risk management for high-risk deployment",\n    "FFIEC guidance on AI/ML governance and validation",\n    "Potential fair lending violations due to model limitations"\n  ],\n  "security_concerns": [\n    "On-premises GPU deployment security controls undefined",\n    "RAG system introduces additional attack vectors",\n    "Model fine-tuning data security during training process",\n    "Access controls for sensitive financial data processing",\n    "Model artifact security and version control"\n  ],\n  "data_privacy_concerns": [\n    "Customer financial statements contain extensive PII/PHI",\n    "Email communications likely contain personal identifiers",\n    "Contract documents may include SSNs, account numbers",\n    "Customer support tickets contain personal information",\n    "Cross-border data transfer implications unclear",\n    "Data retention and deletion policies not specified"\n  ],\n  "bias_concerns": [\n    "ALBERT training data may not represent diverse financial populations",\n    "Fine-tuning data could introduce demographic biases",\n    "AML false positive rates may disproportionately affect protected classes",\n    "Model may exhibit bias against non-English communications",\n    "Lack of bias testing framework for financial decisions"\n  ],\n  "recommendations": [\n    "Implement comprehensive model validation program per SR 11-7",\n    "Establish human oversight for all regulated decisions",\n    "Conduct thorough bias testing across protected classes",\n    "Implement data minimization and privacy-by-design principles",\n    "Develop AML-specific model performance benchmarks",\n    "Create incident response plan for model failures",\n    "Establish ongoing monitoring and model drift detection",\n    "Implement explainability framework for regulatory compliance"\n  ],\n  "required_actions": [\n    "MANDATORY: Implement human-in-the-loop for all credit and AML decisions",\n    "MANDATORY: Complete comprehensive model validation including bias testing",\n    "MANDATORY: Establish data privacy impact assessment and controls",\n    "MANDATORY: Develop AML-specific performance validation framework",\n    "MANDATORY: Create detailed model documentation per SR 11-7",\n    "MANDATORY: Implement ongoing monitoring and governance framework",\n    "MANDATORY: Obtain legal review for ECOA/Reg B compliance",\n    "MANDATORY: Establish vendor risk assessment for Hugging Face dependency"\n  ],\n  "pii_detected": true,\n  "pii_details": {\n    "high_risk_sources": [\n      "Financial Statements",\n      "Contract Documents", \n      "Email Communications",\n      "Customer Support Tickets"\n    ],\n    "pii_types": [\n      "SSN/TIN",\n      "Account Numbers",\n      "Email Addresses",\n      "Names and Addresses",\n      "Financial Account Information",\n      "Transaction Details"\n    ],\n    "risk_level": "HIGH"\n  },\n  "vendor_evaluation": {\n    "vendor_name": "Hugging Face",\n    "reputation": "GOOD",\n    "license_risk": "LOW",\n    "license_type": "Apache 2.0",\n    "documentation_quality": "GOOD",\n    "model_suitability": "POOR",\n    "support_availability": "COMMUNITY",\n    "security_posture": "MODERATE",\n    "compliance_documentation": "LIMITED",\n    "overall_vendor_risk": "MEDIUM",\n    "concerns": [\n      "Model not designed for financial services use cases",\n      "Limited compliance documentation for regulated industries",\n      "Community support model may not meet enterprise SLA requirements",\n      "No financial services specific validation or testing"\n    ]\n  }\n}\n```	2025-11-15 04:24:13.303184	2025-11-15 04:24:13.303184
2	7	automated	95	CRITICAL	DENIED	[{"category": "Model Modifications", "severity": "CRITICAL", "description": "Multiple model modifications (fine-tuning, prompt engineering, safety alignment) applied to CodeLlama 34B create significant validation requirements and risk of degraded safety features. Modified models require comprehensive re-validation under SR 11-7."}, {"category": "Regulatory Compliance", "severity": "CRITICAL", "description": "Code generation model being used for regulated credit, fraud, and identity verification decisions violates ECOA/Reg B, FFIEC guidance, and AML/BSA requirements. Code generation models are not designed for financial decision-making."}, {"category": "Use Case Misalignment", "severity": "CRITICAL", "description": "CodeLlama 34B is designed for programming assistance, not financial services decision-making. Using it for credit, fraud, and KYC decisions represents fundamental misuse of the model's intended capabilities."}, {"category": "Human Oversight", "severity": "CRITICAL", "description": "No human-in-the-loop for high-impact regulated decisions violates SR 11-7 requirements and regulatory expectations for automated decision-making in financial services."}, {"category": "Data Privacy", "severity": "HIGH", "description": "Model processes application forms, contracts, and customer support tickets containing extensive PII without adequate protection mechanisms for a code generation model."}, {"category": "License Compliance", "severity": "HIGH", "description": "Llama 2 Community License may restrict commercial use in financial services applications, particularly for regulated decision-making."}]	["ECOA/Reg B violation - using code generation model for credit decisions", "FFIEC guidance non-compliance for fraud detection systems", "AML/BSA requirements not met for identity verification", "KYC/CIP compliance issues with automated identity decisions", "SR 11-7 Model Risk Management violations - inadequate validation of modified model", "NIST AI Risk Management Framework non-compliance for high-risk AI system"]	["Code generation model exposed to sensitive financial data", "Cloud GPU deployment increases attack surface for sensitive operations", "Modified model may have compromised security features", "Inadequate access controls for regulated decision system"]	["Application forms contain extensive PII (SSN, income, employment)", "Contract documents include personal and financial information", "Customer support tickets may contain account details and personal data", "GLBA compliance at risk due to inappropriate model for financial data", "PII redaction may be insufficient for code generation model processing"]	["Code generation model not designed to handle protected class considerations", "Fine-tuning modifications may introduce discriminatory patterns", "No bias testing framework appropriate for financial decision-making", "Potential for disparate impact in credit and fraud decisions", "Modified model lacks fairness validation for regulated decisions"]	["Immediately halt deployment - fundamental use case misalignment", "Select appropriate model designed for financial services decision-making", "Implement mandatory human-in-the-loop for all regulated decisions", "Conduct comprehensive model validation under SR 11-7 framework", "Perform bias testing and fairness validation for protected classes", "Review and ensure license compliance for commercial financial use", "Implement enhanced PII protection and data governance controls"]	["STOP: Do not deploy - critical regulatory violations identified", "Conduct legal review of Llama 2 Community License for intended use", "Perform complete model risk assessment under SR 11-7", "Implement comprehensive bias and fairness testing framework", "Establish human oversight requirements for all decisions", "Conduct privacy impact assessment for PII handling", "Validate all model modifications through independent testing", "Obtain regulatory approval for AI system in regulated decisions"]	t	{"types": ["SSN", "Financial Information", "Personal Identifiers", "Account Details", "Employment Information"], "sources": ["Application Forms", "Contract Documents", "Customer Support Tickets"], "risk_level": "HIGH", "protection_adequacy": "INSUFFICIENT"}	\N	```json\n{\n  "risk_score": 95,\n  "risk_level": "CRITICAL",\n  "approval_recommendation": "DENIED",\n  "findings": [\n    {\n      "category": "Model Modifications",\n      "severity": "CRITICAL",\n      "description": "Multiple model modifications (fine-tuning, prompt engineering, safety alignment) applied to CodeLlama 34B create significant validation requirements and risk of degraded safety features. Modified models require comprehensive re-validation under SR 11-7."\n    },\n    {\n      "category": "Regulatory Compliance",\n      "severity": "CRITICAL",\n      "description": "Code generation model being used for regulated credit, fraud, and identity verification decisions violates ECOA/Reg B, FFIEC guidance, and AML/BSA requirements. Code generation models are not designed for financial decision-making."\n    },\n    {\n      "category": "Use Case Misalignment",\n      "severity": "CRITICAL",\n      "description": "CodeLlama 34B is designed for programming assistance, not financial services decision-making. Using it for credit, fraud, and KYC decisions represents fundamental misuse of the model's intended capabilities."\n    },\n    {\n      "category": "Human Oversight",\n      "severity": "CRITICAL",\n      "description": "No human-in-the-loop for high-impact regulated decisions violates SR 11-7 requirements and regulatory expectations for automated decision-making in financial services."\n    },\n    {\n      "category": "Data Privacy",\n      "severity": "HIGH",\n      "description": "Model processes application forms, contracts, and customer support tickets containing extensive PII without adequate protection mechanisms for a code generation model."\n    },\n    {\n      "category": "License Compliance",\n      "severity": "HIGH",\n      "description": "Llama 2 Community License may restrict commercial use in financial services applications, particularly for regulated decision-making."\n    }\n  ],\n  "regulatory_concerns": [\n    "ECOA/Reg B violation - using code generation model for credit decisions",\n    "FFIEC guidance non-compliance for fraud detection systems",\n    "AML/BSA requirements not met for identity verification",\n    "KYC/CIP compliance issues with automated identity decisions",\n    "SR 11-7 Model Risk Management violations - inadequate validation of modified model",\n    "NIST AI Risk Management Framework non-compliance for high-risk AI system"\n  ],\n  "security_concerns": [\n    "Code generation model exposed to sensitive financial data",\n    "Cloud GPU deployment increases attack surface for sensitive operations",\n    "Modified model may have compromised security features",\n    "Inadequate access controls for regulated decision system"\n  ],\n  "data_privacy_concerns": [\n    "Application forms contain extensive PII (SSN, income, employment)",\n    "Contract documents include personal and financial information",\n    "Customer support tickets may contain account details and personal data",\n    "GLBA compliance at risk due to inappropriate model for financial data",\n    "PII redaction may be insufficient for code generation model processing"\n  ],\n  "bias_concerns": [\n    "Code generation model not designed to handle protected class considerations",\n    "Fine-tuning modifications may introduce discriminatory patterns",\n    "No bias testing framework appropriate for financial decision-making",\n    "Potential for disparate impact in credit and fraud decisions",\n    "Modified model lacks fairness validation for regulated decisions"\n  ],\n  "recommendations": [\n    "Immediately halt deployment - fundamental use case misalignment",\n    "Select appropriate model designed for financial services decision-making",\n    "Implement mandatory human-in-the-loop for all regulated decisions",\n    "Conduct comprehensive model validation under SR 11-7 framework",\n    "Perform bias testing and fairness validation for protected classes",\n    "Review and ensure license compliance for commercial financial use",\n    "Implement enhanced PII protection and data governance controls"\n  ],\n  "required_actions": [\n    "STOP: Do not deploy - critical regulatory violations identified",\n    "Conduct legal review of Llama 2 Community License for intended use",\n    "Perform complete model risk assessment under SR 11-7",\n    "Implement comprehensive bias and fairness testing framework",\n    "Establish human oversight requirements for all decisions",\n    "Conduct privacy impact assessment for PII handling",\n    "Validate all model modifications through independent testing",\n    "Obtain regulatory approval for AI system in regulated decisions"\n  ],\n  "pii_detected": true,\n  "pii_details": {\n    "sources": ["Application Forms", "Contract Documents", "Customer Support Tickets"],\n    "types": ["SSN", "Financial Information", "Personal Identifiers", "Account Details", "Employment Information"],\n    "risk_level": "HIGH",\n    "protection_adequacy": "INSUFFICIENT"\n  },\n  "vendor_evaluation": {\n    "vendor_name": "Meta",\n    "reputation": "ESTABLISHED",\n    "model_maturity": "MATURE",\n    "documentation_quality": "GOOD",\n    "license_restrictions": "COMMERCIAL_USE_RESTRICTED",\n    "support_availability": "COMMUNITY_ONLY",\n    "security_posture": "UNKNOWN_FOR_MODIFICATIONS",\n    "compliance_certifications": "NONE_FOR_FINANCIAL_SERVICES",\n    "overall_vendor_risk": "HIGH"\n  }\n}\n```	2025-11-15 18:03:55.311162	2025-11-15 18:03:55.311162
3	8	automated	78	HIGH	REQUIRES_REVIEW	[{"category": "Model Modifications", "severity": "HIGH", "description": "Prompt engineering modifications to SAM model for content moderation represent significant deviation from intended use case. SAM is designed for image segmentation, not content moderation decisions. This modification introduces validation requirements and potential for degraded performance in regulatory decision-making context."}, {"category": "Use Case Misalignment", "severity": "HIGH", "description": "Critical misalignment between model capabilities and intended use. SAM is a segmentation model designed for object masking/annotation, not content moderation or regulatory decision-making. Using it for regulated decisions without proper validation poses significant model risk."}, {"category": "Regulatory Decision Risk", "severity": "CRITICAL", "description": "Model will make regulated decisions without human oversight, using a vision model not designed for compliance-sensitive content moderation. This creates significant regulatory and operational risk."}, {"category": "Data Privacy", "severity": "HIGH", "description": "Contract documents likely contain extensive PII, PHI, and confidential business information. Vision model processing of these documents creates data exposure risks."}, {"category": "Model Validation Gap", "severity": "HIGH", "description": "No evidence of proper model validation for the modified use case. SR 11-7 requires comprehensive validation when models are used outside their intended purpose."}, {"category": "Vendor Risk", "severity": "MEDIUM", "description": "Meta/Facebook has faced regulatory scrutiny and privacy concerns. Open source model reduces some vendor lock-in but increases support and maintenance risks."}]	["SR 11-7 Model Risk Management - inadequate validation for modified use case", "FFIEC IT Examination Handbook - insufficient controls for regulated decision-making", "GLBA Privacy Rule - potential exposure of customer financial information in contract documents", "ECOA/Regulation B - risk of discriminatory outcomes in content moderation without proper bias testing", "NIST AI Risk Management Framework - lack of appropriate risk assessment for modified model use"]	["Cloud GPU deployment increases attack surface for sensitive contract data", "Open source model may have undiscovered vulnerabilities", "Insufficient access controls specified for sensitive document processing", "No mention of data encryption in transit/at rest for contract documents", "Potential for model extraction attacks on cloud-deployed vision model"]	["Contract documents highly likely to contain customer PII including names, addresses, SSNs", "Potential PHI exposure if contracts relate to healthcare financing", "Business confidential information exposure risk", "GLBA compliance risk for customer financial data in contracts", "No data retention/deletion policies specified for processed contract images"]	["Vision models can exhibit bias in content interpretation across different document types", "Prompt engineering modifications may introduce or amplify existing biases", "No bias testing mentioned for content moderation use case", "Risk of disparate impact on different customer segments based on contract document characteristics", "Lack of fairness validation for regulated decision-making context"]	["Conduct comprehensive model validation study for content moderation use case", "Implement robust bias testing and fairness assessment framework", "Establish clear data governance policies for contract document processing", "Deploy additional security controls for cloud GPU environment", "Implement comprehensive audit logging for all model decisions", "Establish model performance monitoring and drift detection", "Create incident response procedures for model failures", "Consider alternative models specifically designed for content moderation"]	["MANDATORY: Complete SR 11-7 compliant model validation before deployment", "MANDATORY: Conduct comprehensive PII/PHI assessment of contract document data", "MANDATORY: Implement human oversight mechanism for regulated decisions", "MANDATORY: Establish bias testing framework with protected class analysis", "MANDATORY: Create detailed data governance and retention policies", "MANDATORY: Implement end-to-end encryption for contract document processing", "MANDATORY: Obtain legal review of Apache 2.0 license compliance for commercial use", "MANDATORY: Establish model performance benchmarks and monitoring thresholds"]	t	{"types": ["names", "addresses", "account_numbers", "SSN", "business_identifiers"], "sources": ["Contract Documents"], "likelihood": "HIGH", "risk_level": "HIGH", "mitigation_status": "PARTIAL - PII redaction mentioned but not validated"}	\N	```json\n{\n  "risk_score": 78,\n  "risk_level": "HIGH",\n  "approval_recommendation": "REQUIRES_REVIEW",\n  "findings": [\n    {\n      "category": "Model Modifications",\n      "severity": "HIGH",\n      "description": "Prompt engineering modifications to SAM model for content moderation represent significant deviation from intended use case. SAM is designed for image segmentation, not content moderation decisions. This modification introduces validation requirements and potential for degraded performance in regulatory decision-making context."\n    },\n    {\n      "category": "Use Case Misalignment",\n      "severity": "HIGH", \n      "description": "Critical misalignment between model capabilities and intended use. SAM is a segmentation model designed for object masking/annotation, not content moderation or regulatory decision-making. Using it for regulated decisions without proper validation poses significant model risk."\n    },\n    {\n      "category": "Regulatory Decision Risk",\n      "severity": "CRITICAL",\n      "description": "Model will make regulated decisions without human oversight, using a vision model not designed for compliance-sensitive content moderation. This creates significant regulatory and operational risk."\n    },\n    {\n      "category": "Data Privacy",\n      "severity": "HIGH",\n      "description": "Contract documents likely contain extensive PII, PHI, and confidential business information. Vision model processing of these documents creates data exposure risks."\n    },\n    {\n      "category": "Model Validation Gap",\n      "severity": "HIGH",\n      "description": "No evidence of proper model validation for the modified use case. SR 11-7 requires comprehensive validation when models are used outside their intended purpose."\n    },\n    {\n      "category": "Vendor Risk",\n      "severity": "MEDIUM",\n      "description": "Meta/Facebook has faced regulatory scrutiny and privacy concerns. Open source model reduces some vendor lock-in but increases support and maintenance risks."\n    }\n  ],\n  "regulatory_concerns": [\n    "SR 11-7 Model Risk Management - inadequate validation for modified use case",\n    "FFIEC IT Examination Handbook - insufficient controls for regulated decision-making",\n    "GLBA Privacy Rule - potential exposure of customer financial information in contract documents",\n    "ECOA/Regulation B - risk of discriminatory outcomes in content moderation without proper bias testing",\n    "NIST AI Risk Management Framework - lack of appropriate risk assessment for modified model use"\n  ],\n  "security_concerns": [\n    "Cloud GPU deployment increases attack surface for sensitive contract data",\n    "Open source model may have undiscovered vulnerabilities",\n    "Insufficient access controls specified for sensitive document processing",\n    "No mention of data encryption in transit/at rest for contract documents",\n    "Potential for model extraction attacks on cloud-deployed vision model"\n  ],\n  "data_privacy_concerns": [\n    "Contract documents highly likely to contain customer PII including names, addresses, SSNs",\n    "Potential PHI exposure if contracts relate to healthcare financing",\n    "Business confidential information exposure risk",\n    "GLBA compliance risk for customer financial data in contracts",\n    "No data retention/deletion policies specified for processed contract images"\n  ],\n  "bias_concerns": [\n    "Vision models can exhibit bias in content interpretation across different document types",\n    "Prompt engineering modifications may introduce or amplify existing biases",\n    "No bias testing mentioned for content moderation use case",\n    "Risk of disparate impact on different customer segments based on contract document characteristics",\n    "Lack of fairness validation for regulated decision-making context"\n  ],\n  "recommendations": [\n    "Conduct comprehensive model validation study for content moderation use case",\n    "Implement robust bias testing and fairness assessment framework",\n    "Establish clear data governance policies for contract document processing",\n    "Deploy additional security controls for cloud GPU environment",\n    "Implement comprehensive audit logging for all model decisions",\n    "Establish model performance monitoring and drift detection",\n    "Create incident response procedures for model failures",\n    "Consider alternative models specifically designed for content moderation"\n  ],\n  "required_actions": [\n    "MANDATORY: Complete SR 11-7 compliant model validation before deployment",\n    "MANDATORY: Conduct comprehensive PII/PHI assessment of contract document data",\n    "MANDATORY: Implement human oversight mechanism for regulated decisions",\n    "MANDATORY: Establish bias testing framework with protected class analysis",\n    "MANDATORY: Create detailed data governance and retention policies",\n    "MANDATORY: Implement end-to-end encryption for contract document processing",\n    "MANDATORY: Obtain legal review of Apache 2.0 license compliance for commercial use",\n    "MANDATORY: Establish model performance benchmarks and monitoring thresholds"\n  ],\n  "pii_detected": true,\n  "pii_details": {\n    "likelihood": "HIGH",\n    "types": ["names", "addresses", "account_numbers", "SSN", "business_identifiers"],\n    "sources": ["Contract Documents"],\n    "risk_level": "HIGH",\n    "mitigation_status": "PARTIAL - PII redaction mentioned but not validated"\n  },\n  "vendor_evaluation": {\n    "vendor_name": "Meta",\n    "reputation_score": 65,\n    "security_posture": "MEDIUM",\n    "regulatory_history": "CONCERNING - Multiple privacy violations and regulatory actions",\n    "support_model": "COMMUNITY - Open source model with limited commercial support",\n    "license_risk": "LOW - Apache 2.0 permissive license",\n    "documentation_quality": "HIGH - Well documented on HuggingFace",\n    "update_frequency": "LOW - Model is static, no regular updates",\n    "overall_vendor_risk": "MEDIUM-HIGH"\n  }\n}\n```	2025-11-15 18:11:09.026944	2025-11-15 18:11:09.026944
\.


--
-- Data for Name: artifacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.artifacts (id, submission_id, file_name, file_path, file_type, file_size, artifact_type, uploaded_at) FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_log (id, submission_id, user_id, action, details, ip_address, created_at) FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (id, submission_id, user_id, comment, is_internal, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: conformity_assessments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conformity_assessments (id, submission_id, assessment_type, assessment_date, assessor_name, assessor_organization, general_description, intended_purpose, risk_management_system, data_governance_measures, technical_documentation, transparency_provisions, human_oversight_measures, accuracy_robustness_measures, conformity_status, non_conformities, remediation_plan, next_assessment_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: governance_approvals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.governance_approvals (id, submission_id, role_id, approver_user_id, approval_status, approval_date, comments, evidence_reviewed, conditions, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: governance_evidence; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.governance_evidence (id, submission_id, evidence_type, evidence_category, file_path, metadata, uploaded_by, uploaded_at) FROM stdin;
\.


--
-- Data for Name: governance_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.governance_roles (id, role_name, role_description, responsibilities, required_for_classes, created_at) FROM stdin;
1	Model Owner	Business owner responsible for model use case and outcomes	{"Define business requirements","Approve use cases","Monitor business metrics"}	{0,1,2,3,4,5,6}	2025-11-15 17:51:59.151645
2	Technical Reviewer	Technical expert reviewing implementation	{"Review technical implementation","Validate architecture","Approve technical approach"}	{0,1,2}	2025-11-15 17:51:59.151645
3	AI Safety Officer	Responsible for AI safety and ethics	{"Conduct safety reviews","Evaluate bias and fairness","Approve safety measures"}	{3,4,5,6}	2025-11-15 17:51:59.151645
4	Data Governance Officer	Oversees data quality and compliance	{"Validate data provenance","Ensure data quality","Approve data usage"}	{2,3,4}	2025-11-15 17:51:59.151645
5	Security Reviewer	Reviews security and privacy controls	{"Assess security risks","Validate controls","Approve security measures"}	{2,3,4,5,6}	2025-11-15 17:51:59.151645
6	Legal Counsel	Provides legal review and compliance	{"Review legal compliance","Assess regulatory requirements","Approve legal aspects"}	{4,6}	2025-11-15 17:51:59.151645
7	Data Protection Officer	GDPR/privacy compliance	{"Conduct privacy impact assessments","Ensure GDPR compliance","Approve data processing"}	{4}	2025-11-15 17:51:59.151645
8	Chief AI Officer	Senior leadership approval for high-risk AI	{"Strategic oversight","Final approval for high-risk systems","Set AI governance policy"}	{4,6}	2025-11-15 17:51:59.151645
9	CISO	Chief Information Security Officer	{"Approve security architecture","Final security sign-off","Oversee security compliance"}	{4,6}	2025-11-15 17:51:59.151645
10	CTO	Chief Technology Officer	{"Approve substantial technical changes","Strategic technology decisions","Architecture oversight"}	{6}	2025-11-15 17:51:59.151645
11	Ethics Board	Ethical review committee	{"Conduct ethical reviews","Evaluate societal impact","Approve ethical considerations"}	{4,5}	2025-11-15 17:51:59.151645
\.


--
-- Data for Name: modification_classes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modification_classes (id, class_number, class_name, risk_level, eu_ai_act_category, iso_42001_focus, description, obligations, approval_requirements, required_evidence, monitoring_requirements, created_at) FROM stdin;
1	0	Pure Base Model (No Modifications)	Low	Minimal / Limited-risk	Transparency + Acceptable Use	Using a pre-trained model without any modifications, including prompts, fine-tuning, or RAG.	{"usage": ["Within permitted domain"], "safety": ["Vendor safety guardrails"], "verification": ["License for commercial use"], "documentation": ["Model name, vendor, version"]}	{"authority": "Model Owner", "reviewers": ["Technical Reviewer"]}	{"Model card","Version documentation","License agreement","Business justification"}	{"Access control logs","Usage monitoring"}	2025-11-15 17:51:59.146367
2	1	Prompt Engineering Only	Low	Non-HRM, minimal-risk	Transparency + Change Management	Using system prompts or prompt templates to guide model behavior without changing model weights.	{"data": ["No PII in prompts"], "safety": ["Prompt safety review"], "documentation": ["Versioned prompt templates", "System prompts"]}	{"authority": "Model Owner + Reviewer", "reviewers": ["Technical Reviewer"]}	{"Prompt template version history","Safety review results","Use case documentation"}	{"Prompt version control","Behavior consistency analysis"}	2025-11-15 17:51:59.146367
3	2	RAG (Retrieval-Augmented Generation)	Medium	Limited or High Risk (context-dependent)	Data governance + Monitoring	Augmenting model outputs with retrieved information from a knowledge base or vector database.	{"legal": ["Licensing", "Copyright validation"], "privacy": ["PII controls", "Data minimization"], "security": ["Access management", "Query logging"], "documentation": ["Corpus sources", "Data lineage"]}	{"authority": "AI Reviewer + Data Governance", "reviewers": ["Data Governance Officer", "Security Reviewer"]}	{"Data lineage diagrams","Retrieval logs","Copyright compliance review","PII protection controls","Data minimization assessment"}	{"Retrieval query logging","Data leakage detection","Access audit logs"}	2025-11-15 17:51:59.146367
4	3	LoRA / QLoRA / PEFT (Adapter Fine-Tuning)	Medium-High	May be High-Risk (domain-dependent)	Lifecycle + Training Data Governance	Fine-tuning model using parameter-efficient methods (LoRA, QLoRA, adapters) that update only a small subset of parameters.	{"legal": ["Dataset legality", "Copyright", "Privacy"], "testing": ["Safety tests", "Bias evaluation"], "documentation": ["Training dataset provenance", "Dataset quality controls", "Adapter versioning"], "reproducibility": ["Training logs", "Hyperparameters"]}	{"authority": "AI Risk Committee", "reviewers": ["AI Safety Officer", "Legal", "Security", "Data Governance"]}	{"Training dataset documentation","Dataset provenance","Safety test results","Bias evaluation report","Adapter weights versioning","Reproducibility documentation","Impact assessment"}	{"Model performance monitoring","Drift detection","Bias monitoring","Safety incident tracking"}	2025-11-15 17:51:59.146367
5	4	Full Fine-Tuning (Weight Overwrite)	High	High-Risk / GPAI with Systemic Risk	Full AI Management System Controls	Complete retraining or fine-tuning that modifies all model weights, creating essentially a new model.	{"legal": ["Privacy impact assessment", "Copyright compliance"], "testing": ["Comprehensive safety testing", "Bias testing", "Robustness testing", "Red-team adversarial testing"], "monitoring": ["Drift detection", "Harm detection"], "documentation": ["Full dataset disclosure", "Data governance plan", "Model lineage"], "reproducibility": ["Training pipeline", "Version control"]}	{"authority": "Risk Committee + Legal + Security", "reviewers": ["Chief AI Officer", "Legal Counsel", "CISO", "Data Protection Officer", "Ethics Board"]}	{"Complete training metadata","Dataset disclosure","Data governance plan","Privacy impact assessment","Copyright compliance review","Safety test suite results","Bias evaluation","Robustness testing","Red-team results","Conformity assessment","Technical documentation package","Post-market monitoring plan"}	{"Continuous monitoring","Drift detection","Harm detection","Incident reporting","Performance tracking","Bias monitoring"}	2025-11-15 17:51:59.146367
6	5	Safety Alignment Tuning	Medium-High	Often High-Risk	Safety + Monitoring + Evaluation	Fine-tuning specifically to improve safety, reduce harm, or align model behavior with human values (e.g., RLHF, DPO, Constitutional AI).	{"testing": ["Bias assessment", "Safety improvement evidence", "False refusal/compliance rates"], "documentation": ["Alignment methods", "Alignment dataset lineage"]}	{"authority": "AI Risk Committee", "reviewers": ["AI Safety Officer", "Ethics Board", "Security"]}	{"Alignment methodology documentation","Alignment dataset provenance","Pre/post safety metrics","Bias evaluation","False refusal analysis","Safety test results"}	{"Safety monitoring","Alignment drift detection","Human oversight logs"}	2025-11-15 17:51:59.146367
7	6	Custom Tokenizer	Very High	High-Risk / Substantial Modification	Full Lifecycle Controls + Extensive Documentation	Modifying or replacing the model tokenizer, which fundamentally changes how the model processes inputs.	{"legal": ["Substantial modification declaration"], "testing": ["Full re-evaluation", "Stability testing", "Safety tests", "Bias tests"], "documentation": ["Tokenizer specification", "Design rationale", "Vocabulary changes"], "reproducibility": ["Tokenizer versioning", "Change control"]}	{"authority": "Risk Committee + Legal + CTO", "reviewers": ["CTO", "Chief AI Officer", "Legal Counsel", "CISO", "AI Safety Officer"]}	{"Tokenizer specification","Design rationale","Vocabulary documentation","Regression test results","Stability evaluation","Safety test suite","Bias evaluation","Substantial modification package","Technical documentation","Conformity assessment"}	{"Comprehensive monitoring","Stability tracking","Safety incident detection","Performance regression detection"}	2025-11-15 17:51:59.146367
\.


--
-- Data for Name: modification_risk_scores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modification_risk_scores (id, submission_id, modification_class, licensing_risk, data_governance_risk, safety_alignment_risk, transparency_risk, security_risk, compliance_risk, overall_risk_score, risk_factors, calculated_at) FROM stdin;
\.


--
-- Data for Name: post_market_monitoring; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.post_market_monitoring (id, submission_id, monitoring_date, monitoring_type, performance_metrics, drift_detected, drift_details, safety_incidents, incident_details, bias_metrics, bias_concerns, user_complaints, complaint_summary, actions_required, actions_taken, reported_by, created_at) FROM stdin;
\.


--
-- Data for Name: ref_data_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ref_data_sources (id, name, sensitivity, pii, created_at) FROM stdin;
1	Internal Customer Database	high	t	2025-11-15 20:35:37.929786
2	Transaction History	high	t	2025-11-15 20:35:37.930322
3	Customer Support Tickets	medium	t	2025-11-15 20:35:37.930574
4	Public Web Data	low	f	2025-11-15 20:35:37.930872
5	Product Catalog	low	f	2025-11-15 20:35:37.931065
6	User Behavior Logs	medium	t	2025-11-15 20:35:37.931264
7	Financial Statements	high	f	2025-11-15 20:35:37.931462
8	Synthetic/Generated Data	low	f	2025-11-15 20:35:37.931652
9	Third-Party Data Feeds	medium	f	2025-11-15 20:35:37.931833
10	Social Media Data	medium	t	2025-11-15 20:35:37.932013
11	Email Communications	high	t	2025-11-15 20:35:37.932247
12	Call Center Recordings	high	t	2025-11-15 20:35:37.932426
13	Application Forms	high	t	2025-11-15 20:35:37.932631
14	Contract Documents	high	t	2025-11-15 20:35:37.932802
\.


--
-- Data for Name: ref_deployment_platforms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ref_deployment_platforms (id, name, provider, type, created_at) FROM stdin;
1	AWS SageMaker	AWS	cloud_gpu	2025-11-15 20:35:37.933011
2	Google Vertex AI	Google Cloud	cloud_gpu	2025-11-15 20:35:37.933438
3	Azure ML	Microsoft Azure	cloud_gpu	2025-11-15 20:35:37.933657
4	Kubernetes (EKS)	AWS	kubernetes	2025-11-15 20:35:37.933832
5	Kubernetes (GKE)	Google Cloud	kubernetes	2025-11-15 20:35:37.934015
6	Kubernetes (AKS)	Microsoft Azure	kubernetes	2025-11-15 20:35:37.934185
7	AWS Lambda	AWS	serverless_api	2025-11-15 20:35:37.934356
8	Google Cloud Functions	Google Cloud	serverless_api	2025-11-15 20:35:37.934533
9	Azure Functions	Microsoft Azure	serverless_api	2025-11-15 20:35:37.934736
10	On-Premise GPU Cluster	Self-Hosted	on_prem_gpu	2025-11-15 20:35:37.93494
11	OpenAI API	OpenAI	vendor_hosted	2025-11-15 20:35:37.935128
12	Anthropic API	Anthropic	vendor_hosted	2025-11-15 20:35:37.935308
13	Hugging Face Inference API	Hugging Face	vendor_hosted	2025-11-15 20:35:37.935502
\.


--
-- Data for Name: ref_models; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ref_models (id, name, vendor, type, version, category, parameters, description, use_cases, license, documentation_url, created_at) FROM stdin;
1	GPT-4	OpenAI	llm	gpt-4	vendor	1.76T	Large multimodal model that accepts image and text inputs, with strong reasoning and broad general knowledge	Complex reasoning, code generation, creative writing, detailed analysis	Proprietary	https://platform.openai.com/docs/models/gpt-4	2025-11-15 20:35:37.885006
2	GPT-4 Turbo	OpenAI	llm	gpt-4-turbo	vendor	1.76T	Optimized version of GPT-4 with longer context window (128K tokens) and lower cost	Long-form content, detailed analysis, multi-document tasks	Proprietary	https://platform.openai.com/docs/models/gpt-4-turbo	2025-11-15 20:35:37.885723
3	GPT-4o	OpenAI	multimodal	gpt-4o	vendor	Unknown	Flagship multimodal model with vision capabilities and fast response times	Image understanding, OCR, multimodal tasks, real-time applications	Proprietary	https://platform.openai.com/docs/models/gpt-4o	2025-11-15 20:35:37.886054
4	GPT-4o Mini	OpenAI	llm	gpt-4o-mini	vendor	Unknown	Compact multimodal model optimized for speed and cost-efficiency with strong performance	High-volume applications, chatbots, content generation, API integrations	Proprietary	https://platform.openai.com/docs/models/gpt-4o-mini	2025-11-15 20:35:37.886501
5	GPT-3.5 Turbo	OpenAI	llm	gpt-3.5-turbo	vendor	175B	Fast and cost-effective language model suitable for most conversational and text generation tasks	Chatbots, content creation, summarization, basic coding assistance	Proprietary	https://platform.openai.com/docs/models/gpt-3-5-turbo	2025-11-15 20:35:37.886943
6	text-embedding-3-large	OpenAI	embedding	text-embedding-3-large	vendor	Unknown	High-dimensional embedding model with 3072 dimensions for semantic search and retrieval	Semantic search, document retrieval, clustering, recommendation systems	Proprietary	https://platform.openai.com/docs/models/embeddings	2025-11-15 20:35:37.887264
7	text-embedding-3-small	OpenAI	embedding	text-embedding-3-small	vendor	Unknown	Efficient embedding model with 1536 dimensions balancing performance and cost	Semantic search, classification, clustering, similarity matching	Proprietary	https://platform.openai.com/docs/models/embeddings	2025-11-15 20:35:37.887608
8	DALL-E 3	OpenAI	vision	dall-e-3	vendor	Unknown	Advanced text-to-image generation model with improved prompt following and detail	Image generation, creative design, marketing materials, concept visualization	Proprietary	https://platform.openai.com/docs/models/dall-e	2025-11-15 20:35:37.88803
9	Whisper	OpenAI	other	whisper-1	vendor	1.5B	Automatic speech recognition model trained on multilingual and multitask supervised data	Speech-to-text transcription, audio translation, voice assistants, meeting transcription	Proprietary	https://platform.openai.com/docs/models/whisper	2025-11-15 20:35:37.888296
10	Claude 3.5 Sonnet	Anthropic	llm	claude-3-5-sonnet-20241022	vendor	Unknown	Most intelligent Claude model with enhanced reasoning, coding, and analysis capabilities	Complex analysis, code generation, research tasks, agentic workflows	Proprietary	https://docs.anthropic.com/en/docs/models-overview	2025-11-15 20:35:37.88862
11	Claude 3.5 Haiku	Anthropic	llm	claude-3-5-haiku-20241022	vendor	Unknown	Fastest and most compact Claude model optimized for speed and efficiency	High-throughput tasks, real-time applications, cost-effective deployments	Proprietary	https://docs.anthropic.com/en/docs/models-overview	2025-11-15 20:35:37.889029
12	Claude 3 Opus	Anthropic	llm	claude-3-opus-20240229	vendor	Unknown	Most capable Claude 3 model for highly complex tasks requiring deep reasoning and analysis	Advanced reasoning, complex research, technical writing, detailed code review	Proprietary	https://docs.anthropic.com/en/docs/models-overview	2025-11-15 20:35:37.889333
13	Claude 3 Sonnet	Anthropic	llm	claude-3-sonnet-20240229	vendor	Unknown	Balanced Claude 3 model offering strong performance with improved speed and cost-effectiveness	Data processing, analysis, content generation, coding assistance	Proprietary	https://docs.anthropic.com/en/docs/models-overview	2025-11-15 20:35:37.889558
14	Claude 3 Haiku	Anthropic	llm	claude-3-haiku-20240307	vendor	Unknown	Fastest Claude 3 model designed for near-instant responsiveness and high-throughput use cases	Customer support, quick content moderation, simple extraction, real-time chat	Proprietary	https://docs.anthropic.com/en/docs/models-overview	2025-11-15 20:35:37.889924
15	Gemini 1.5 Pro	Google	multimodal	gemini-1.5-pro	vendor	Unknown	Advanced multimodal model with 1M+ token context window for complex reasoning and analysis	Long document analysis, code reasoning, multimodal understanding, video analysis	Proprietary	https://ai.google.dev/gemini-api/docs/models/gemini	2025-11-15 20:35:37.890199
16	Gemini 1.5 Flash	Google	multimodal	gemini-1.5-flash	vendor	Unknown	Fast and efficient multimodal model optimized for speed with long context support	High-frequency tasks, real-time applications, summarization, data extraction	Proprietary	https://ai.google.dev/gemini-api/docs/models/gemini	2025-11-15 20:35:37.890413
17	Gemini Pro	Google	llm	gemini-pro	vendor	Unknown	Production-ready text generation model with strong reasoning capabilities	Text generation, summarization, question answering, content creation	Proprietary	https://ai.google.dev/gemini-api/docs/models/gemini	2025-11-15 20:35:37.890614
18	Gemini Pro Vision	Google	multimodal	gemini-pro-vision	vendor	Unknown	Multimodal model combining text and vision understanding capabilities	Image captioning, visual question answering, document understanding, OCR	Proprietary	https://ai.google.dev/gemini-api/docs/models/gemini	2025-11-15 20:35:37.89082
19	PaLM 2	Google	llm	text-bison-001	vendor	340B	Pathways Language Model optimized for reasoning, coding, and multilingual tasks	Text generation, translation, code generation, reasoning tasks	Proprietary	https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/text	2025-11-15 20:35:37.891076
20	Vertex AI Vision	Google	vision	imagetext@001	vendor	Unknown	Computer vision model for image analysis and text extraction from images	Image classification, object detection, OCR, visual inspection	Proprietary	https://cloud.google.com/vision/docs	2025-11-15 20:35:37.891297
21	Chirp (Speech)	Google	other	chirp-v2	vendor	Unknown	Universal speech model supporting 100+ languages for transcription and translation	Speech-to-text, transcription, multilingual speech recognition, voice assistants	Proprietary	https://cloud.google.com/speech-to-text/docs	2025-11-15 20:35:37.891514
22	Azure OpenAI GPT-4	Microsoft Azure	llm	gpt-4	vendor	1.76T	Enterprise-grade GPT-4 deployment with enhanced security, compliance, and regional availability	Enterprise applications, secure AI deployment, compliance-required tasks, regulated industries	Proprietary	https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models	2025-11-15 20:35:37.89189
23	Azure OpenAI GPT-4 Turbo	Microsoft Azure	llm	gpt-4-turbo	vendor	1.76T	Azure-hosted GPT-4 Turbo with enterprise SLA, data residency, and enhanced security	Enterprise long-form content, secure multi-document analysis, compliance workflows	Proprietary	https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models	2025-11-15 20:35:37.89215
24	Azure OpenAI GPT-3.5	Microsoft Azure	llm	gpt-35-turbo	vendor	175B	Cost-effective GPT-3.5 on Azure with enterprise security and data protection	Enterprise chatbots, customer service automation, content generation at scale	Proprietary	https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models	2025-11-15 20:35:37.892418
75	T5 XXL	Google	llm	t5-11b	open_source	11B	Largest T5 encoder-decoder model for text-to-text transfer learning tasks	Translation, summarization, question answering, text generation	Apache 2.0	https://huggingface.co/google-t5/t5-11b	2025-11-15 20:35:37.903427
25	Azure Cognitive Services Vision	Microsoft Azure	vision	computer-vision-v3.2	vendor	Unknown	Computer vision API for image analysis, OCR, and spatial analysis with enterprise features	Image tagging, OCR, object detection, facial recognition, spatial analysis	Proprietary	https://learn.microsoft.com/en-us/azure/cognitive-services/computer-vision/	2025-11-15 20:35:37.892654
26	Azure Document Intelligence	Microsoft Azure	other	form-recognizer-v3	vendor	Unknown	AI-powered document processing for extraction and analysis of structured data from forms	Invoice processing, form extraction, document digitization, data entry automation	Proprietary	https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/	2025-11-15 20:35:37.893061
27	Azure Speech Services	Microsoft Azure	other	speech-v1	vendor	Unknown	Speech-to-text, text-to-speech, and speech translation with 100+ languages	Voice assistants, transcription services, call center analytics, accessibility features	Proprietary	https://learn.microsoft.com/en-us/azure/ai-services/speech-service/	2025-11-15 20:35:37.893257
28	Amazon Titan Text	AWS	llm	amazon.titan-text-express-v1	vendor	Unknown	Amazon-developed text generation model optimized for English with summarization and generation	Content creation, summarization, question answering, chatbots	Proprietary	https://docs.aws.amazon.com/bedrock/latest/userguide/titan-text-models.html	2025-11-15 20:35:37.893449
29	Amazon Titan Embeddings	AWS	embedding	amazon.titan-embed-text-v1	vendor	Unknown	Embeddings model supporting 25+ languages with 1536-dimensional vectors	Semantic search, document retrieval, recommendation systems, RAG applications	Proprietary	https://docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html	2025-11-15 20:35:37.893663
30	AWS Bedrock Claude	AWS	llm	anthropic.claude-3-sonnet	vendor	Unknown	Claude 3 Sonnet available through AWS Bedrock with AWS security and compliance	Enterprise AI applications, data processing, analysis, secure deployments	Proprietary	https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-anthropic-claude.html	2025-11-15 20:35:37.893899
31	AWS Rekognition	AWS	vision	rekognition-v1	vendor	Unknown	Computer vision service for image and video analysis with facial recognition capabilities	Facial recognition, object detection, content moderation, celebrity recognition	Proprietary	https://docs.aws.amazon.com/rekognition/	2025-11-15 20:35:37.894116
32	AWS Textract	AWS	other	textract-v1	vendor	Unknown	Document analysis service that extracts text, forms, and tables from scanned documents	Document processing, form extraction, invoice processing, automated data entry	Proprietary	https://docs.aws.amazon.com/textract/	2025-11-15 20:35:37.894323
33	AWS Comprehend	AWS	classification	comprehend-v1	vendor	Unknown	Natural language processing service for entity extraction, sentiment analysis, and topic modeling	Sentiment analysis, entity recognition, topic modeling, document classification	Proprietary	https://docs.aws.amazon.com/comprehend/	2025-11-15 20:35:37.894519
34	Command R+	Cohere	llm	command-r-plus	vendor	104B	Most capable Command model optimized for RAG, multilingual tasks, and complex reasoning	Retrieval augmented generation, multi-step reasoning, coding, multilingual applications	Proprietary	https://docs.cohere.com/docs/command-r-plus	2025-11-15 20:35:37.894715
35	Command R	Cohere	llm	command-r	vendor	35B	Scalable model optimized for long-context RAG and tool use at enterprise scale	RAG applications, conversational AI, tool use, enterprise chatbots	Proprietary	https://docs.cohere.com/docs/command-r	2025-11-15 20:35:37.894935
36	Command	Cohere	llm	command	vendor	52B	General-purpose language model for text generation and conversational applications	Content generation, summarization, chatbots, classification	Proprietary	https://docs.cohere.com/docs/command-beta	2025-11-15 20:35:37.895132
37	Command Light	Cohere	llm	command-light	vendor	6B	Lightweight and fast model optimized for speed and cost-effectiveness	High-volume tasks, simple classification, content moderation, quick responses	Proprietary	https://docs.cohere.com/docs/command-beta	2025-11-15 20:35:37.895328
38	Embed v3	Cohere	embedding	embed-english-v3.0	vendor	Unknown	State-of-the-art embeddings with compression and multi-lingual support	Semantic search, clustering, classification, recommendation systems	Proprietary	https://docs.cohere.com/docs/embed-2	2025-11-15 20:35:37.895529
39	Rerank v3	Cohere	other	rerank-english-v3.0	vendor	Unknown	Reranking model for improving search relevance and result ordering	Search result reranking, document relevance scoring, retrieval optimization	Proprietary	https://docs.cohere.com/docs/rerank-2	2025-11-15 20:35:37.895727
40	Mistral Large 2	Mistral AI	llm	mistral-large-2407	vendor	123B	Flagship Mistral model with advanced reasoning, coding, and multilingual capabilities	Complex reasoning, code generation, multilingual tasks, advanced analysis	Proprietary	https://docs.mistral.ai/platform/endpoints/	2025-11-15 20:35:37.895921
41	Mistral Large	Mistral AI	llm	mistral-large-latest	vendor	123B	Top-tier Mistral model for high-complexity tasks with broad capabilities	Enterprise applications, complex reasoning, code generation, multilingual support	Proprietary	https://docs.mistral.ai/platform/endpoints/	2025-11-15 20:35:37.896156
42	Mistral Medium	Mistral AI	llm	mistral-medium-latest	vendor	Unknown	Balanced model offering strong performance with improved efficiency	General text generation, summarization, question answering, analysis	Proprietary	https://docs.mistral.ai/platform/endpoints/	2025-11-15 20:35:37.896412
43	Mistral Small	Mistral AI	llm	mistral-small-latest	vendor	22B	Cost-effective model optimized for low latency and high throughput	Simple classification, content moderation, lightweight chatbots, API integrations	Proprietary	https://docs.mistral.ai/platform/endpoints/	2025-11-15 20:35:37.89664
44	Perplexity Sonar Large	Perplexity AI	llm	sonar-large-online	vendor	Unknown	Large online model with real-time web search and fact-checking capabilities	Research, fact-checking, current events analysis, web-connected Q&A	Proprietary	https://docs.perplexity.ai/docs/model-cards	2025-11-15 20:35:37.896862
45	Perplexity Sonar Medium	Perplexity AI	llm	sonar-medium-online	vendor	Unknown	Medium-sized online model balancing speed and accuracy for web-connected tasks	Quick research, information retrieval, summarization, web-based queries	Proprietary	https://docs.perplexity.ai/docs/model-cards	2025-11-15 20:35:37.897094
46	Jurassic-2 Ultra	AI21 Labs	llm	j2-ultra	vendor	178B	Most powerful Jurassic model with superior language understanding and generation	Complex text generation, long-form content, advanced reasoning, creative writing	Proprietary	https://docs.ai21.com/docs/jurassic-2-models	2025-11-15 20:35:37.897297
47	Jurassic-2 Mid	AI21 Labs	llm	j2-mid	vendor	80B	Mid-tier Jurassic model balancing performance and cost for production use	Content generation, summarization, classification, chatbots	Proprietary	https://docs.ai21.com/docs/jurassic-2-models	2025-11-15 20:35:37.897485
48	Jamba	AI21 Labs	llm	jamba-instruct	vendor	52B	Hybrid SSM-Transformer model with 256K context window for long-context tasks	Long document analysis, extensive context reasoning, complex conversations	Proprietary	https://docs.ai21.com/docs/jamba-models	2025-11-15 20:35:37.897767
49	Stable Diffusion XL	Stability AI	vision	stable-diffusion-xl-1024-v1-0	vendor	3.5B	High-resolution text-to-image model generating detailed 1024x1024 images with improved composition	High-quality image generation, art creation, product visualization, marketing materials	CreativeML Open RAIL++-M	https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0	2025-11-15 20:35:37.898095
50	Stable Diffusion 3	Stability AI	vision	stable-diffusion-3-medium	vendor	2B	Latest generation diffusion model with improved prompt understanding and text rendering	Advanced image generation, text-in-image rendering, creative design, visual content	Stability AI Community License	https://huggingface.co/stabilityai/stable-diffusion-3-medium	2025-11-15 20:35:37.898306
51	Midjourney v6	Midjourney	vision	v6	vendor	Unknown	State-of-the-art image generation model with photorealistic output and enhanced prompt adherence	Professional art generation, creative design, conceptual visualization, marketing imagery	Proprietary	https://docs.midjourney.com/	2025-11-15 20:35:37.898543
52	Claude with Vision	Anthropic	multimodal	claude-3-opus-vision	vendor	Unknown	Claude 3 Opus with vision capabilities for image understanding and multimodal reasoning	Image analysis, document processing, visual question answering, diagram interpretation	Proprietary	https://docs.anthropic.com/en/docs/vision	2025-11-15 20:35:37.898732
53	Llama 3.3 70B	Meta	llm	llama-3.3-70b-instruct	open_source	70B	Latest Llama 3 model with 70B parameters, optimized for instruction following and reasoning	Chat, instruction following, coding, reasoning tasks	Llama 3 Community License	https://huggingface.co/meta-llama/llama-3.3-70b-instruct	2025-11-15 20:35:37.898931
54	Llama 3.2 90B	Meta	multimodal	llama-3.2-90b-vision	open_source	90B	Multimodal Llama model with vision capabilities for image understanding	Image captioning, visual question answering, multimodal chat	Llama 3.2 Community License	https://huggingface.co/meta-llama/llama-3.2-90b-vision	2025-11-15 20:35:37.899127
55	Llama 3.2 11B	Meta	multimodal	llama-3.2-11b-vision	open_source	11B	Compact multimodal Llama model with vision capabilities for image understanding	Image captioning, visual Q&A, document understanding, edge deployment	Llama 3.2 Community License	https://huggingface.co/meta-llama/Llama-3.2-11B-Vision	2025-11-15 20:35:37.899331
56	Llama 3.2 3B	Meta	llm	llama-3.2-3b	open_source	3B	Lightweight Llama model optimized for on-device and edge deployments	Edge AI, mobile applications, low-resource environments, summarization	Llama 3.2 Community License	https://huggingface.co/meta-llama/Llama-3.2-3B	2025-11-15 20:35:37.899532
57	Llama 3.2 1B	Meta	llm	llama-3.2-1b	open_source	1B	Ultra-compact Llama model for resource-constrained environments and mobile devices	Mobile AI, IoT devices, edge computing, lightweight chatbots	Llama 3.2 Community License	https://huggingface.co/meta-llama/Llama-3.2-1B	2025-11-15 20:35:37.899723
58	Llama 3.1 405B	Meta	llm	llama-3.1-405b	open_source	405B	Largest Llama model with state-of-the-art performance on complex reasoning and generation tasks	Advanced reasoning, complex coding, research, synthetic data generation	Llama 3.1 Community License	https://huggingface.co/meta-llama/Llama-3.1-405B	2025-11-15 20:35:37.899924
59	Llama 3.1 70B	Meta	llm	llama-3.1-70b	open_source	70B	High-performance Llama model with 128K context window for long-form content	Long-document analysis, coding, content generation, complex reasoning	Llama 3.1 Community License	https://huggingface.co/meta-llama/Llama-3.1-70B	2025-11-15 20:35:37.900111
60	Llama 3.1 8B	Meta	llm	llama-3.1-8b	open_source	8B	Efficient Llama model balancing performance and computational requirements	Chatbots, summarization, content generation, general-purpose NLP	Llama 3.1 Community License	https://huggingface.co/meta-llama/Llama-3.1-8B	2025-11-15 20:35:37.900295
61	Llama 3 70B	Meta	llm	llama-3-70b	open_source	70B	Llama 3 large model with strong reasoning and multilingual capabilities	Complex reasoning, multilingual tasks, coding, content creation	Llama 3 Community License	https://huggingface.co/meta-llama/Meta-Llama-3-70B	2025-11-15 20:35:37.900478
62	Llama 3 8B	Meta	llm	llama-3-8b	open_source	8B	Llama 3 base model offering strong performance for general-purpose tasks	Text generation, question answering, summarization, chatbots	Llama 3 Community License	https://huggingface.co/meta-llama/Meta-Llama-3-8B	2025-11-15 20:35:37.90066
63	Llama 2 70B	Meta	llm	llama-2-70b	open_source	70B	Llama 2 large model fine-tuned for dialogue and instruction following	Conversational AI, instruction following, content generation, Q&A	Llama 2 Community License	https://huggingface.co/meta-llama/Llama-2-70b-hf	2025-11-15 20:35:37.900861
64	Llama 2 13B	Meta	llm	llama-2-13b	open_source	13B	Mid-sized Llama 2 model providing good balance of quality and efficiency	Chatbots, text generation, summarization, general NLP tasks	Llama 2 Community License	https://huggingface.co/meta-llama/Llama-2-13b-hf	2025-11-15 20:35:37.901082
65	Llama 2 7B	Meta	llm	llama-2-7b	open_source	7B	Compact Llama 2 model suitable for efficient deployment and fine-tuning	Resource-efficient chatbots, fine-tuning, domain adaptation, text generation	Llama 2 Community License	https://huggingface.co/meta-llama/Llama-2-7b-hf	2025-11-15 20:35:37.901284
66	Mixtral 8x22B	Mistral AI	llm	mixtral-8x22b-instruct-v0.1	open_source	141B	Large mixture-of-experts model with 8 experts of 22B parameters each for high performance	Complex reasoning, multilingual tasks, code generation, advanced analysis	Apache 2.0	https://huggingface.co/mistralai/Mixtral-8x22B-Instruct-v0.1	2025-11-15 20:35:37.901477
67	Mixtral 8x7B	Mistral AI	llm	mixtral-8x7b-instruct-v0.1	open_source	46.7B	Efficient mixture-of-experts model outperforming larger models while using fewer active parameters	Multilingual tasks, code generation, reasoning, general text generation	Apache 2.0	https://huggingface.co/mistralai/Mixtral-8x7B-Instruct-v0.1	2025-11-15 20:35:37.901697
68	Mistral 7B	Mistral AI	llm	mistral-7b-instruct-v0.3	open_source	7B	Compact open-source model with strong performance and efficient inference	Chatbots, text generation, summarization, instruction following	Apache 2.0	https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.3	2025-11-15 20:35:37.901908
69	Mistral Nemo	Mistral AI	llm	mistral-nemo-instruct-2407	open_source	12B	Mid-size model developed with NVIDIA, optimized for reasoning and multilingual tasks	Chatbots, multilingual applications, reasoning tasks, code generation	Apache 2.0	https://huggingface.co/mistralai/Mistral-Nemo-Instruct-2407	2025-11-15 20:35:37.902114
70	Gemma 2 27B	Google	llm	gemma-2-27b-it	open_source	27B	Largest Gemma 2 model with advanced capabilities for complex reasoning and generation	Complex reasoning, code generation, long-form content, research tasks	Gemma License	https://huggingface.co/google/gemma-2-27b-it	2025-11-15 20:35:37.90231
71	Gemma 2 9B	Google	llm	gemma-2-9b-it	open_source	9B	Mid-sized Gemma 2 model balancing performance and efficiency for production use	Chatbots, content generation, question answering, summarization	Gemma License	https://huggingface.co/google/gemma-2-9b-it	2025-11-15 20:35:37.902532
72	Gemma 2 2B	Google	llm	gemma-2-2b-it	open_source	2B	Compact Gemma 2 model optimized for edge deployment and resource-constrained environments	Edge AI, mobile applications, lightweight chatbots, on-device inference	Gemma License	https://huggingface.co/google/gemma-2-2b-it	2025-11-15 20:35:37.902779
73	Gemma 7B	Google	llm	gemma-7b-it	open_source	7B	First-generation Gemma model with strong instruction-following capabilities	Instruction following, text generation, chatbots, Q&A	Gemma License	https://huggingface.co/google/gemma-7b-it	2025-11-15 20:35:37.903015
74	Gemma 2B	Google	llm	gemma-2b-it	open_source	2B	Lightweight Gemma model for efficient deployment and fine-tuning	Resource-efficient applications, fine-tuning, lightweight inference	Gemma License	https://huggingface.co/google/gemma-2b-it	2025-11-15 20:35:37.903224
76	T5 Large	Google	llm	t5-large	open_source	770M	Large T5 model for diverse text-to-text tasks with good performance-efficiency balance	Translation, summarization, text classification, NLP tasks	Apache 2.0	https://huggingface.co/google-t5/t5-large	2025-11-15 20:35:37.903636
77	T5 Base	Google	llm	t5-base	open_source	220M	Base T5 encoder-decoder model for efficient text-to-text transfer learning	General NLP tasks, fine-tuning, text processing, classification	Apache 2.0	https://huggingface.co/google-t5/t5-base	2025-11-15 20:35:37.90387
78	FLAN-T5 XXL	Google	llm	flan-t5-xxl	open_source	11B	T5 model fine-tuned on instruction tasks with improved zero-shot performance	Instruction following, zero-shot tasks, multi-task learning, reasoning	Apache 2.0	https://huggingface.co/google/flan-t5-xxl	2025-11-15 20:35:37.904071
79	Qwen2.5 72B	Alibaba	llm	qwen2.5-72b-instruct	open_source	72B	Largest Qwen 2.5 model with advanced multilingual and reasoning capabilities	Complex reasoning, multilingual tasks, code generation, long-context analysis	Apache 2.0	https://huggingface.co/Qwen/Qwen2.5-72B-Instruct	2025-11-15 20:35:37.904263
80	Qwen2.5 32B	Alibaba	llm	qwen2.5-32b-instruct	open_source	32B	Mid-large Qwen model balancing performance and computational efficiency	Multilingual applications, coding, content generation, reasoning	Apache 2.0	https://huggingface.co/Qwen/Qwen2.5-32B-Instruct	2025-11-15 20:35:37.904477
81	Qwen2.5 14B	Alibaba	llm	qwen2.5-14b-instruct	open_source	14B	Mid-sized Qwen model with strong multilingual and reasoning performance	Chatbots, multilingual NLP, code assistance, general text generation	Apache 2.0	https://huggingface.co/Qwen/Qwen2.5-14B-Instruct	2025-11-15 20:35:37.904661
82	Qwen2.5 7B	Alibaba	llm	qwen2.5-7b-instruct	open_source	7B	Efficient Qwen model optimized for multilingual tasks and coding	Multilingual chatbots, code generation, text generation, Q&A	Apache 2.0	https://huggingface.co/Qwen/Qwen2.5-7B-Instruct	2025-11-15 20:35:37.904916
83	Phi-4	Microsoft	llm	phi-4	open_source	14B	Latest Phi model with enhanced reasoning and problem-solving capabilities	Reasoning tasks, coding, mathematical problem solving, Q&A	MIT	https://huggingface.co/microsoft/phi-4	2025-11-15 20:35:37.905218
84	Phi-3.5 MoE	Microsoft	llm	phi-3.5-moe-instruct	open_source	42B	Mixture-of-experts Phi model with 16 experts for efficient inference	Complex reasoning, multilingual tasks, coding, long-context applications	MIT	https://huggingface.co/microsoft/Phi-3.5-MoE-instruct	2025-11-15 20:35:37.905581
85	Phi-3 Medium	Microsoft	llm	phi-3-medium-128k-instruct	open_source	14B	Mid-sized Phi-3 with 128K context window for long-context tasks	Long document analysis, coding, reasoning, extended conversations	MIT	https://huggingface.co/microsoft/Phi-3-medium-128k-instruct	2025-11-15 20:35:37.906034
86	Phi-3 Small	Microsoft	llm	phi-3-small-128k-instruct	open_source	7B	Compact Phi-3 model with 128K context window balancing size and capability	Chatbots, reasoning, coding assistance, summarization	MIT	https://huggingface.co/microsoft/Phi-3-small-128k-instruct	2025-11-15 20:35:37.906272
87	Phi-3 Mini	Microsoft	llm	phi-3-mini-128k-instruct	open_source	3.8B	Ultra-compact Phi-3 model optimized for edge and mobile deployment	Edge AI, mobile applications, lightweight inference, resource-constrained environments	MIT	https://huggingface.co/microsoft/Phi-3-mini-128k-instruct	2025-11-15 20:35:37.906475
88	DBRX Instruct	Databricks	llm	dbrx-instruct	open_source	132B	Large MoE model with 36B active parameters optimized for instruction following	Complex instructions, code generation, reasoning, enterprise applications	Databricks Open Model License	https://huggingface.co/databricks/dbrx-instruct	2025-11-15 20:35:37.906675
89	DBRX Base	Databricks	llm	dbrx-base	open_source	132B	Base DBRX model for fine-tuning on domain-specific tasks	Fine-tuning, domain adaptation, custom model development	Databricks Open Model License	https://huggingface.co/databricks/dbrx-base	2025-11-15 20:35:37.906981
90	Falcon 180B	TII	llm	falcon-180b	open_source	180B	Largest open-source Falcon model with strong multilingual capabilities	Complex reasoning, multilingual tasks, research, large-scale generation	Apache 2.0	https://huggingface.co/tiiuae/falcon-180B	2025-11-15 20:35:37.90726
91	Falcon 40B	TII	llm	falcon-40b	open_source	40B	Mid-sized Falcon model with strong performance across diverse tasks	Text generation, reasoning, chatbots, multilingual applications	Apache 2.0	https://huggingface.co/tiiuae/falcon-40b	2025-11-15 20:35:37.90749
92	Falcon 7B	TII	llm	falcon-7b	open_source	7B	Compact Falcon model suitable for efficient deployment and fine-tuning	Chatbots, text generation, fine-tuning, resource-efficient applications	Apache 2.0	https://huggingface.co/tiiuae/falcon-7b	2025-11-15 20:35:37.907718
93	MPT 30B	MosaicML	llm	mpt-30b-instruct	open_source	30B	MosaicML Pretrained Transformer optimized for long-context understanding	Long-context tasks, instruction following, chatbots, content generation	Apache 2.0	https://huggingface.co/mosaicml/mpt-30b-instruct	2025-11-15 20:35:37.907952
94	MPT 7B	MosaicML	llm	mpt-7b-instruct	open_source	7B	Efficient MPT model with commercial-friendly license and strong performance	Chatbots, instruction following, commercial applications, text generation	Apache 2.0	https://huggingface.co/mosaicml/mpt-7b-instruct	2025-11-15 20:35:37.90818
95	Vicuna 33B	LMSYS	llm	vicuna-33b-v1.3	open_source	33B	Large Vicuna model fine-tuned from Llama with conversational capabilities	Conversational AI, chatbots, instruction following, research	Non-commercial	https://huggingface.co/lmsys/vicuna-33b-v1.3	2025-11-15 20:35:37.908422
96	Vicuna 13B	LMSYS	llm	vicuna-13b-v1.5	open_source	13B	Mid-sized Vicuna model with strong conversational performance	Chatbots, conversational AI, research, instruction following	Non-commercial	https://huggingface.co/lmsys/vicuna-13b-v1.5	2025-11-15 20:35:37.908647
97	BERT Large	Google	classification	google-bert/bert-large-uncased	open_source	340M	Large bidirectional transformer for language understanding, pretrained on BookCorpus and Wikipedia	Sequence classification, token classification, question answering, masked language modeling	Apache 2.0	https://huggingface.co/google-bert/bert-large-uncased	2025-11-15 20:35:37.908887
98	BERT Base	Google	classification	google-bert/bert-base-uncased	open_source	110M	Base BERT model pretrained on English text in self-supervised fashion with MLM and NSP objectives	Fine-tuning for NLP tasks, feature extraction, sentence classification, named entity recognition	Apache 2.0	https://huggingface.co/google-bert/bert-base-uncased	2025-11-15 20:35:37.909171
99	RoBERTa Large	Hugging Face	classification	roberta-large	open_source	355M	Robustly optimized BERT model trained longer with more data and no NSP objective	Text classification, sentiment analysis, NER, question answering	MIT	https://huggingface.co/FacebookAI/roberta-large	2025-11-15 20:35:37.909447
100	RoBERTa Base	Hugging Face	classification	roberta-base	open_source	125M	Base RoBERTa model with improved training methodology over BERT	Fine-tuning for classification, NER, sentiment analysis, Q&A	MIT	https://huggingface.co/FacebookAI/roberta-base	2025-11-15 20:35:37.909654
101	DistilBERT	Hugging Face	classification	distilbert-base-uncased	open_source	66M	Distilled version of BERT retaining 97% performance with 40% fewer parameters	Resource-efficient NLP, classification, NER, lightweight deployments	Apache 2.0	https://huggingface.co/distilbert/distilbert-base-uncased	2025-11-15 20:35:37.909886
102	ALBERT XXL	Hugging Face	classification	albert-xxlarge-v2	open_source	235M	A Lite BERT with parameter sharing for improved efficiency and performance	NLP tasks, classification, question answering, low-resource training	Apache 2.0	https://huggingface.co/albert/albert-xxlarge-v2	2025-11-15 20:35:37.910099
103	DeBERTa V3 Large	Microsoft	classification	deberta-v3-large	open_source	435M	Decoding-enhanced BERT with disentangled attention and enhanced mask decoder	Advanced NLP tasks, classification, NER, benchmarking	MIT	https://huggingface.co/microsoft/deberta-v3-large	2025-11-15 20:35:37.910373
104	XLM-RoBERTa	Facebook	classification	xlm-roberta-large	open_source	559M	Multilingual RoBERTa trained on 100 languages for cross-lingual understanding	Multilingual NLP, cross-lingual classification, translation, NER	MIT	https://huggingface.co/FacebookAI/xlm-roberta-large	2025-11-15 20:35:37.911056
105	Sentence-BERT	UKP Lab	embedding	all-mpnet-base-v2	open_source	110M	Sentence embeddings using siamese BERT networks for semantic similarity	Semantic search, clustering, sentence similarity, paraphrase detection	Apache 2.0	https://huggingface.co/sentence-transformers/all-mpnet-base-v2	2025-11-15 20:35:37.911624
106	E5 Large	Microsoft	embedding	e5-large-v2	open_source	335M	Text embeddings by weakly-supervised contrastive pre-training with strong performance	Semantic search, retrieval, classification, clustering	MIT	https://huggingface.co/intfloat/e5-large-v2	2025-11-15 20:35:37.912497
107	BGE Large	BAAI	embedding	bge-large-en-v1.5	open_source	335M	Beijing Academy of AI general embedding model with SOTA retrieval performance	Semantic search, information retrieval, RAG applications, clustering	MIT	https://huggingface.co/BAAI/bge-large-en-v1.5	2025-11-15 20:35:37.912899
108	GTE Large	Alibaba	embedding	gte-large	open_source	335M	General text embeddings trained on diverse corpus for semantic understanding	Semantic search, document retrieval, text similarity, clustering	Apache 2.0	https://huggingface.co/thenlper/gte-large	2025-11-15 20:35:37.914177
109	CLIP ViT-L/14	OpenAI	multimodal	clip-vit-large-patch14	open_source	427M	Large vision transformer CLIP model for zero-shot image classification and retrieval	Zero-shot classification, image-text matching, semantic search, vision-language tasks	MIT	https://huggingface.co/openai/clip-vit-large-patch14	2025-11-15 20:35:37.914551
110	CLIP ViT-B/32	OpenAI	multimodal	clip-vit-base-patch32	open_source	151M	Base CLIP model with vision transformer for efficient multimodal understanding	Image classification, image-text retrieval, zero-shot tasks, embeddings	MIT	https://huggingface.co/openai/clip-vit-base-patch32	2025-11-15 20:35:37.914787
111	BLIP-2	Salesforce	multimodal	blip2-opt-6.7b	open_source	7.8B	Bootstrapping language-image pre-training with frozen LLMs for vision-language tasks	Image captioning, visual question answering, image-text retrieval, multimodal chat	MIT	https://huggingface.co/Salesforce/blip2-opt-6.7b	2025-11-15 20:35:37.915006
112	LLaVA 1.6	Microsoft	multimodal	llava-1.6-vicuna-13b	open_source	13B	Large Language and Vision Assistant combining vision encoder with Vicuna LLM	Visual question answering, image understanding, multimodal chat, visual reasoning	Apache 2.0	https://huggingface.co/liuhaotian/llava-v1.6-vicuna-13b	2025-11-15 20:35:37.915223
113	CogVLM	THUDM	multimodal	cogvlm-chat-hf	open_source	17B	Visual language model with deep fusion of vision and language for understanding	Visual question answering, image captioning, visual reasoning, multimodal dialogue	Apache 2.0	https://huggingface.co/THUDM/cogvlm-chat-hf	2025-11-15 20:35:37.915444
114	YOLO v8	Ultralytics	vision	yolov8x	open_source	68M	State-of-the-art real-time object detection model with high accuracy and speed	Object detection, instance segmentation, pose estimation, real-time inference	AGPL-3.0	https://docs.ultralytics.com/models/yolov8/	2025-11-15 20:35:37.915676
115	SAM (Segment Anything)	Meta	vision	sam-vit-huge	open_source	641M	Promptable segmentation model for zero-shot object segmentation in images	Image segmentation, object masking, annotation tools, visual editing	Apache 2.0	https://huggingface.co/facebook/sam-vit-huge	2025-11-15 20:35:37.915895
116	Stable Diffusion v1.5	Stability AI	vision	stable-diffusion-v1-5	open_source	860M	Latent diffusion model for high-quality text-to-image generation	Image generation, art creation, image editing, inpainting	CreativeML Open RAIL-M	https://huggingface.co/runwayml/stable-diffusion-v1-5	2025-11-15 20:35:37.91617
117	Stable Diffusion v2.1	Stability AI	vision	stable-diffusion-2-1	open_source	865M	Improved stable diffusion with better prompt understanding and image quality	Advanced image generation, creative design, image synthesis, art production	CreativeML Open RAIL++-M	https://huggingface.co/stabilityai/stable-diffusion-2-1	2025-11-15 20:35:37.916398
118	Whisper Large V3	OpenAI	other	whisper-large-v3	open_source	1.55B	Latest and most accurate Whisper model for multilingual speech recognition	Speech-to-text, transcription, translation, multilingual ASR	MIT	https://huggingface.co/openai/whisper-large-v3	2025-11-15 20:35:37.916588
119	Whisper Medium	OpenAI	other	whisper-medium	open_source	769M	Mid-sized Whisper model balancing accuracy and computational requirements	Speech recognition, audio transcription, voice-to-text, subtitling	MIT	https://huggingface.co/openai/whisper-medium	2025-11-15 20:35:37.916775
120	Wav2Vec 2.0	Facebook	other	wav2vec2-large-960h	open_source	317M	Self-supervised speech representation learning for robust ASR performance	Speech recognition, audio analysis, low-resource ASR, fine-tuning	Apache 2.0	https://huggingface.co/facebook/wav2vec2-large-960h	2025-11-15 20:35:37.916959
121	CodeLlama 70B	Meta	llm	codellama-70b-instruct	open_source	70B	Largest CodeLlama model specialized for code generation and understanding	Code generation, code completion, debugging, technical documentation	Llama 2 Community License	https://huggingface.co/codellama/CodeLlama-70b-Instruct-hf	2025-11-15 20:35:37.917145
122	CodeLlama 34B	Meta	llm	codellama-34b-instruct	open_source	34B	Large CodeLlama model with strong coding capabilities and instruction following	Code generation, refactoring, code explanation, programming assistance	Llama 2 Community License	https://huggingface.co/codellama/CodeLlama-34b-Instruct-hf	2025-11-15 20:35:37.917504
123	CodeLlama 13B	Meta	llm	codellama-13b-instruct	open_source	13B	Mid-sized CodeLlama for efficient code generation and understanding	Code completion, code review, debugging, documentation generation	Llama 2 Community License	https://huggingface.co/codellama/CodeLlama-13b-Instruct-hf	2025-11-15 20:35:37.917698
124	CodeLlama 7B	Meta	llm	codellama-7b-instruct	open_source	7B	Compact CodeLlama model for resource-efficient code tasks	Code generation, simple refactoring, code suggestions, lightweight IDE integration	Llama 2 Community License	https://huggingface.co/codellama/CodeLlama-7b-Instruct-hf	2025-11-15 20:35:37.917893
125	StarCoder2 15B	BigCode	llm	starcoder2-15b	open_source	15B	Advanced code generation model trained on diverse programming languages	Code generation, multi-language programming, code completion, technical tasks	BigCode OpenRAIL-M	https://huggingface.co/bigcode/starcoder2-15b	2025-11-15 20:35:37.918138
126	CodeGen 16B	Salesforce	llm	codegen-16b-mono	open_source	16B	Large autoregressive model for program synthesis and code generation	Code generation, program synthesis, code completion, Python programming	Apache 2.0	https://huggingface.co/Salesforce/codegen-16B-mono	2025-11-15 20:35:37.918361
127	DeepSeek Coder 33B	DeepSeek	llm	deepseek-coder-33b-instruct	open_source	33B	Specialized coding model with strong performance on code generation benchmarks	Code generation, debugging, code explanation, algorithm implementation	DeepSeek License	https://huggingface.co/deepseek-ai/deepseek-coder-33b-instruct	2025-11-15 20:35:37.918559
128	XGBoost	DMLC	classification	xgboost	open_source	Varies	Scalable gradient boosting framework for supervised learning with tree-based models	Classification, regression, ranking, feature importance analysis	Apache 2.0	https://xgboost.readthedocs.io/	2025-11-15 20:35:37.918813
129	LightGBM	Microsoft	classification	lightgbm	open_source	Varies	Fast gradient boosting framework using histogram-based algorithms for efficiency	Classification, regression, large-scale ML, feature engineering	MIT	https://lightgbm.readthedocs.io/	2025-11-15 20:35:37.919037
130	CatBoost	Yandex	classification	catboost	open_source	Varies	Gradient boosting library with categorical feature support and robustness	Classification, regression, categorical data handling, ranking	Apache 2.0	https://catboost.ai/	2025-11-15 20:35:37.919272
131	Random Forest	Scikit-learn	classification	sklearn-rf	open_source	Varies	Ensemble learning method using multiple decision trees for classification and regression	Classification, regression, feature selection, outlier detection	BSD-3-Clause	https://scikit-learn.org/stable/modules/ensemble.html#random-forests	2025-11-15 20:35:37.919491
132	Gradient Boosting	Scikit-learn	classification	sklearn-gb	open_source	Varies	Sequential ensemble method building models to correct predecessor errors	Classification, regression, feature importance, predictive modeling	BSD-3-Clause	https://scikit-learn.org/stable/modules/ensemble.html#gradient-boosting	2025-11-15 20:35:37.919689
133	Isolation Forest	Scikit-learn	fraud_detection	isolation-forest	open_source	Varies	Unsupervised anomaly detection using isolation of observations in random forests	Fraud detection, anomaly detection, outlier identification, quality control	BSD-3-Clause	https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html	2025-11-15 20:35:37.919888
134	Autoencoder Anomaly	TensorFlow	fraud_detection	autoencoder-ad	open_source	Varies	Neural network-based anomaly detection using reconstruction error from autoencoders	Fraud detection, network intrusion detection, manufacturing defects, healthcare anomalies	Apache 2.0	https://www.tensorflow.org/tutorials/generative/autoencoder	2025-11-15 20:35:37.920088
135	LSTM Anomaly Detection	PyTorch	fraud_detection	lstm-ad	open_source	Varies	Recurrent neural network for time-series anomaly detection using LSTM cells	Time-series fraud detection, system monitoring, predictive maintenance, behavioral anomalies	BSD-3-Clause	https://pytorch.org/tutorials/beginner/lstm_word_language_model.html	2025-11-15 20:35:37.920279
136	Neural Collaborative Filtering	Open Source	recommendation	ncf-v1	open_source	Varies	Deep learning approach to collaborative filtering using neural networks	Product recommendations, content recommendations, personalization, user preference modeling	MIT	https://github.com/hexiangnan/neural_collaborative_filtering	2025-11-15 20:35:37.920481
137	Deep Factorization Machine	Open Source	recommendation	deepfm	open_source	Varies	Combines factorization machines with deep learning for CTR prediction and recommendations	Click-through rate prediction, recommendation systems, ad targeting, e-commerce	Apache 2.0	https://github.com/ChenglongChen/tensorflow-DeepFM	2025-11-15 20:35:37.920687
138	Wide & Deep	TensorFlow	recommendation	wide-deep	open_source	Varies	Google recommender combining memorization and generalization for recommendations	App recommendations, content recommendations, ranking systems, personalization	Apache 2.0	https://www.tensorflow.org/tutorials/structured_data/wide_and_deep	2025-11-15 20:35:37.920893
139	LightFM	Open Source	recommendation	lightfm	open_source	Varies	Hybrid recommendation algorithm combining collaborative and content-based filtering	Cold-start recommendations, content discovery, personalization, hybrid filtering	Apache 2.0	https://github.com/lyst/lightfm	2025-11-15 20:35:37.921117
\.


--
-- Data for Name: ref_regulatory_frameworks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ref_regulatory_frameworks (id, name, description, applies_to, created_at) FROM stdin;
1	ECOA (Equal Credit Opportunity Act)	Prohibits credit discrimination	["credit", "lending"]	2025-11-15 20:35:37.938242
2	Regulation B	Implements ECOA requirements	["credit", "lending"]	2025-11-15 20:35:37.938778
3	Fair Credit Reporting Act (FCRA)	Regulates consumer credit information	["credit", "background_checks"]	2025-11-15 20:35:37.939005
4	FFIEC Guidance	Federal Financial Institutions Examination Council guidance	["banking", "finance"]	2025-11-15 20:35:37.93921
5	AML/BSA	Anti-Money Laundering and Bank Secrecy Act	["banking", "finance"]	2025-11-15 20:35:37.939392
6	KYC/CIP	Know Your Customer / Customer Identification Program	["banking", "finance"]	2025-11-15 20:35:37.939601
7	GDPR	General Data Protection Regulation (EU)	["data_privacy"]	2025-11-15 20:35:37.93979
8	CCPA	California Consumer Privacy Act	["data_privacy"]	2025-11-15 20:35:37.939984
9	GLBA	Gramm-Leach-Bliley Act (financial privacy)	["finance", "privacy"]	2025-11-15 20:35:37.940185
10	HIPAA	Health Insurance Portability and Accountability Act	["healthcare"]	2025-11-15 20:35:37.94036
11	SR 11-7	Model Risk Management guidance	["banking", "model_risk"]	2025-11-15 20:35:37.940545
12	NIST AI Framework	National Institute of Standards and Technology AI framework	["all"]	2025-11-15 20:35:37.940718
\.


--
-- Data for Name: ref_safety_features; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ref_safety_features (id, name, description, category, created_at) FROM stdin;
1	Input Validation	Validate and sanitize all inputs	Input Security	2025-11-15 20:35:37.93571
2	Output Filtering	Filter harmful or inappropriate outputs	Output Security	2025-11-15 20:35:37.936118
3	Prompt Guardrails	Prevent prompt injection attacks	Prompt Security	2025-11-15 20:35:37.936296
4	Safety Classifier	Classify content for safety	Content Safety	2025-11-15 20:35:37.936489
5	Rate Limiting	Limit API request rates	Availability	2025-11-15 20:35:37.936692
6	PII Redaction	Automatically redact sensitive information	Privacy	2025-11-15 20:35:37.936931
7	Bias Monitoring	Monitor for biased outputs	Fairness	2025-11-15 20:35:37.937127
8	Audit Logging	Log all model interactions	Compliance	2025-11-15 20:35:37.937306
9	Human Review Queue	Queue uncertain outputs for review	Quality	2025-11-15 20:35:37.937478
10	Explainability Tools	Provide model decision explanations	Transparency	2025-11-15 20:35:37.937656
11	Model Versioning	Track model versions and rollbacks	Operations	2025-11-15 20:35:37.937831
12	A/B Testing	Test models before full deployment	Quality	2025-11-15 20:35:37.938002
\.


--
-- Data for Name: ref_use_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ref_use_cases (id, name, category, risk_level, created_at) FROM stdin;
1	Customer Service Chatbot	Customer Support	medium	2025-11-15 20:35:37.926404
2	Document Processing & Extraction	Document AI	medium	2025-11-15 20:35:37.927039
3	Fraud Detection	Risk Management	high	2025-11-15 20:35:37.927261
4	Credit Risk Scoring	Lending	high	2025-11-15 20:35:37.927457
5	KYC/Identity Verification	Compliance	high	2025-11-15 20:35:37.927657
6	AML Transaction Monitoring	Compliance	high	2025-11-15 20:35:37.927874
7	Content Moderation	Safety	high	2025-11-15 20:35:37.928061
8	Sentiment Analysis	Analytics	low	2025-11-15 20:35:37.928252
9	Product Recommendations	Personalization	medium	2025-11-15 20:35:37.928441
10	Code Generation/Copilot	Developer Tools	low	2025-11-15 20:35:37.928622
11	Email Classification	Productivity	low	2025-11-15 20:35:37.928799
12	Contract Analysis	Legal Tech	high	2025-11-15 20:35:37.928984
13	Market Research & Analysis	Analytics	low	2025-11-15 20:35:37.929164
14	HR Resume Screening	Human Resources	high	2025-11-15 20:35:37.929366
15	Medical Diagnosis Support	Healthcare	critical	2025-11-15 20:35:37.929551
\.


--
-- Data for Name: ref_vendors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ref_vendors (id, name, description, industry, website, created_at) FROM stdin;
1	OpenAI	AI research and deployment company	AI/ML	https://openai.com	2025-11-15 20:35:37.921384
2	Anthropic	AI safety and research company	AI/ML	https://anthropic.com	2025-11-15 20:35:37.921863
3	Google	Google Cloud AI and Vertex AI	Cloud/AI	https://cloud.google.com/vertex-ai	2025-11-15 20:35:37.922066
4	Microsoft Azure	Azure OpenAI and Cognitive Services	Cloud/AI	https://azure.microsoft.com	2025-11-15 20:35:37.922289
5	Microsoft	Phi models and AI research	AI/ML	https://www.microsoft.com/ai	2025-11-15 20:35:37.922514
6	AWS	Amazon Bedrock and SageMaker	Cloud/AI	https://aws.amazon.com/bedrock	2025-11-15 20:35:37.922726
7	Meta	Llama models and AI research	AI/ML	https://ai.meta.com	2025-11-15 20:35:37.92292
8	Mistral AI	Open and commercial LLMs	AI/ML	https://mistral.ai	2025-11-15 20:35:37.923099
9	Cohere	Enterprise NLP platform	AI/ML	https://cohere.com	2025-11-15 20:35:37.92329
10	Hugging Face	Open source ML platform	AI/ML	https://huggingface.co	2025-11-15 20:35:37.923477
11	Perplexity AI	AI-powered search and answers	AI/ML	https://www.perplexity.ai	2025-11-15 20:35:37.923673
12	AI21 Labs	Jurassic and Jamba models	AI/ML	https://www.ai21.com	2025-11-15 20:35:37.923931
13	Stability AI	Stable Diffusion and generative AI	AI/ML	https://stability.ai	2025-11-15 20:35:37.924164
14	Midjourney	AI image generation	AI/ML	https://www.midjourney.com	2025-11-15 20:35:37.92437
15	Salesforce	Einstein AI and BLIP models	AI/ML	https://www.salesforce.com/ai	2025-11-15 20:35:37.924572
16	Databricks	DBRX and MLflow	AI/ML	https://www.databricks.com	2025-11-15 20:35:37.924758
17	Alibaba	Qwen models and cloud AI	AI/ML	https://www.alibabacloud.com/solutions/ai	2025-11-15 20:35:37.924961
18	Scale AI	Data labeling and ML ops	AI/ML	https://scale.com	2025-11-15 20:35:37.925151
19	DataRobot	Automated ML platform	AI/ML	https://datarobot.com	2025-11-15 20:35:37.925342
20	H2O.ai	Open source ML platform	AI/ML	https://h2o.ai	2025-11-15 20:35:37.925532
21	Replicate	Run open-source models via API	AI/ML	https://replicate.com	2025-11-15 20:35:37.925721
22	Together AI	Open-source model inference	AI/ML	https://www.together.ai	2025-11-15 20:35:37.925973
23	Anyscale	Ray and distributed ML	AI/ML	https://www.anyscale.com	2025-11-15 20:35:37.926182
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.submissions (id, user_id, project_name, model_name, model_type, model_type_other, model_origin, model_origin_name, model_origin_version, model_origin_url, vendor_name, intended_purpose, business_impact_category, regulated_decisions, human_in_loop, data_sources, contains_customer_data, labels_modified, labels_description, modifications, training_config_location, deployment_location, deployment_location_other, access_teams, input_format, output_format, sees_sensitive_data, safety_features, known_risks, status, submitted_at, reviewed_at, reviewer_id, created_at, updated_at, modification_class, governance_data, conformity_status, iso_42001_compliant, eu_ai_act_compliant) FROM stdin;
6	1	frefer	ferfe	llm		open_source	ALBERT XXL	albert-xxlarge-v2	https://huggingface.co/albert-xxlarge-v2		AML Transaction Monitoring	low	["Regulated decisions", "Credit decisions (ECOA/Reg B)"]	f	Contract Documents, Customer Support Tickets, Email Communications, Financial Statements	yes	f		["RAG added", "Fine-tuning (LoRA / QLoRA / PEFT)"]		on_prem_gpu		legal			yes	["Output filtering", "Safety classifier"]		submitted	2025-11-15 04:23:49.135578	\N	\N	2025-11-15 04:23:49.135578	2025-11-15 04:23:49.135578	\N	{}	pending	f	f
7	1	tewst4wter	tertret	llm		open_source	CodeLlama 34B	codellama-34b-instruct	https://huggingface.co/codellama/CodeLlama-34b-Instruct-hf		Code generation, refactoring, code explanation, programming assistance	high	["Regulated decisions", "Credit decisions (ECOA/Reg B)", "Fraud decisions (FFIEC, AML/BSA)", "Identity verification (KYC, CIP)", "Customer eligibility"]	f	Application Forms, Contract Documents, Customer Support Tickets	yes	f		["Fine-tuning (LoRA / QLoRA / PEFT)", "Fine-tuning (full)", "Prompt engineering only", "Safety alignment tuning"]		cloud_gpu					yes	["Input validation", "Prompt guardrails", "PII redaction"]		submitted	2025-11-15 18:03:30.442699	\N	\N	2025-11-15 18:03:30.442699	2025-11-15 18:03:30.442699	\N	{}	pending	f	f
8	1	432423	42342	vision		open_source	SAM (Segment Anything)	sam-vit-huge	https://huggingface.co/facebook/sam-vit-huge		Content Moderation	medium	["Regulated decisions"]	f	Contract Documents	yes	f		["Prompt engineering only"]		cloud_gpu		423423	423423	432432	yes	["PII redaction", "Safety classifier", "Output filtering"]	rewrewr	submitted	2025-11-15 18:10:41.44715	\N	\N	2025-11-15 18:10:41.44715	2025-11-15 18:10:41.44715	\N	{}	pending	f	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, password_hash, full_name, role, created_at, updated_at) FROM stdin;
1	demo@example.com	demo-password-hash	Demo User	user	2025-11-15 04:23:08.783281	2025-11-15 04:23:08.783281
\.


--
-- Name: ai_incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ai_incidents_id_seq', 1, false);


--
-- Name: ai_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ai_reviews_id_seq', 3, true);


--
-- Name: artifacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.artifacts_id_seq', 1, false);


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, false);


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.comments_id_seq', 1, false);


--
-- Name: conformity_assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.conformity_assessments_id_seq', 1, false);


--
-- Name: governance_approvals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.governance_approvals_id_seq', 1, false);


--
-- Name: governance_evidence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.governance_evidence_id_seq', 1, false);


--
-- Name: governance_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.governance_roles_id_seq', 11, true);


--
-- Name: modification_classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modification_classes_id_seq', 7, true);


--
-- Name: modification_risk_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modification_risk_scores_id_seq', 1, false);


--
-- Name: post_market_monitoring_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.post_market_monitoring_id_seq', 1, false);


--
-- Name: ref_data_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ref_data_sources_id_seq', 14, true);


--
-- Name: ref_deployment_platforms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ref_deployment_platforms_id_seq', 13, true);


--
-- Name: ref_models_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ref_models_id_seq', 139, true);


--
-- Name: ref_regulatory_frameworks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ref_regulatory_frameworks_id_seq', 12, true);


--
-- Name: ref_safety_features_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ref_safety_features_id_seq', 12, true);


--
-- Name: ref_use_cases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ref_use_cases_id_seq', 15, true);


--
-- Name: ref_vendors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ref_vendors_id_seq', 23, true);


--
-- Name: submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.submissions_id_seq', 8, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: ai_incidents ai_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_incidents
    ADD CONSTRAINT ai_incidents_pkey PRIMARY KEY (id);


--
-- Name: ai_reviews ai_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_reviews
    ADD CONSTRAINT ai_reviews_pkey PRIMARY KEY (id);


--
-- Name: artifacts artifacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artifacts
    ADD CONSTRAINT artifacts_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: conformity_assessments conformity_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conformity_assessments
    ADD CONSTRAINT conformity_assessments_pkey PRIMARY KEY (id);


--
-- Name: governance_approvals governance_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_approvals
    ADD CONSTRAINT governance_approvals_pkey PRIMARY KEY (id);


--
-- Name: governance_evidence governance_evidence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_evidence
    ADD CONSTRAINT governance_evidence_pkey PRIMARY KEY (id);


--
-- Name: governance_roles governance_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_roles
    ADD CONSTRAINT governance_roles_pkey PRIMARY KEY (id);


--
-- Name: governance_roles governance_roles_role_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_roles
    ADD CONSTRAINT governance_roles_role_name_key UNIQUE (role_name);


--
-- Name: modification_classes modification_classes_class_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modification_classes
    ADD CONSTRAINT modification_classes_class_number_key UNIQUE (class_number);


--
-- Name: modification_classes modification_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modification_classes
    ADD CONSTRAINT modification_classes_pkey PRIMARY KEY (id);


--
-- Name: modification_risk_scores modification_risk_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modification_risk_scores
    ADD CONSTRAINT modification_risk_scores_pkey PRIMARY KEY (id);


--
-- Name: post_market_monitoring post_market_monitoring_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_market_monitoring
    ADD CONSTRAINT post_market_monitoring_pkey PRIMARY KEY (id);


--
-- Name: ref_data_sources ref_data_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_data_sources
    ADD CONSTRAINT ref_data_sources_pkey PRIMARY KEY (id);


--
-- Name: ref_deployment_platforms ref_deployment_platforms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_deployment_platforms
    ADD CONSTRAINT ref_deployment_platforms_pkey PRIMARY KEY (id);


--
-- Name: ref_models ref_models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_models
    ADD CONSTRAINT ref_models_pkey PRIMARY KEY (id);


--
-- Name: ref_regulatory_frameworks ref_regulatory_frameworks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_regulatory_frameworks
    ADD CONSTRAINT ref_regulatory_frameworks_pkey PRIMARY KEY (id);


--
-- Name: ref_safety_features ref_safety_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_safety_features
    ADD CONSTRAINT ref_safety_features_pkey PRIMARY KEY (id);


--
-- Name: ref_use_cases ref_use_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_use_cases
    ADD CONSTRAINT ref_use_cases_pkey PRIMARY KEY (id);


--
-- Name: ref_vendors ref_vendors_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_vendors
    ADD CONSTRAINT ref_vendors_name_key UNIQUE (name);


--
-- Name: ref_vendors ref_vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ref_vendors
    ADD CONSTRAINT ref_vendors_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_ai_incidents_severity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_incidents_severity ON public.ai_incidents USING btree (severity);


--
-- Name: idx_ai_incidents_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_incidents_submission ON public.ai_incidents USING btree (submission_id);


--
-- Name: idx_ai_reviews_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_reviews_submission_id ON public.ai_reviews USING btree (submission_id);


--
-- Name: idx_artifacts_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_artifacts_submission_id ON public.artifacts USING btree (submission_id);


--
-- Name: idx_audit_log_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_log_submission_id ON public.audit_log USING btree (submission_id);


--
-- Name: idx_comments_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comments_submission_id ON public.comments USING btree (submission_id);


--
-- Name: idx_conformity_assessments_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conformity_assessments_submission ON public.conformity_assessments USING btree (submission_id);


--
-- Name: idx_governance_approvals_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_governance_approvals_status ON public.governance_approvals USING btree (approval_status);


--
-- Name: idx_governance_approvals_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_governance_approvals_submission ON public.governance_approvals USING btree (submission_id);


--
-- Name: idx_governance_evidence_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_governance_evidence_submission ON public.governance_evidence USING btree (submission_id);


--
-- Name: idx_modification_risk_scores_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modification_risk_scores_submission ON public.modification_risk_scores USING btree (submission_id);


--
-- Name: idx_post_market_monitoring_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_market_monitoring_submission ON public.post_market_monitoring USING btree (submission_id);


--
-- Name: idx_submissions_conformity_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_submissions_conformity_status ON public.submissions USING btree (conformity_status);


--
-- Name: idx_submissions_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_submissions_created_at ON public.submissions USING btree (created_at);


--
-- Name: idx_submissions_modification_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_submissions_modification_class ON public.submissions USING btree (modification_class);


--
-- Name: idx_submissions_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_submissions_status ON public.submissions USING btree (status);


--
-- Name: idx_submissions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_submissions_user_id ON public.submissions USING btree (user_id);


--
-- Name: ai_incidents ai_incidents_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_incidents
    ADD CONSTRAINT ai_incidents_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: ai_incidents ai_incidents_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_incidents
    ADD CONSTRAINT ai_incidents_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: ai_incidents ai_incidents_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_incidents
    ADD CONSTRAINT ai_incidents_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: ai_reviews ai_reviews_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_reviews
    ADD CONSTRAINT ai_reviews_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: artifacts artifacts_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artifacts
    ADD CONSTRAINT artifacts_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: audit_log audit_log_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE SET NULL;


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: comments comments_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: conformity_assessments conformity_assessments_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conformity_assessments
    ADD CONSTRAINT conformity_assessments_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: governance_approvals governance_approvals_approver_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_approvals
    ADD CONSTRAINT governance_approvals_approver_user_id_fkey FOREIGN KEY (approver_user_id) REFERENCES public.users(id);


--
-- Name: governance_approvals governance_approvals_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_approvals
    ADD CONSTRAINT governance_approvals_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.governance_roles(id);


--
-- Name: governance_approvals governance_approvals_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_approvals
    ADD CONSTRAINT governance_approvals_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: governance_evidence governance_evidence_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_evidence
    ADD CONSTRAINT governance_evidence_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: governance_evidence governance_evidence_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.governance_evidence
    ADD CONSTRAINT governance_evidence_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: modification_risk_scores modification_risk_scores_modification_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modification_risk_scores
    ADD CONSTRAINT modification_risk_scores_modification_class_fkey FOREIGN KEY (modification_class) REFERENCES public.modification_classes(class_number);


--
-- Name: modification_risk_scores modification_risk_scores_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modification_risk_scores
    ADD CONSTRAINT modification_risk_scores_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: post_market_monitoring post_market_monitoring_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_market_monitoring
    ADD CONSTRAINT post_market_monitoring_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: post_market_monitoring post_market_monitoring_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_market_monitoring
    ADD CONSTRAINT post_market_monitoring_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_modification_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_modification_class_fkey FOREIGN KEY (modification_class) REFERENCES public.modification_classes(class_number);


--
-- Name: submissions submissions_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id);


--
-- Name: submissions submissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict O2p3hzEmUqpW1U5Drpe70u6khurFHt2KWKRBbnIQaUUUqxINhjLMFg5nlmQaQDw

