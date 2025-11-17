--
-- PostgreSQL database dump
--

\restrict FH9tjUfdiDGAxlMgwi7x4HeuCLQ0Umc98dJTmj9Yb05ldgwt6PFgTTvS7W2NzpP

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

--
-- Name: create_policy_version(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: aiuser
--

CREATE FUNCTION public.create_policy_version(p_policy_id integer, p_version_name character varying, p_created_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_version_number INTEGER;
  v_version_id INTEGER;
  v_snapshot JSONB;
BEGIN
  -- Get next version number
  SELECT COALESCE(MAX(version_number), 0) + 1
  INTO v_version_number
  FROM policy_versions
  WHERE policy_id = p_policy_id;

  -- Build snapshot (policy + sections + fields)
  SELECT jsonb_build_object(
    'policy', (SELECT row_to_json(p.*) FROM form_policies p WHERE p.id = p_policy_id),
    'sections', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'section', s.*,
          'fields', (
            SELECT jsonb_agg(f.* ORDER BY f.order_index)
            FROM form_fields f
            WHERE f.section_id = s.id
          )
        ) ORDER BY s.order_index
      )
      FROM form_sections s
      WHERE s.policy_id = p_policy_id
    )
  ) INTO v_snapshot;

  -- Insert version
  INSERT INTO policy_versions (policy_id, version_number, version_name, snapshot, created_by)
  VALUES (p_policy_id, v_version_number, p_version_name, v_snapshot, p_created_by)
  RETURNING id INTO v_version_id;

  RETURN v_version_id;
END;
$$;


ALTER FUNCTION public.create_policy_version(p_policy_id integer, p_version_name character varying, p_created_by integer) OWNER TO aiuser;

--
-- Name: FUNCTION create_policy_version(p_policy_id integer, p_version_name character varying, p_created_by integer); Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON FUNCTION public.create_policy_version(p_policy_id integer, p_version_name character varying, p_created_by integer) IS 'Creates a new version snapshot of a policy';


--
-- Name: restore_policy_version(integer, integer); Type: FUNCTION; Schema: public; Owner: aiuser
--

CREATE FUNCTION public.restore_policy_version(p_version_id integer, p_restored_by integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_policy_id INTEGER;
  v_snapshot JSONB;
  v_section JSONB;
  v_field JSONB;
  v_new_section_id INTEGER;
BEGIN
  -- Get version snapshot
  SELECT policy_id, snapshot
  INTO v_policy_id, v_snapshot
  FROM policy_versions
  WHERE id = p_version_id;

  IF v_policy_id IS NULL THEN
    RAISE EXCEPTION 'Version not found';
  END IF;

  -- Delete current sections and fields (CASCADE will handle fields)
  DELETE FROM form_sections WHERE policy_id = v_policy_id;

  -- Restore sections from snapshot
  FOR v_section IN SELECT * FROM jsonb_array_elements(v_snapshot->'sections')
  LOOP
    INSERT INTO form_sections (
      policy_id, section_key, title, description, order_index, is_required, is_enabled
    )
    SELECT
      v_policy_id,
      (v_section->'section'->>'section_key')::VARCHAR,
      (v_section->'section'->>'title')::VARCHAR,
      (v_section->'section'->>'description')::TEXT,
      (v_section->'section'->>'order_index')::INTEGER,
      (v_section->'section'->>'is_required')::BOOLEAN,
      (v_section->'section'->>'is_enabled')::BOOLEAN
    RETURNING id INTO v_new_section_id;

    -- Restore fields for this section
    FOR v_field IN SELECT * FROM jsonb_array_elements(v_section->'fields')
    LOOP
      INSERT INTO form_fields (
        section_id, field_key, label, field_type, placeholder, help_text,
        order_index, is_required, is_enabled, validation_rules, options, default_value
      )
      SELECT
        v_new_section_id,
        (v_field->>'field_key')::VARCHAR,
        (v_field->>'label')::VARCHAR,
        (v_field->>'field_type')::VARCHAR,
        (v_field->>'placeholder')::TEXT,
        (v_field->>'help_text')::TEXT,
        (v_field->>'order_index')::INTEGER,
        (v_field->>'is_required')::BOOLEAN,
        (v_field->>'is_enabled')::BOOLEAN,
        (v_field->'validation_rules')::JSONB,
        (v_field->'options')::JSONB,
        (v_field->>'default_value')::TEXT;
    END LOOP;
  END LOOP;

  -- Update active version
  INSERT INTO policy_active_versions (policy_id, version_id, activated_by)
  VALUES (v_policy_id, p_version_id, p_restored_by)
  ON CONFLICT (policy_id)
  DO UPDATE SET version_id = p_version_id, activated_at = NOW(), activated_by = p_restored_by;

  -- Log the restore action
  INSERT INTO policy_audit_log (policy_id, action, changed_by, changes)
  VALUES (
    v_policy_id,
    'version_restored',
    p_restored_by,
    jsonb_build_object('version_id', p_version_id, 'restored_at', NOW())
  );

  RETURN TRUE;
END;
$$;


ALTER FUNCTION public.restore_policy_version(p_version_id integer, p_restored_by integer) OWNER TO aiuser;

--
-- Name: FUNCTION restore_policy_version(p_version_id integer, p_restored_by integer); Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON FUNCTION public.restore_policy_version(p_version_id integer, p_restored_by integer) IS 'Restores a policy to a previous version';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_catalog_items; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.ai_catalog_items (
    id integer NOT NULL,
    catalog_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    provider character varying(255),
    category character varying(50) NOT NULL,
    description text,
    tags text[] DEFAULT ARRAY[]::text[],
    version character varying(100),
    license character varying(100),
    homepage_url text,
    documentation_url text,
    is_active boolean DEFAULT true,
    is_deprecated boolean DEFAULT false,
    deprecation_note text,
    created_by integer,
    updated_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ai_catalog_items_category_check CHECK (((category)::text = ANY ((ARRAY['model'::character varying, 'tool'::character varying, 'oss'::character varying, 'dataset'::character varying, 'use_case'::character varying])::text[])))
);


ALTER TABLE public.ai_catalog_items OWNER TO aiuser;

--
-- Name: TABLE ai_catalog_items; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.ai_catalog_items IS 'Dynamic AI catalog that can be managed through admin UI';


--
-- Name: COLUMN ai_catalog_items.catalog_id; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON COLUMN public.ai_catalog_items.catalog_id IS 'Unique identifier like "openai:gpt-4.1" or "fraud-detection"';


--
-- Name: COLUMN ai_catalog_items.category; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON COLUMN public.ai_catalog_items.category IS 'Type: model, tool, oss, dataset, or use_case';


--
-- Name: ai_catalog_items_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.ai_catalog_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_catalog_items_id_seq OWNER TO aiuser;

--
-- Name: ai_catalog_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.ai_catalog_items_id_seq OWNED BY public.ai_catalog_items.id;


--
-- Name: ai_catalog_policies; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.ai_catalog_policies (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description text,
    approved_models text[] DEFAULT ARRAY[]::text[],
    approved_tools text[] DEFAULT ARRAY[]::text[],
    approved_oss text[] DEFAULT ARRAY[]::text[],
    approved_datasets text[] DEFAULT ARRAY[]::text[],
    denied_models text[] DEFAULT ARRAY[]::text[],
    denied_tools text[] DEFAULT ARRAY[]::text[],
    denied_oss text[] DEFAULT ARRAY[]::text[],
    denied_datasets text[] DEFAULT ARRAY[]::text[],
    denied_use_cases text[] DEFAULT ARRAY[]::text[],
    review_models text[] DEFAULT ARRAY[]::text[],
    review_tools text[] DEFAULT ARRAY[]::text[],
    review_oss text[] DEFAULT ARRAY[]::text[],
    review_datasets text[] DEFAULT ARRAY[]::text[],
    review_use_cases text[] DEFAULT ARRAY[]::text[],
    is_active boolean DEFAULT true,
    is_default boolean DEFAULT false,
    is_global boolean DEFAULT true,
    version integer DEFAULT 1,
    created_by integer,
    updated_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ai_catalog_policies OWNER TO aiuser;

--
-- Name: TABLE ai_catalog_policies; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.ai_catalog_policies IS 'AI governance policies defining approved, denied, and review-required AI resources';


--
-- Name: ai_catalog_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.ai_catalog_policies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_catalog_policies_id_seq OWNER TO aiuser;

--
-- Name: ai_catalog_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.ai_catalog_policies_id_seq OWNED BY public.ai_catalog_policies.id;


--
-- Name: ai_catalog_policy_versions; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.ai_catalog_policy_versions (
    id integer NOT NULL,
    policy_id integer,
    version integer NOT NULL,
    policy_snapshot jsonb NOT NULL,
    change_description text,
    changed_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ai_catalog_policy_versions OWNER TO aiuser;

--
-- Name: TABLE ai_catalog_policy_versions; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.ai_catalog_policy_versions IS 'Version history for AI catalog policies';


--
-- Name: ai_catalog_policy_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.ai_catalog_policy_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_catalog_policy_versions_id_seq OWNER TO aiuser;

--
-- Name: ai_catalog_policy_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.ai_catalog_policy_versions_id_seq OWNED BY public.ai_catalog_policy_versions.id;


--
-- Name: ai_incidents; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.ai_incidents OWNER TO aiuser;

--
-- Name: TABLE ai_incidents; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.ai_incidents IS 'EU AI Act Article 62 serious incident reporting';


--
-- Name: ai_incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.ai_incidents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_incidents_id_seq OWNER TO aiuser;

--
-- Name: ai_incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.ai_incidents_id_seq OWNED BY public.ai_incidents.id;


--
-- Name: ai_reviews; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.ai_reviews OWNER TO aiuser;

--
-- Name: ai_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.ai_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_reviews_id_seq OWNER TO aiuser;

--
-- Name: ai_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.ai_reviews_id_seq OWNED BY public.ai_reviews.id;


--
-- Name: artifacts; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.artifacts OWNER TO aiuser;

--
-- Name: artifacts_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.artifacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.artifacts_id_seq OWNER TO aiuser;

--
-- Name: artifacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.artifacts_id_seq OWNED BY public.artifacts.id;


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.audit_log OWNER TO aiuser;

--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_log_id_seq OWNER TO aiuser;

--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.comments OWNER TO aiuser;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comments_id_seq OWNER TO aiuser;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: conformity_assessments; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.conformity_assessments OWNER TO aiuser;

--
-- Name: TABLE conformity_assessments; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.conformity_assessments IS 'EU AI Act Annex IV conformity assessment documentation';


--
-- Name: conformity_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.conformity_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conformity_assessments_id_seq OWNER TO aiuser;

--
-- Name: conformity_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.conformity_assessments_id_seq OWNED BY public.conformity_assessments.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description text,
    parent_department_id integer,
    entra_id character varying(255),
    entra_display_name character varying(255),
    entra_last_sync timestamp without time zone,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.departments OWNER TO aiuser;

--
-- Name: TABLE departments; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.departments IS 'Organizational departments, synced with Microsoft Entra ID';


--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO aiuser;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: form_fields; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.form_fields (
    id integer NOT NULL,
    section_id integer,
    field_key character varying(100) NOT NULL,
    label character varying(255) NOT NULL,
    field_type character varying(50) NOT NULL,
    placeholder text,
    help_text text,
    order_index integer NOT NULL,
    is_required boolean DEFAULT false,
    is_enabled boolean DEFAULT true,
    validation_rules jsonb,
    options jsonb,
    default_value text,
    conditional_logic jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.form_fields OWNER TO aiuser;

--
-- Name: TABLE form_fields; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.form_fields IS 'Individual fields with full configuration';


--
-- Name: form_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.form_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.form_fields_id_seq OWNER TO aiuser;

--
-- Name: form_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.form_fields_id_seq OWNED BY public.form_fields.id;


--
-- Name: form_policies; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.form_policies (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(100) NOT NULL,
    description text,
    industry character varying(100),
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.form_policies OWNER TO aiuser;

--
-- Name: TABLE form_policies; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.form_policies IS 'Reusable form templates for different industries or use cases';


--
-- Name: form_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.form_policies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.form_policies_id_seq OWNER TO aiuser;

--
-- Name: form_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.form_policies_id_seq OWNED BY public.form_policies.id;


--
-- Name: form_sections; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.form_sections (
    id integer NOT NULL,
    policy_id integer,
    section_key character varying(100) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    order_index integer NOT NULL,
    is_required boolean DEFAULT true,
    is_enabled boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.form_sections OWNER TO aiuser;

--
-- Name: TABLE form_sections; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.form_sections IS 'Configurable sections within each policy';


--
-- Name: form_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.form_sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.form_sections_id_seq OWNER TO aiuser;

--
-- Name: form_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.form_sections_id_seq OWNED BY public.form_sections.id;


--
-- Name: governance_approvals; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.governance_approvals OWNER TO aiuser;

--
-- Name: TABLE governance_approvals; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.governance_approvals IS 'Tracks multi-stakeholder approval workflow based on modification class';


--
-- Name: governance_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.governance_approvals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.governance_approvals_id_seq OWNER TO aiuser;

--
-- Name: governance_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.governance_approvals_id_seq OWNED BY public.governance_approvals.id;


--
-- Name: governance_evidence; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.governance_evidence OWNER TO aiuser;

--
-- Name: governance_evidence_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.governance_evidence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.governance_evidence_id_seq OWNER TO aiuser;

--
-- Name: governance_evidence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.governance_evidence_id_seq OWNED BY public.governance_evidence.id;


--
-- Name: governance_roles; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.governance_roles (
    id integer NOT NULL,
    role_name character varying(100) NOT NULL,
    role_description text,
    responsibilities text[],
    required_for_classes integer[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.governance_roles OWNER TO aiuser;

--
-- Name: governance_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.governance_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.governance_roles_id_seq OWNER TO aiuser;

--
-- Name: governance_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.governance_roles_id_seq OWNED BY public.governance_roles.id;


--
-- Name: modification_classes; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.modification_classes OWNER TO aiuser;

--
-- Name: TABLE modification_classes; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.modification_classes IS 'ISO/IEC 42001 + EU AI Act aligned model modification classification system';


--
-- Name: modification_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.modification_classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.modification_classes_id_seq OWNER TO aiuser;

--
-- Name: modification_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.modification_classes_id_seq OWNED BY public.modification_classes.id;


--
-- Name: modification_risk_scores; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.modification_risk_scores OWNER TO aiuser;

--
-- Name: TABLE modification_risk_scores; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.modification_risk_scores IS 'Risk scoring tied to modification class requirements';


--
-- Name: modification_risk_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.modification_risk_scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.modification_risk_scores_id_seq OWNER TO aiuser;

--
-- Name: modification_risk_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.modification_risk_scores_id_seq OWNED BY public.modification_risk_scores.id;


--
-- Name: organization_policies; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.organization_policies (
    id integer NOT NULL,
    organization_id integer,
    policy_id integer,
    is_active boolean DEFAULT true,
    customizations jsonb,
    activated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.organization_policies OWNER TO aiuser;

--
-- Name: TABLE organization_policies; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.organization_policies IS 'Maps organizations to their active policies';


--
-- Name: organization_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.organization_policies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organization_policies_id_seq OWNER TO aiuser;

--
-- Name: organization_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.organization_policies_id_seq OWNED BY public.organization_policies.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(100) NOT NULL,
    industry character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.organizations OWNER TO aiuser;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organizations_id_seq OWNER TO aiuser;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: policy_active_versions; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.policy_active_versions (
    id integer NOT NULL,
    policy_id integer,
    version_id integer,
    activated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activated_by integer
);


ALTER TABLE public.policy_active_versions OWNER TO aiuser;

--
-- Name: TABLE policy_active_versions; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.policy_active_versions IS 'Tracks which version is currently active for each policy';


--
-- Name: policy_active_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.policy_active_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.policy_active_versions_id_seq OWNER TO aiuser;

--
-- Name: policy_active_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.policy_active_versions_id_seq OWNED BY public.policy_active_versions.id;


--
-- Name: policy_audit_log; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.policy_audit_log (
    id integer NOT NULL,
    organization_id integer,
    policy_id integer,
    action character varying(50) NOT NULL,
    changed_by integer,
    changes jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.policy_audit_log OWNER TO aiuser;

--
-- Name: policy_audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.policy_audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.policy_audit_log_id_seq OWNER TO aiuser;

--
-- Name: policy_audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.policy_audit_log_id_seq OWNED BY public.policy_audit_log.id;


--
-- Name: policy_customizations; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.policy_customizations (
    id integer NOT NULL,
    organization_id integer,
    field_id integer,
    custom_label character varying(255),
    custom_help_text text,
    custom_options jsonb,
    custom_validation_rules jsonb,
    is_enabled boolean,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.policy_customizations OWNER TO aiuser;

--
-- Name: TABLE policy_customizations; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.policy_customizations IS 'Organization-specific overrides to policy fields';


--
-- Name: policy_customizations_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.policy_customizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.policy_customizations_id_seq OWNER TO aiuser;

--
-- Name: policy_customizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.policy_customizations_id_seq OWNED BY public.policy_customizations.id;


--
-- Name: policy_departments; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.policy_departments (
    id integer NOT NULL,
    policy_id integer,
    department_id integer,
    override_approved jsonb,
    override_denied jsonb,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    assigned_by integer
);


ALTER TABLE public.policy_departments OWNER TO aiuser;

--
-- Name: TABLE policy_departments; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.policy_departments IS 'Maps policies to specific departments with optional overrides';


--
-- Name: policy_departments_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.policy_departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.policy_departments_id_seq OWNER TO aiuser;

--
-- Name: policy_departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.policy_departments_id_seq OWNED BY public.policy_departments.id;


--
-- Name: policy_resource_restrictions; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.policy_resource_restrictions (
    id integer NOT NULL,
    policy_id integer,
    resource_id character varying(255) NOT NULL,
    resource_category character varying(50) NOT NULL,
    approval_status character varying(50) NOT NULL,
    allowed_use_cases text[],
    denied_use_cases text[],
    use_case_restriction_mode character varying(50) DEFAULT 'all'::character varying,
    restriction_reason text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT policy_resource_restrictions_approval_status_check CHECK (((approval_status)::text = ANY ((ARRAY['approved'::character varying, 'denied'::character varying, 'review'::character varying])::text[]))),
    CONSTRAINT policy_resource_restrictions_resource_category_check CHECK (((resource_category)::text = ANY ((ARRAY['model'::character varying, 'tool'::character varying, 'oss'::character varying, 'dataset'::character varying])::text[]))),
    CONSTRAINT policy_resource_restrictions_use_case_restriction_mode_check CHECK (((use_case_restriction_mode)::text = ANY ((ARRAY['all'::character varying, 'whitelist'::character varying, 'blacklist'::character varying])::text[])))
);


ALTER TABLE public.policy_resource_restrictions OWNER TO aiuser;

--
-- Name: TABLE policy_resource_restrictions; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.policy_resource_restrictions IS 'Fine-grained use case restrictions for approved AI resources';


--
-- Name: COLUMN policy_resource_restrictions.use_case_restriction_mode; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON COLUMN public.policy_resource_restrictions.use_case_restriction_mode IS 'all=no restrictions, whitelist=only specific use cases, blacklist=all except specific';


--
-- Name: policy_resource_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.policy_resource_restrictions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.policy_resource_restrictions_id_seq OWNER TO aiuser;

--
-- Name: policy_resource_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.policy_resource_restrictions_id_seq OWNED BY public.policy_resource_restrictions.id;


--
-- Name: policy_versions; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.policy_versions (
    id integer NOT NULL,
    policy_id integer,
    version_number integer NOT NULL,
    version_name character varying(255),
    snapshot jsonb NOT NULL,
    created_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_published boolean DEFAULT false
);


ALTER TABLE public.policy_versions OWNER TO aiuser;

--
-- Name: TABLE policy_versions; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.policy_versions IS 'Complete snapshots of policy configurations at specific points in time';


--
-- Name: policy_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.policy_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.policy_versions_id_seq OWNER TO aiuser;

--
-- Name: policy_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.policy_versions_id_seq OWNED BY public.policy_versions.id;


--
-- Name: post_market_monitoring; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.post_market_monitoring OWNER TO aiuser;

--
-- Name: TABLE post_market_monitoring; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.post_market_monitoring IS 'ISO 42001 + EU AI Act post-deployment monitoring requirements';


--
-- Name: post_market_monitoring_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.post_market_monitoring_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.post_market_monitoring_id_seq OWNER TO aiuser;

--
-- Name: post_market_monitoring_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.post_market_monitoring_id_seq OWNED BY public.post_market_monitoring.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL,
    applied_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.schema_migrations OWNER TO aiuser;

--
-- Name: submissions; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.submissions OWNER TO aiuser;

--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.submissions_id_seq OWNER TO aiuser;

--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: aiuser
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


ALTER TABLE public.users OWNER TO aiuser;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO aiuser;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: version_change_log; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.version_change_log (
    id integer NOT NULL,
    version_id integer,
    change_type character varying(50) NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id integer,
    field_name character varying(100),
    old_value jsonb,
    new_value jsonb,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.version_change_log OWNER TO aiuser;

--
-- Name: TABLE version_change_log; Type: COMMENT; Schema: public; Owner: aiuser
--

COMMENT ON TABLE public.version_change_log IS 'Detailed log of what changed in each version';


--
-- Name: version_change_log_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.version_change_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.version_change_log_id_seq OWNER TO aiuser;

--
-- Name: version_change_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.version_change_log_id_seq OWNED BY public.version_change_log.id;


--
-- Name: ai_catalog_items id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_items ALTER COLUMN id SET DEFAULT nextval('public.ai_catalog_items_id_seq'::regclass);


--
-- Name: ai_catalog_policies id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policies ALTER COLUMN id SET DEFAULT nextval('public.ai_catalog_policies_id_seq'::regclass);


--
-- Name: ai_catalog_policy_versions id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policy_versions ALTER COLUMN id SET DEFAULT nextval('public.ai_catalog_policy_versions_id_seq'::regclass);


--
-- Name: ai_incidents id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_incidents ALTER COLUMN id SET DEFAULT nextval('public.ai_incidents_id_seq'::regclass);


--
-- Name: ai_reviews id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_reviews ALTER COLUMN id SET DEFAULT nextval('public.ai_reviews_id_seq'::regclass);


--
-- Name: artifacts id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.artifacts ALTER COLUMN id SET DEFAULT nextval('public.artifacts_id_seq'::regclass);


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: conformity_assessments id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.conformity_assessments ALTER COLUMN id SET DEFAULT nextval('public.conformity_assessments_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: form_fields id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_fields ALTER COLUMN id SET DEFAULT nextval('public.form_fields_id_seq'::regclass);


--
-- Name: form_policies id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_policies ALTER COLUMN id SET DEFAULT nextval('public.form_policies_id_seq'::regclass);


--
-- Name: form_sections id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_sections ALTER COLUMN id SET DEFAULT nextval('public.form_sections_id_seq'::regclass);


--
-- Name: governance_approvals id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_approvals ALTER COLUMN id SET DEFAULT nextval('public.governance_approvals_id_seq'::regclass);


--
-- Name: governance_evidence id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_evidence ALTER COLUMN id SET DEFAULT nextval('public.governance_evidence_id_seq'::regclass);


--
-- Name: governance_roles id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_roles ALTER COLUMN id SET DEFAULT nextval('public.governance_roles_id_seq'::regclass);


--
-- Name: modification_classes id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.modification_classes ALTER COLUMN id SET DEFAULT nextval('public.modification_classes_id_seq'::regclass);


--
-- Name: modification_risk_scores id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.modification_risk_scores ALTER COLUMN id SET DEFAULT nextval('public.modification_risk_scores_id_seq'::regclass);


--
-- Name: organization_policies id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.organization_policies ALTER COLUMN id SET DEFAULT nextval('public.organization_policies_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: policy_active_versions id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_active_versions ALTER COLUMN id SET DEFAULT nextval('public.policy_active_versions_id_seq'::regclass);


--
-- Name: policy_audit_log id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_audit_log ALTER COLUMN id SET DEFAULT nextval('public.policy_audit_log_id_seq'::regclass);


--
-- Name: policy_customizations id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_customizations ALTER COLUMN id SET DEFAULT nextval('public.policy_customizations_id_seq'::regclass);


--
-- Name: policy_departments id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_departments ALTER COLUMN id SET DEFAULT nextval('public.policy_departments_id_seq'::regclass);


--
-- Name: policy_resource_restrictions id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_resource_restrictions ALTER COLUMN id SET DEFAULT nextval('public.policy_resource_restrictions_id_seq'::regclass);


--
-- Name: policy_versions id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_versions ALTER COLUMN id SET DEFAULT nextval('public.policy_versions_id_seq'::regclass);


--
-- Name: post_market_monitoring id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.post_market_monitoring ALTER COLUMN id SET DEFAULT nextval('public.post_market_monitoring_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: version_change_log id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.version_change_log ALTER COLUMN id SET DEFAULT nextval('public.version_change_log_id_seq'::regclass);


--
-- Data for Name: ai_catalog_items; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.ai_catalog_items (id, catalog_id, name, provider, category, description, tags, version, license, homepage_url, documentation_url, is_active, is_deprecated, deprecation_note, created_by, updated_by, created_at, updated_at) FROM stdin;
1	openai:gpt-4o	GPT-4o	OpenAI	model	\N	{llm,commercial,multimodal}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.595553	2025-11-17 17:56:52.595553
2	openai:gpt-4o-mini	GPT-4o Mini	OpenAI	model	\N	{llm,commercial,cost-effective}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.599548	2025-11-17 17:56:52.599548
3	openai:gpt-4-turbo	GPT-4 Turbo	OpenAI	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.601402	2025-11-17 17:56:52.601402
4	openai:gpt-4	GPT-4	OpenAI	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.604099	2025-11-17 17:56:52.604099
5	openai:gpt-3.5-turbo	GPT-3.5 Turbo	OpenAI	model	\N	{llm,commercial,cost-effective}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.607416	2025-11-17 17:56:52.607416
6	openai:o1	o1	OpenAI	model	\N	{llm,commercial,reasoning}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.609412	2025-11-17 17:56:52.609412
7	openai:o1-mini	o1 Mini	OpenAI	model	\N	{llm,commercial,reasoning,cost-effective}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.610713	2025-11-17 17:56:52.610713
8	openai:o3-mini	o3 Mini	OpenAI	model	\N	{llm,commercial,reasoning}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.611881	2025-11-17 17:56:52.611881
9	anthropic:claude-sonnet-4	Claude Sonnet 4	Anthropic	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.61281	2025-11-17 17:56:52.61281
10	anthropic:claude-3.7-sonnet	Claude 3.7 Sonnet	Anthropic	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.613975	2025-11-17 17:56:52.613975
11	anthropic:claude-3.5-sonnet	Claude 3.5 Sonnet	Anthropic	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.61478	2025-11-17 17:56:52.61478
12	anthropic:claude-3.5-haiku	Claude 3.5 Haiku	Anthropic	model	\N	{llm,commercial,fast}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.61559	2025-11-17 17:56:52.61559
13	anthropic:claude-3-opus	Claude 3 Opus	Anthropic	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.616376	2025-11-17 17:56:52.616376
14	google:gemini-2.0-flash-exp	Gemini 2.0 Flash Experimental	Google	model	\N	{llm,commercial,multimodal,experimental}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.618122	2025-11-17 17:56:52.618122
15	google:gemini-exp-1206	Gemini Experimental 1206	Google	model	\N	{llm,commercial,experimental}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.619267	2025-11-17 17:56:52.619267
16	google:gemini-1.5-pro	Gemini 1.5 Pro	Google	model	\N	{llm,commercial,multimodal}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.62026	2025-11-17 17:56:52.62026
17	google:gemini-1.5-flash	Gemini 1.5 Flash	Google	model	\N	{llm,commercial,fast}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.621221	2025-11-17 17:56:52.621221
18	meta:llama-3.3-70b	Llama 3.3 70B	Meta	model	\N	{llm,open-weights}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.622288	2025-11-17 17:56:52.622288
19	meta:llama-3.1-405b	Llama 3.1 405B	Meta	model	\N	{llm,open-weights,large}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.623251	2025-11-17 17:56:52.623251
20	meta:llama-3.1-70b	Llama 3.1 70B	Meta	model	\N	{llm,open-weights}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.624098	2025-11-17 17:56:52.624098
21	meta:llama-3.1-8b	Llama 3.1 8B	Meta	model	\N	{llm,open-weights,small}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.624933	2025-11-17 17:56:52.624933
22	meta:llama-3-70b	Llama 3 70B	Meta	model	\N	{llm,open-weights}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.625673	2025-11-17 17:56:52.625673
23	meta:llama-3-8b	Llama 3 8B	Meta	model	\N	{llm,open-weights,small}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.626523	2025-11-17 17:56:52.626523
24	mistral:mistral-large-2	Mistral Large 2	Mistral AI	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.627357	2025-11-17 17:56:52.627357
25	mistral:mistral-small	Mistral Small	Mistral AI	model	\N	{llm,commercial,cost-effective}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.62825	2025-11-17 17:56:52.62825
26	mistral:mixtral-8x22b	Mixtral 8x22B	Mistral AI	model	\N	{llm,open-weights}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.629201	2025-11-17 17:56:52.629201
27	mistral:mixtral-8x7b	Mixtral 8x7B	Mistral AI	model	\N	{llm,open-weights}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.630048	2025-11-17 17:56:52.630048
28	cohere:command-r-plus	Command R+	Cohere	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.630869	2025-11-17 17:56:52.630869
29	cohere:command-r	Command R	Cohere	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.631795	2025-11-17 17:56:52.631795
30	cohere:command	Command	Cohere	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.632606	2025-11-17 17:56:52.632606
31	aws:bedrock-titan-text-premier	Bedrock Titan Text Premier	AWS	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.633466	2025-11-17 17:56:52.633466
32	aws:bedrock-titan-text-express	Bedrock Titan Text Express	AWS	model	\N	{llm,commercial}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.634211	2025-11-17 17:56:52.634211
33	deepseek:deepseek-v3	DeepSeek V3	DeepSeek	model	\N	{llm,open-weights}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.635043	2025-11-17 17:56:52.635043
34	deepseek:deepseek-r1	DeepSeek R1	DeepSeek	model	\N	{llm,open-weights,reasoning}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.635868	2025-11-17 17:56:52.635868
35	qwen:qwen2.5-72b	Qwen 2.5 72B	Alibaba Cloud	model	\N	{llm,open-weights}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.636803	2025-11-17 17:56:52.636803
36	qwen:qwq-32b	QwQ 32B	Alibaba Cloud	model	\N	{llm,open-weights,reasoning}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.637574	2025-11-17 17:56:52.637574
37	llama-uncensored-*	Llama Uncensored (Wildcard)	Community	model	\N	{uncensored,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.638443	2025-11-17 17:56:52.638443
38	wizardlm-uncensored-*	WizardLM Uncensored (Wildcard)	Community	model	\N	{uncensored,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.639464	2025-11-17 17:56:52.639464
39	gpt4free-*	GPT4Free (Wildcard)	Community	model	\N	{reverse-engineered,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.640308	2025-11-17 17:56:52.640308
40	stable-diffusion-raw-*	Stable Diffusion Raw (Wildcard)	Stability AI	model	\N	{image-gen,uncensored}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.641258	2025-11-17 17:56:52.641258
41	github:copilot-enterprise	GitHub Copilot Enterprise	GitHub	tool	\N	{code-assistant,enterprise}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.642177	2025-11-17 17:56:52.642177
42	openai:enterprise	OpenAI Enterprise	OpenAI	tool	\N	{llm-api,enterprise}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.64298	2025-11-17 17:56:52.64298
43	perplexity:enterprise	Perplexity Enterprise	Perplexity	tool	\N	{search,enterprise}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.643804	2025-11-17 17:56:52.643804
44	microsoft:365-copilot-enterprise	Microsoft 365 Copilot Enterprise	Microsoft	tool	\N	{productivity,enterprise}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.644649	2025-11-17 17:56:52.644649
45	huggingface:inference-api	HuggingFace Inference API	HuggingFace	tool	\N	{ml-api,cloud}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.645418	2025-11-17 17:56:52.645418
46	local-inference	Local Inference	Self-hosted	tool	\N	{self-hosted,privacy}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.646208	2025-11-17 17:56:52.646208
47	characterai:*	Character.AI (Wildcard)	Character.AI	tool	\N	{chatbot,consumer}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.646966	2025-11-17 17:56:52.646966
48	midjourney:*	Midjourney (Wildcard)	Midjourney	tool	\N	{image-gen,consumer}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.647862	2025-11-17 17:56:52.647862
49	replika:*	Replika (Wildcard)	Replika	tool	\N	{chatbot,consumer}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.648662	2025-11-17 17:56:52.648662
50	huggingface/transformers	Transformers	HuggingFace	oss	\N	{library,apache-2.0}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.649584	2025-11-17 17:56:52.649584
51	huggingface/diffusers	Diffusers	HuggingFace	oss	\N	{library,apache-2.0,image-gen}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.650576	2025-11-17 17:56:52.650576
52	langchain	LangChain	LangChain	oss	\N	{framework,mit}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.651331	2025-11-17 17:56:52.651331
53	pytorch	PyTorch	Meta	oss	\N	{framework,bsd}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.652196	2025-11-17 17:56:52.652196
54	tensorflow	TensorFlow	Google	oss	\N	{framework,apache-2.0}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.652975	2025-11-17 17:56:52.652975
55	llama.cpp	llama.cpp	Community	oss	\N	{inference,mit}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.653888	2025-11-17 17:56:52.653888
56	vllm	vLLM	UC Berkeley	oss	\N	{inference,apache-2.0}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.65461	2025-11-17 17:56:52.65461
57	any:GPL-3.0	Any GPL-3.0 Software	Various	oss	\N	{gpl,copyleft}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.655708	2025-11-17 17:56:52.655708
58	hf:model:no-license	HF Models Without License	HuggingFace	oss	\N	{no-license,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.656465	2025-11-17 17:56:52.656465
59	hf:dataset:no-docs	HF Datasets Without Docs	HuggingFace	oss	\N	{no-docs,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.657187	2025-11-17 17:56:52.657187
60	hf:financial-sentiment-verified	Financial Sentiment (Verified)	HuggingFace	dataset	\N	{finance,verified}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.657907	2025-11-17 17:56:52.657907
61	hf:ms-marco-v1	MS MARCO v1	Microsoft	dataset	\N	{search,qa}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.658684	2025-11-17 17:56:52.658684
62	hf:wiki-en-cleaned	Wikipedia EN (Cleaned)	Wikimedia	dataset	\N	{knowledge,cleaned}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.659383	2025-11-17 17:56:52.659383
63	openclimate:climate-risk-dataset-v2	Climate Risk Dataset v2	OpenClimate	dataset	\N	{climate,risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.660208	2025-11-17 17:56:52.660208
64	customer-data-derived	Customer Data (Derived)	Internal	dataset	\N	{customer,pii}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.661228	2025-11-17 17:56:52.661228
65	user-uploaded	User Uploaded Data	Internal	dataset	\N	{user-generated,review-required}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.662085	2025-11-17 17:56:52.662085
66	fraud-detection	Fraud Detection	\N	use_case	\N	{finance,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.662945	2025-11-17 17:56:52.662945
67	credit-eligibility	Credit Eligibility	\N	use_case	\N	{finance,high-risk,ecoa}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.66393	2025-11-17 17:56:52.66393
68	aml-bsa	AML/BSA Compliance	\N	use_case	\N	{finance,compliance}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.665093	2025-11-17 17:56:52.665093
69	hr-screening	HR Candidate Screening	\N	use_case	\N	{hr,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.666141	2025-11-17 17:56:52.666141
70	customer-service	Customer Service / Support	\N	use_case	\N	{customer,low-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.66703	2025-11-17 17:56:52.66703
71	internal-productivity	Internal Productivity Tools	\N	use_case	\N	{internal,low-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.6679	2025-11-17 17:56:52.6679
72	code-generation	Code Generation / Development	\N	use_case	\N	{developer,medium-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.668764	2025-11-17 17:56:52.668764
73	content-creation	Content Creation / Marketing	\N	use_case	\N	{marketing,low-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.669651	2025-11-17 17:56:52.669651
74	data-analysis	Data Analysis / BI	\N	use_case	\N	{analytics,medium-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.670437	2025-11-17 17:56:52.670437
75	research	Research & Development	\N	use_case	\N	{research,medium-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.671212	2025-11-17 17:56:52.671212
76	legal-review	Legal Document Review	\N	use_case	\N	{legal,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.672014	2025-11-17 17:56:52.672014
77	risk-assessment	Risk Assessment	\N	use_case	\N	{risk,high-risk}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.672797	2025-11-17 17:56:52.672797
78	biometric-identification	Biometric Identification	\N	use_case	\N	{biometric,prohibited}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.67373	2025-11-17 17:56:52.67373
79	autonomous-medical-diagnosis	Autonomous Medical Diagnosis	\N	use_case	\N	{medical,prohibited}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.674561	2025-11-17 17:56:52.674561
80	political-profiling	Political Profiling	\N	use_case	\N	{political,prohibited}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.675409	2025-11-17 17:56:52.675409
81	unexplainable-credit-decisions	Unexplainable Credit Decisions	\N	use_case	\N	{credit,prohibited}	\N	\N	\N	\N	t	f	\N	\N	\N	2025-11-17 17:56:52.676109	2025-11-17 17:56:52.676109
\.


--
-- Data for Name: ai_catalog_policies; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.ai_catalog_policies (id, name, slug, description, approved_models, approved_tools, approved_oss, approved_datasets, denied_models, denied_tools, denied_oss, denied_datasets, denied_use_cases, review_models, review_tools, review_oss, review_datasets, review_use_cases, is_active, is_default, is_global, version, created_by, updated_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ai_catalog_policy_versions; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.ai_catalog_policy_versions (id, policy_id, version, policy_snapshot, change_description, changed_by, created_at) FROM stdin;
\.


--
-- Data for Name: ai_incidents; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.ai_incidents (id, submission_id, incident_date, incident_type, severity, description, affected_users, harm_caused, root_cause, corrective_actions, preventive_actions, reported_to_authorities, authority_notification_date, authority_response, status, reported_by, assigned_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ai_reviews; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.ai_reviews (id, submission_id, review_type, risk_score, risk_level, approval_recommendation, findings, regulatory_concerns, security_concerns, data_privacy_concerns, bias_concerns, recommendations, required_actions, pii_detected, pii_details, vendor_evaluation, full_review, reviewed_at, created_at) FROM stdin;
\.


--
-- Data for Name: artifacts; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.artifacts (id, submission_id, file_name, file_path, file_type, file_size, artifact_type, uploaded_at) FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.audit_log (id, submission_id, user_id, action, details, ip_address, created_at) FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.comments (id, submission_id, user_id, comment, is_internal, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: conformity_assessments; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.conformity_assessments (id, submission_id, assessment_type, assessment_date, assessor_name, assessor_organization, general_description, intended_purpose, risk_management_system, data_governance_measures, technical_documentation, transparency_provisions, human_oversight_measures, accuracy_robustness_measures, conformity_status, non_conformities, remediation_plan, next_assessment_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.departments (id, name, slug, description, parent_department_id, entra_id, entra_display_name, entra_last_sync, is_active, created_at, updated_at) FROM stdin;
1	Global	global	Default department for organization-wide policies	\N	\N	\N	\N	t	2025-11-17 17:53:26.502377	2025-11-17 17:53:26.502377
2	Engineering	engineering	Software development and technical teams	\N	\N	\N	\N	t	2025-11-17 17:56:56.247345	2025-11-17 17:56:56.247345
3	Product	product	Product management and design	\N	\N	\N	\N	t	2025-11-17 17:56:56.252596	2025-11-17 17:56:56.252596
4	Data Science	data-science	Data analytics and machine learning teams	\N	\N	\N	\N	t	2025-11-17 17:56:56.25456	2025-11-17 17:56:56.25456
5	Marketing	marketing	Marketing and communications	\N	\N	\N	\N	t	2025-11-17 17:56:56.256206	2025-11-17 17:56:56.256206
6	Sales	sales	Sales and business development	\N	\N	\N	\N	t	2025-11-17 17:56:56.258231	2025-11-17 17:56:56.258231
7	Customer Success	customer-success	Customer support and success	\N	\N	\N	\N	t	2025-11-17 17:56:56.259862	2025-11-17 17:56:56.259862
8	Finance	finance	Finance and accounting	\N	\N	\N	\N	t	2025-11-17 17:56:56.261295	2025-11-17 17:56:56.261295
9	Legal	legal	Legal and compliance	\N	\N	\N	\N	t	2025-11-17 17:56:56.26334	2025-11-17 17:56:56.26334
10	Human Resources	human-resources	HR and people operations	\N	\N	\N	\N	t	2025-11-17 17:56:56.26511	2025-11-17 17:56:56.26511
11	Operations	operations	Business operations	\N	\N	\N	\N	t	2025-11-17 17:56:56.267869	2025-11-17 17:56:56.267869
\.


--
-- Data for Name: form_fields; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.form_fields (id, section_id, field_key, label, field_type, placeholder, help_text, order_index, is_required, is_enabled, validation_rules, options, default_value, conditional_logic, created_at) FROM stdin;
1	1	project_name	Project Name	text	Enter project name	Internal project identifier	1	t	t	{"max": 255, "min": 1}	\N	\N	\N	2025-11-17 17:56:54.021818
2	1	model_origin	Model Origin	select	\N	Where did this model come from?	2	t	t	\N	[{"label": "Commercial Off-The-Shelf (COTS)", "value": "cots"}, {"label": "Open Source", "value": "open_source"}, {"label": "Homegrown/Custom Built", "value": "homegrown"}]	\N	\N	2025-11-17 17:56:54.021818
3	1	vendor_name	Vendor Name	text	Enter vendor name	For COTS models only	3	f	t	\N	\N	\N	\N	2025-11-17 17:56:54.021818
4	2	intended_purpose	Intended Purpose	textarea	Describe the intended use	What business problem does this solve?	1	t	t	{"min": 10}	\N	\N	\N	2025-11-17 17:56:54.02624
5	2	regulated_decisions	System Used For	multiselect	\N	Select all that apply	2	f	t	\N	[{"label": "Credit decisions (ECOA/Reg B)", "value": "credit"}, {"label": "Fraud decisions (FFIEC, AML/BSA)", "value": "fraud"}, {"label": "Identity verification (KYC, CIP)", "value": "kyc"}, {"label": "None of the above", "value": "none"}]	\N	\N	2025-11-17 17:56:54.02624
6	2	human_in_loop	Human in the Loop?	radio	\N	Is there human oversight?	3	t	t	\N	[{"label": "Yes", "value": "true"}, {"label": "No", "value": "false"}]	\N	\N	2025-11-17 17:56:54.02624
7	3	project_name	Project Name	text	Enter project name	\N	1	t	t	{"min": 1}	\N	\N	\N	2025-11-17 17:56:54.02971
8	3	clinical_use_case	Clinical Use Case	select	\N	Primary clinical application	2	t	t	\N	[{"label": "Diagnosis Support", "value": "diagnosis"}, {"label": "Treatment Planning", "value": "treatment"}, {"label": "Patient Monitoring", "value": "monitoring"}, {"label": "Administrative/Operational", "value": "administrative"}]	\N	\N	2025-11-17 17:56:54.02971
9	3	patient_impact	Patient Impact Level	select	\N	Direct impact on patient care decisions	3	t	t	\N	[{"label": "High - Direct clinical decisions", "value": "high"}, {"label": "Medium - Indirect clinical support", "value": "medium"}, {"label": "Low - Administrative only", "value": "low"}]	\N	\N	2025-11-17 17:56:54.02971
10	4	uses_phi	Uses Protected Health Information (PHI)?	radio	\N	Does this system process PHI?	1	t	t	\N	[{"label": "Yes", "value": "true"}, {"label": "No", "value": "false"}]	\N	\N	2025-11-17 17:56:54.031732
11	4	phi_types	PHI Data Types	multiselect	\N	Select all that apply	2	f	t	\N	[{"label": "Demographic Information", "value": "demographic"}, {"label": "Diagnosis Codes", "value": "diagnosis"}, {"label": "Treatment Records", "value": "treatment"}, {"label": "Lab Results", "value": "lab"}, {"label": "Medical Imaging", "value": "imaging"}]	\N	\N	2025-11-17 17:56:54.031732
12	4	hipaa_compliance	HIPAA Compliance Controls	textarea	Describe HIPAA safeguards	What technical and administrative controls are in place?	3	t	t	{"min": 20}	\N	\N	\N	2025-11-17 17:56:54.031732
13	5	project_name	Project Name	text	Enter project name	\N	1	t	t	{"min": 1}	\N	\N	\N	2025-11-17 17:56:54.033051
14	5	use_case_category	Use Case Category	select	\N	Primary application area	2	t	t	\N	[{"label": "Personalization & Recommendations", "value": "personalization"}, {"label": "Search & Discovery", "value": "search"}, {"label": "Dynamic Pricing", "value": "pricing"}, {"label": "Inventory Optimization", "value": "inventory"}, {"label": "Customer Support", "value": "support"}]	\N	\N	2025-11-17 17:56:54.033051
15	5	customer_facing	Customer-Facing?	radio	\N	Is this visible to customers?	3	t	t	\N	[{"label": "Yes - Customer-facing", "value": "true"}, {"label": "No - Internal only", "value": "false"}]	\N	\N	2025-11-17 17:56:54.033051
16	6	customer_data_types	Customer Data Types Used	multiselect	\N	What customer data is used?	1	t	t	\N	[{"label": "Behavioral/Clickstream", "value": "behavioral"}, {"label": "Purchase History", "value": "purchase"}, {"label": "Demographics", "value": "demographic"}, {"label": "Stated Preferences", "value": "preferences"}, {"label": "Location Data", "value": "location"}]	\N	\N	2025-11-17 17:56:54.034116
17	6	gdpr_compliant	GDPR Compliance	radio	\N	For EU customers	2	t	t	\N	[{"label": "Yes - GDPR controls in place", "value": "yes"}, {"label": "No - No EU customers", "value": "no"}, {"label": "Implementation planned", "value": "planned"}]	\N	\N	2025-11-17 17:56:54.034116
18	6	opt_out_mechanism	Customer Opt-Out Mechanism	text	Describe opt-out process	How can customers opt out of AI personalization?	3	f	t	\N	\N	\N	\N	2025-11-17 17:56:54.034116
19	7	project_name	Project Name	text	Enter project name	\N	1	t	t	{"min": 1}	\N	\N	\N	2025-11-17 17:56:54.038206
20	7	business_function	Business Function	select	\N	Which department/function?	2	t	t	\N	[{"label": "Human Resources", "value": "hr"}, {"label": "Finance", "value": "finance"}, {"label": "Operations", "value": "operations"}, {"label": "Sales & Marketing", "value": "sales"}, {"label": "IT & Engineering", "value": "it"}]	\N	\N	2025-11-17 17:56:54.038206
21	7	intended_purpose	Intended Purpose	textarea	Describe the purpose	What problem does this solve?	3	t	t	{"min": 10}	\N	\N	\N	2025-11-17 17:56:54.038206
22	7	risk_level	Risk Assessment	select	\N	Initial risk categorization	4	t	t	\N	[{"label": "Low - Internal tooling", "value": "low"}, {"label": "Medium - Business impact", "value": "medium"}, {"label": "High - Critical decisions", "value": "high"}]	\N	\N	2025-11-17 17:56:54.038206
\.


--
-- Data for Name: form_policies; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.form_policies (id, name, slug, description, industry, is_default, is_active, created_by, created_at, updated_at) FROM stdin;
1	Financial Services AI Governance	fintech-governance	Comprehensive intake form for financial institutions with focus on ECOA/Reg B, FFIEC, AML/BSA, KYC/CIP compliance	fintech	t	t	\N	2025-11-17 17:56:54.005752	2025-11-17 17:56:54.005752
2	Healthcare AI Compliance	healthcare-compliance	Healthcare-specific intake form focused on HIPAA, PHI protection, clinical decision support standards	healthcare	f	t	\N	2025-11-17 17:56:54.013542	2025-11-17 17:56:54.013542
3	Retail & E-commerce AI	retail-ai	Streamlined intake for retail AI focusing on customer experience, personalization, and data privacy	retail	f	t	\N	2025-11-17 17:56:54.015443	2025-11-17 17:56:54.015443
4	General Enterprise AI	enterprise-general	General-purpose AI intake form suitable for most enterprise use cases	general	f	t	\N	2025-11-17 17:56:54.016937	2025-11-17 17:56:54.016937
\.


--
-- Data for Name: form_sections; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.form_sections (id, policy_id, section_key, title, description, order_index, is_required, is_enabled, created_at) FROM stdin;
1	1	section1	Project & Model Overview	Basic information about the AI model	1	t	t	2025-11-17 17:56:54.018279
2	1	section2	Intended Use & Regulatory Scope	How will the model be used and what regulations apply	2	t	t	2025-11-17 17:56:54.024317
3	2	section1	Clinical Context	Clinical application and patient impact	1	t	t	2025-11-17 17:56:54.027757
4	2	section2	PHI & Data Privacy	Protected Health Information handling	2	t	t	2025-11-17 17:56:54.030874
5	3	section1	Customer Experience Use Case	How this AI enhances customer experience	1	t	t	2025-11-17 17:56:54.032524
6	3	section2	Data & Privacy	Customer data usage and privacy compliance	2	t	t	2025-11-17 17:56:54.03362
7	4	section1	AI System Overview	Basic information about the AI system	1	t	t	2025-11-17 17:56:54.034849
\.


--
-- Data for Name: governance_approvals; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.governance_approvals (id, submission_id, role_id, approver_user_id, approval_status, approval_date, comments, evidence_reviewed, conditions, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: governance_evidence; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.governance_evidence (id, submission_id, evidence_type, evidence_category, file_path, metadata, uploaded_by, uploaded_at) FROM stdin;
\.


--
-- Data for Name: governance_roles; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.governance_roles (id, role_name, role_description, responsibilities, required_for_classes, created_at) FROM stdin;
1	Model Owner	Business owner responsible for model use case and outcomes	{"Define business requirements","Approve use cases","Monitor business metrics"}	{0,1,2,3,4,5,6}	2025-11-17 17:53:26.439812
2	Technical Reviewer	Technical expert reviewing implementation	{"Review technical implementation","Validate architecture","Approve technical approach"}	{0,1,2}	2025-11-17 17:53:26.439812
3	AI Safety Officer	Responsible for AI safety and ethics	{"Conduct safety reviews","Evaluate bias and fairness","Approve safety measures"}	{3,4,5,6}	2025-11-17 17:53:26.439812
4	Data Governance Officer	Oversees data quality and compliance	{"Validate data provenance","Ensure data quality","Approve data usage"}	{2,3,4}	2025-11-17 17:53:26.439812
5	Security Reviewer	Reviews security and privacy controls	{"Assess security risks","Validate controls","Approve security measures"}	{2,3,4,5,6}	2025-11-17 17:53:26.439812
6	Legal Counsel	Provides legal review and compliance	{"Review legal compliance","Assess regulatory requirements","Approve legal aspects"}	{4,6}	2025-11-17 17:53:26.439812
7	Data Protection Officer	GDPR/privacy compliance	{"Conduct privacy impact assessments","Ensure GDPR compliance","Approve data processing"}	{4}	2025-11-17 17:53:26.439812
8	Chief AI Officer	Senior leadership approval for high-risk AI	{"Strategic oversight","Final approval for high-risk systems","Set AI governance policy"}	{4,6}	2025-11-17 17:53:26.439812
9	CISO	Chief Information Security Officer	{"Approve security architecture","Final security sign-off","Oversee security compliance"}	{4,6}	2025-11-17 17:53:26.439812
10	CTO	Chief Technology Officer	{"Approve substantial technical changes","Strategic technology decisions","Architecture oversight"}	{6}	2025-11-17 17:53:26.439812
11	Ethics Board	Ethical review committee	{"Conduct ethical reviews","Evaluate societal impact","Approve ethical considerations"}	{4,5}	2025-11-17 17:53:26.439812
\.


--
-- Data for Name: modification_classes; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.modification_classes (id, class_number, class_name, risk_level, eu_ai_act_category, iso_42001_focus, description, obligations, approval_requirements, required_evidence, monitoring_requirements, created_at) FROM stdin;
1	0	Pure Base Model (No Modifications)	Low	Minimal / Limited-risk	Transparency + Acceptable Use	Using a pre-trained model without any modifications, including prompts, fine-tuning, or RAG.	{"usage": ["Within permitted domain"], "safety": ["Vendor safety guardrails"], "verification": ["License for commercial use"], "documentation": ["Model name, vendor, version"]}	{"authority": "Model Owner", "reviewers": ["Technical Reviewer"]}	{"Model card","Version documentation","License agreement","Business justification"}	{"Access control logs","Usage monitoring"}	2025-11-17 17:53:26.439812
2	1	Prompt Engineering Only	Low	Non-HRM, minimal-risk	Transparency + Change Management	Using system prompts or prompt templates to guide model behavior without changing model weights.	{"data": ["No PII in prompts"], "safety": ["Prompt safety review"], "documentation": ["Versioned prompt templates", "System prompts"]}	{"authority": "Model Owner + Reviewer", "reviewers": ["Technical Reviewer"]}	{"Prompt template version history","Safety review results","Use case documentation"}	{"Prompt version control","Behavior consistency analysis"}	2025-11-17 17:53:26.439812
3	2	RAG (Retrieval-Augmented Generation)	Medium	Limited or High Risk (context-dependent)	Data governance + Monitoring	Augmenting model outputs with retrieved information from a knowledge base or vector database.	{"legal": ["Licensing", "Copyright validation"], "privacy": ["PII controls", "Data minimization"], "security": ["Access management", "Query logging"], "documentation": ["Corpus sources", "Data lineage"]}	{"authority": "AI Reviewer + Data Governance", "reviewers": ["Data Governance Officer", "Security Reviewer"]}	{"Data lineage diagrams","Retrieval logs","Copyright compliance review","PII protection controls","Data minimization assessment"}	{"Retrieval query logging","Data leakage detection","Access audit logs"}	2025-11-17 17:53:26.439812
4	3	LoRA / QLoRA / PEFT (Adapter Fine-Tuning)	Medium-High	May be High-Risk (domain-dependent)	Lifecycle + Training Data Governance	Fine-tuning model using parameter-efficient methods (LoRA, QLoRA, adapters) that update only a small subset of parameters.	{"legal": ["Dataset legality", "Copyright", "Privacy"], "testing": ["Safety tests", "Bias evaluation"], "documentation": ["Training dataset provenance", "Dataset quality controls", "Adapter versioning"], "reproducibility": ["Training logs", "Hyperparameters"]}	{"authority": "AI Risk Committee", "reviewers": ["AI Safety Officer", "Legal", "Security", "Data Governance"]}	{"Training dataset documentation","Dataset provenance","Safety test results","Bias evaluation report","Adapter weights versioning","Reproducibility documentation","Impact assessment"}	{"Model performance monitoring","Drift detection","Bias monitoring","Safety incident tracking"}	2025-11-17 17:53:26.439812
5	4	Full Fine-Tuning (Weight Overwrite)	High	High-Risk / GPAI with Systemic Risk	Full AI Management System Controls	Complete retraining or fine-tuning that modifies all model weights, creating essentially a new model.	{"legal": ["Privacy impact assessment", "Copyright compliance"], "testing": ["Comprehensive safety testing", "Bias testing", "Robustness testing", "Red-team adversarial testing"], "monitoring": ["Drift detection", "Harm detection"], "documentation": ["Full dataset disclosure", "Data governance plan", "Model lineage"], "reproducibility": ["Training pipeline", "Version control"]}	{"authority": "Risk Committee + Legal + Security", "reviewers": ["Chief AI Officer", "Legal Counsel", "CISO", "Data Protection Officer", "Ethics Board"]}	{"Complete training metadata","Dataset disclosure","Data governance plan","Privacy impact assessment","Copyright compliance review","Safety test suite results","Bias evaluation","Robustness testing","Red-team results","Conformity assessment","Technical documentation package","Post-market monitoring plan"}	{"Continuous monitoring","Drift detection","Harm detection","Incident reporting","Performance tracking","Bias monitoring"}	2025-11-17 17:53:26.439812
6	5	Safety Alignment Tuning	Medium-High	Often High-Risk	Safety + Monitoring + Evaluation	Fine-tuning specifically to improve safety, reduce harm, or align model behavior with human values (e.g., RLHF, DPO, Constitutional AI).	{"testing": ["Bias assessment", "Safety improvement evidence", "False refusal/compliance rates"], "documentation": ["Alignment methods", "Alignment dataset lineage"]}	{"authority": "AI Risk Committee", "reviewers": ["AI Safety Officer", "Ethics Board", "Security"]}	{"Alignment methodology documentation","Alignment dataset provenance","Pre/post safety metrics","Bias evaluation","False refusal analysis","Safety test results"}	{"Safety monitoring","Alignment drift detection","Human oversight logs"}	2025-11-17 17:53:26.439812
7	6	Custom Tokenizer	Very High	High-Risk / Substantial Modification	Full Lifecycle Controls + Extensive Documentation	Modifying or replacing the model tokenizer, which fundamentally changes how the model processes inputs.	{"legal": ["Substantial modification declaration"], "testing": ["Full re-evaluation", "Stability testing", "Safety tests", "Bias tests"], "documentation": ["Tokenizer specification", "Design rationale", "Vocabulary changes"], "reproducibility": ["Tokenizer versioning", "Change control"]}	{"authority": "Risk Committee + Legal + CTO", "reviewers": ["CTO", "Chief AI Officer", "Legal Counsel", "CISO", "AI Safety Officer"]}	{"Tokenizer specification","Design rationale","Vocabulary documentation","Regression test results","Stability evaluation","Safety test suite","Bias evaluation","Substantial modification package","Technical documentation","Conformity assessment"}	{"Comprehensive monitoring","Stability tracking","Safety incident detection","Performance regression detection"}	2025-11-17 17:53:26.439812
\.


--
-- Data for Name: modification_risk_scores; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.modification_risk_scores (id, submission_id, modification_class, licensing_risk, data_governance_risk, safety_alignment_risk, transparency_risk, security_risk, compliance_risk, overall_risk_score, risk_factors, calculated_at) FROM stdin;
\.


--
-- Data for Name: organization_policies; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.organization_policies (id, organization_id, policy_id, is_active, customizations, activated_at) FROM stdin;
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.organizations (id, name, slug, industry, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: policy_active_versions; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.policy_active_versions (id, policy_id, version_id, activated_at, activated_by) FROM stdin;
\.


--
-- Data for Name: policy_audit_log; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.policy_audit_log (id, organization_id, policy_id, action, changed_by, changes, created_at) FROM stdin;
\.


--
-- Data for Name: policy_customizations; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.policy_customizations (id, organization_id, field_id, custom_label, custom_help_text, custom_options, custom_validation_rules, is_enabled, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: policy_departments; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.policy_departments (id, policy_id, department_id, override_approved, override_denied, assigned_at, assigned_by) FROM stdin;
\.


--
-- Data for Name: policy_resource_restrictions; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.policy_resource_restrictions (id, policy_id, resource_id, resource_category, approval_status, allowed_use_cases, denied_use_cases, use_case_restriction_mode, restriction_reason, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: policy_versions; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.policy_versions (id, policy_id, version_number, version_name, snapshot, created_by, created_at, is_published) FROM stdin;
\.


--
-- Data for Name: post_market_monitoring; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.post_market_monitoring (id, submission_id, monitoring_date, monitoring_type, performance_metrics, drift_detected, drift_details, safety_incidents, incident_details, bias_metrics, bias_concerns, user_complaints, complaint_summary, actions_required, actions_taken, reported_by, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.schema_migrations (version, applied_at) FROM stdin;
base-schema	2025-11-17 17:53:26.36229
006_form_configuration.sql	2025-11-17 17:53:26.414136
007_policy_versioning.sql	2025-11-17 17:53:26.436721
009_ai_governance_framework.sql	2025-11-17 17:53:26.500574
010_ai_catalog_policies.sql	2025-11-17 17:53:26.549699
011_use_case_restrictions.sql	2025-11-17 17:53:26.568078
012_ai_catalog_items.sql	2025-11-17 17:53:26.582076
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.submissions (id, user_id, project_name, model_name, model_type, model_type_other, model_origin, model_origin_name, model_origin_version, model_origin_url, vendor_name, intended_purpose, business_impact_category, regulated_decisions, human_in_loop, data_sources, contains_customer_data, labels_modified, labels_description, modifications, training_config_location, deployment_location, deployment_location_other, access_teams, input_format, output_format, sees_sensitive_data, safety_features, known_risks, status, submitted_at, reviewed_at, reviewer_id, created_at, updated_at, modification_class, governance_data, conformity_status, iso_42001_compliant, eu_ai_act_compliant) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.users (id, email, password_hash, full_name, role, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: version_change_log; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.version_change_log (id, version_id, change_type, entity_type, entity_id, field_name, old_value, new_value, description, created_at) FROM stdin;
\.


--
-- Name: ai_catalog_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.ai_catalog_items_id_seq', 81, true);


--
-- Name: ai_catalog_policies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.ai_catalog_policies_id_seq', 1, false);


--
-- Name: ai_catalog_policy_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.ai_catalog_policy_versions_id_seq', 1, false);


--
-- Name: ai_incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.ai_incidents_id_seq', 1, false);


--
-- Name: ai_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.ai_reviews_id_seq', 1, false);


--
-- Name: artifacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.artifacts_id_seq', 1, false);


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, false);


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.comments_id_seq', 1, false);


--
-- Name: conformity_assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.conformity_assessments_id_seq', 1, false);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.departments_id_seq', 11, true);


--
-- Name: form_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.form_fields_id_seq', 22, true);


--
-- Name: form_policies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.form_policies_id_seq', 4, true);


--
-- Name: form_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.form_sections_id_seq', 7, true);


--
-- Name: governance_approvals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.governance_approvals_id_seq', 1, false);


--
-- Name: governance_evidence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.governance_evidence_id_seq', 1, false);


--
-- Name: governance_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.governance_roles_id_seq', 11, true);


--
-- Name: modification_classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.modification_classes_id_seq', 7, true);


--
-- Name: modification_risk_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.modification_risk_scores_id_seq', 1, false);


--
-- Name: organization_policies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.organization_policies_id_seq', 1, false);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.organizations_id_seq', 1, false);


--
-- Name: policy_active_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.policy_active_versions_id_seq', 1, false);


--
-- Name: policy_audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.policy_audit_log_id_seq', 1, false);


--
-- Name: policy_customizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.policy_customizations_id_seq', 1, false);


--
-- Name: policy_departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.policy_departments_id_seq', 1, false);


--
-- Name: policy_resource_restrictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.policy_resource_restrictions_id_seq', 1, false);


--
-- Name: policy_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.policy_versions_id_seq', 1, false);


--
-- Name: post_market_monitoring_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.post_market_monitoring_id_seq', 1, false);


--
-- Name: submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.submissions_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: version_change_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.version_change_log_id_seq', 1, false);


--
-- Name: ai_catalog_items ai_catalog_items_catalog_id_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_items
    ADD CONSTRAINT ai_catalog_items_catalog_id_key UNIQUE (catalog_id);


--
-- Name: ai_catalog_items ai_catalog_items_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_items
    ADD CONSTRAINT ai_catalog_items_pkey PRIMARY KEY (id);


--
-- Name: ai_catalog_policies ai_catalog_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policies
    ADD CONSTRAINT ai_catalog_policies_pkey PRIMARY KEY (id);


--
-- Name: ai_catalog_policies ai_catalog_policies_slug_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policies
    ADD CONSTRAINT ai_catalog_policies_slug_key UNIQUE (slug);


--
-- Name: ai_catalog_policy_versions ai_catalog_policy_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policy_versions
    ADD CONSTRAINT ai_catalog_policy_versions_pkey PRIMARY KEY (id);


--
-- Name: ai_incidents ai_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_incidents
    ADD CONSTRAINT ai_incidents_pkey PRIMARY KEY (id);


--
-- Name: ai_reviews ai_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_reviews
    ADD CONSTRAINT ai_reviews_pkey PRIMARY KEY (id);


--
-- Name: artifacts artifacts_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.artifacts
    ADD CONSTRAINT artifacts_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: conformity_assessments conformity_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.conformity_assessments
    ADD CONSTRAINT conformity_assessments_pkey PRIMARY KEY (id);


--
-- Name: departments departments_entra_id_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_entra_id_key UNIQUE (entra_id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: departments departments_slug_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_slug_key UNIQUE (slug);


--
-- Name: form_fields form_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_fields
    ADD CONSTRAINT form_fields_pkey PRIMARY KEY (id);


--
-- Name: form_fields form_fields_section_id_field_key_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_fields
    ADD CONSTRAINT form_fields_section_id_field_key_key UNIQUE (section_id, field_key);


--
-- Name: form_policies form_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_policies
    ADD CONSTRAINT form_policies_pkey PRIMARY KEY (id);


--
-- Name: form_policies form_policies_slug_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_policies
    ADD CONSTRAINT form_policies_slug_key UNIQUE (slug);


--
-- Name: form_sections form_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_sections
    ADD CONSTRAINT form_sections_pkey PRIMARY KEY (id);


--
-- Name: form_sections form_sections_policy_id_section_key_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_sections
    ADD CONSTRAINT form_sections_policy_id_section_key_key UNIQUE (policy_id, section_key);


--
-- Name: governance_approvals governance_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_approvals
    ADD CONSTRAINT governance_approvals_pkey PRIMARY KEY (id);


--
-- Name: governance_evidence governance_evidence_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_evidence
    ADD CONSTRAINT governance_evidence_pkey PRIMARY KEY (id);


--
-- Name: governance_roles governance_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_roles
    ADD CONSTRAINT governance_roles_pkey PRIMARY KEY (id);


--
-- Name: governance_roles governance_roles_role_name_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_roles
    ADD CONSTRAINT governance_roles_role_name_key UNIQUE (role_name);


--
-- Name: modification_classes modification_classes_class_number_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.modification_classes
    ADD CONSTRAINT modification_classes_class_number_key UNIQUE (class_number);


--
-- Name: modification_classes modification_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.modification_classes
    ADD CONSTRAINT modification_classes_pkey PRIMARY KEY (id);


--
-- Name: modification_risk_scores modification_risk_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.modification_risk_scores
    ADD CONSTRAINT modification_risk_scores_pkey PRIMARY KEY (id);


--
-- Name: organization_policies organization_policies_organization_id_policy_id_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.organization_policies
    ADD CONSTRAINT organization_policies_organization_id_policy_id_key UNIQUE (organization_id, policy_id);


--
-- Name: organization_policies organization_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.organization_policies
    ADD CONSTRAINT organization_policies_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_slug_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_slug_key UNIQUE (slug);


--
-- Name: policy_active_versions policy_active_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_active_versions
    ADD CONSTRAINT policy_active_versions_pkey PRIMARY KEY (id);


--
-- Name: policy_active_versions policy_active_versions_policy_id_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_active_versions
    ADD CONSTRAINT policy_active_versions_policy_id_key UNIQUE (policy_id);


--
-- Name: policy_audit_log policy_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_audit_log
    ADD CONSTRAINT policy_audit_log_pkey PRIMARY KEY (id);


--
-- Name: policy_customizations policy_customizations_organization_id_field_id_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_customizations
    ADD CONSTRAINT policy_customizations_organization_id_field_id_key UNIQUE (organization_id, field_id);


--
-- Name: policy_customizations policy_customizations_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_customizations
    ADD CONSTRAINT policy_customizations_pkey PRIMARY KEY (id);


--
-- Name: policy_departments policy_departments_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_departments
    ADD CONSTRAINT policy_departments_pkey PRIMARY KEY (id);


--
-- Name: policy_departments policy_departments_policy_id_department_id_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_departments
    ADD CONSTRAINT policy_departments_policy_id_department_id_key UNIQUE (policy_id, department_id);


--
-- Name: policy_resource_restrictions policy_resource_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_resource_restrictions
    ADD CONSTRAINT policy_resource_restrictions_pkey PRIMARY KEY (id);


--
-- Name: policy_resource_restrictions policy_resource_restrictions_policy_id_resource_id_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_resource_restrictions
    ADD CONSTRAINT policy_resource_restrictions_policy_id_resource_id_key UNIQUE (policy_id, resource_id);


--
-- Name: policy_versions policy_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_versions
    ADD CONSTRAINT policy_versions_pkey PRIMARY KEY (id);


--
-- Name: policy_versions policy_versions_policy_id_version_number_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_versions
    ADD CONSTRAINT policy_versions_policy_id_version_number_key UNIQUE (policy_id, version_number);


--
-- Name: post_market_monitoring post_market_monitoring_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.post_market_monitoring
    ADD CONSTRAINT post_market_monitoring_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: version_change_log version_change_log_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.version_change_log
    ADD CONSTRAINT version_change_log_pkey PRIMARY KEY (id);


--
-- Name: idx_ai_catalog_items_active; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_items_active ON public.ai_catalog_items USING btree (is_active);


--
-- Name: idx_ai_catalog_items_catalog_id; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_items_catalog_id ON public.ai_catalog_items USING btree (catalog_id);


--
-- Name: idx_ai_catalog_items_category; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_items_category ON public.ai_catalog_items USING btree (category);


--
-- Name: idx_ai_catalog_items_provider; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_items_provider ON public.ai_catalog_items USING btree (provider);


--
-- Name: idx_ai_catalog_items_tags; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_items_tags ON public.ai_catalog_items USING gin (tags);


--
-- Name: idx_ai_catalog_policies_active; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_policies_active ON public.ai_catalog_policies USING btree (is_active);


--
-- Name: idx_ai_catalog_policies_default; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_policies_default ON public.ai_catalog_policies USING btree (is_default);


--
-- Name: idx_ai_catalog_policies_global; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_policies_global ON public.ai_catalog_policies USING btree (is_global);


--
-- Name: idx_ai_catalog_policies_slug; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_policies_slug ON public.ai_catalog_policies USING btree (slug);


--
-- Name: idx_ai_catalog_policy_versions_policy; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_catalog_policy_versions_policy ON public.ai_catalog_policy_versions USING btree (policy_id);


--
-- Name: idx_ai_incidents_severity; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_incidents_severity ON public.ai_incidents USING btree (severity);


--
-- Name: idx_ai_incidents_submission; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_incidents_submission ON public.ai_incidents USING btree (submission_id);


--
-- Name: idx_ai_reviews_submission_id; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_ai_reviews_submission_id ON public.ai_reviews USING btree (submission_id);


--
-- Name: idx_artifacts_submission_id; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_artifacts_submission_id ON public.artifacts USING btree (submission_id);


--
-- Name: idx_audit_log_submission_id; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_audit_log_submission_id ON public.audit_log USING btree (submission_id);


--
-- Name: idx_comments_submission_id; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_comments_submission_id ON public.comments USING btree (submission_id);


--
-- Name: idx_conformity_assessments_submission; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_conformity_assessments_submission ON public.conformity_assessments USING btree (submission_id);


--
-- Name: idx_departments_entra_id; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_departments_entra_id ON public.departments USING btree (entra_id);


--
-- Name: idx_departments_parent; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_departments_parent ON public.departments USING btree (parent_department_id);


--
-- Name: idx_departments_slug; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_departments_slug ON public.departments USING btree (slug);


--
-- Name: idx_form_fields_section; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_form_fields_section ON public.form_fields USING btree (section_id);


--
-- Name: idx_form_sections_policy; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_form_sections_policy ON public.form_sections USING btree (policy_id);


--
-- Name: idx_governance_approvals_status; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_governance_approvals_status ON public.governance_approvals USING btree (approval_status);


--
-- Name: idx_governance_approvals_submission; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_governance_approvals_submission ON public.governance_approvals USING btree (submission_id);


--
-- Name: idx_governance_evidence_submission; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_governance_evidence_submission ON public.governance_evidence USING btree (submission_id);


--
-- Name: idx_modification_risk_scores_submission; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_modification_risk_scores_submission ON public.modification_risk_scores USING btree (submission_id);


--
-- Name: idx_org_policies_org; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_org_policies_org ON public.organization_policies USING btree (organization_id);


--
-- Name: idx_policy_active_versions_policy; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_active_versions_policy ON public.policy_active_versions USING btree (policy_id);


--
-- Name: idx_policy_audit_org; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_audit_org ON public.policy_audit_log USING btree (organization_id);


--
-- Name: idx_policy_customizations_org; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_customizations_org ON public.policy_customizations USING btree (organization_id);


--
-- Name: idx_policy_departments_department; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_departments_department ON public.policy_departments USING btree (department_id);


--
-- Name: idx_policy_departments_policy; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_departments_policy ON public.policy_departments USING btree (policy_id);


--
-- Name: idx_policy_resource_restrictions_policy; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_resource_restrictions_policy ON public.policy_resource_restrictions USING btree (policy_id);


--
-- Name: idx_policy_resource_restrictions_resource; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_resource_restrictions_resource ON public.policy_resource_restrictions USING btree (resource_id);


--
-- Name: idx_policy_resource_restrictions_status; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_resource_restrictions_status ON public.policy_resource_restrictions USING btree (approval_status);


--
-- Name: idx_policy_versions_policy; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_policy_versions_policy ON public.policy_versions USING btree (policy_id);


--
-- Name: idx_post_market_monitoring_submission; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_post_market_monitoring_submission ON public.post_market_monitoring USING btree (submission_id);


--
-- Name: idx_submissions_conformity_status; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_submissions_conformity_status ON public.submissions USING btree (conformity_status);


--
-- Name: idx_submissions_created_at; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_submissions_created_at ON public.submissions USING btree (created_at);


--
-- Name: idx_submissions_modification_class; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_submissions_modification_class ON public.submissions USING btree (modification_class);


--
-- Name: idx_submissions_status; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_submissions_status ON public.submissions USING btree (status);


--
-- Name: idx_submissions_user_id; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_submissions_user_id ON public.submissions USING btree (user_id);


--
-- Name: idx_version_change_log_version; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX idx_version_change_log_version ON public.version_change_log USING btree (version_id);


--
-- Name: unique_default_policy; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE UNIQUE INDEX unique_default_policy ON public.ai_catalog_policies USING btree (is_default) WHERE (is_default = true);


--
-- Name: ai_catalog_items ai_catalog_items_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_items
    ADD CONSTRAINT ai_catalog_items_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: ai_catalog_items ai_catalog_items_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_items
    ADD CONSTRAINT ai_catalog_items_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: ai_catalog_policies ai_catalog_policies_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policies
    ADD CONSTRAINT ai_catalog_policies_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: ai_catalog_policies ai_catalog_policies_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policies
    ADD CONSTRAINT ai_catalog_policies_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: ai_catalog_policy_versions ai_catalog_policy_versions_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policy_versions
    ADD CONSTRAINT ai_catalog_policy_versions_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- Name: ai_catalog_policy_versions ai_catalog_policy_versions_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_catalog_policy_versions
    ADD CONSTRAINT ai_catalog_policy_versions_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.ai_catalog_policies(id) ON DELETE CASCADE;


--
-- Name: ai_incidents ai_incidents_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_incidents
    ADD CONSTRAINT ai_incidents_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: ai_incidents ai_incidents_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_incidents
    ADD CONSTRAINT ai_incidents_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: ai_incidents ai_incidents_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_incidents
    ADD CONSTRAINT ai_incidents_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: ai_reviews ai_reviews_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.ai_reviews
    ADD CONSTRAINT ai_reviews_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: artifacts artifacts_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.artifacts
    ADD CONSTRAINT artifacts_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: audit_log audit_log_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE SET NULL;


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: comments comments_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: conformity_assessments conformity_assessments_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.conformity_assessments
    ADD CONSTRAINT conformity_assessments_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: departments departments_parent_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_parent_department_id_fkey FOREIGN KEY (parent_department_id) REFERENCES public.departments(id);


--
-- Name: form_fields form_fields_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_fields
    ADD CONSTRAINT form_fields_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.form_sections(id) ON DELETE CASCADE;


--
-- Name: form_policies form_policies_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_policies
    ADD CONSTRAINT form_policies_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: form_sections form_sections_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.form_sections
    ADD CONSTRAINT form_sections_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.form_policies(id) ON DELETE CASCADE;


--
-- Name: governance_approvals governance_approvals_approver_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_approvals
    ADD CONSTRAINT governance_approvals_approver_user_id_fkey FOREIGN KEY (approver_user_id) REFERENCES public.users(id);


--
-- Name: governance_approvals governance_approvals_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_approvals
    ADD CONSTRAINT governance_approvals_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.governance_roles(id);


--
-- Name: governance_approvals governance_approvals_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_approvals
    ADD CONSTRAINT governance_approvals_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: governance_evidence governance_evidence_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_evidence
    ADD CONSTRAINT governance_evidence_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: governance_evidence governance_evidence_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.governance_evidence
    ADD CONSTRAINT governance_evidence_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: modification_risk_scores modification_risk_scores_modification_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.modification_risk_scores
    ADD CONSTRAINT modification_risk_scores_modification_class_fkey FOREIGN KEY (modification_class) REFERENCES public.modification_classes(class_number);


--
-- Name: modification_risk_scores modification_risk_scores_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.modification_risk_scores
    ADD CONSTRAINT modification_risk_scores_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: organization_policies organization_policies_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.organization_policies
    ADD CONSTRAINT organization_policies_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_policies organization_policies_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.organization_policies
    ADD CONSTRAINT organization_policies_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.form_policies(id) ON DELETE CASCADE;


--
-- Name: policy_active_versions policy_active_versions_activated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_active_versions
    ADD CONSTRAINT policy_active_versions_activated_by_fkey FOREIGN KEY (activated_by) REFERENCES public.users(id);


--
-- Name: policy_active_versions policy_active_versions_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_active_versions
    ADD CONSTRAINT policy_active_versions_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.form_policies(id) ON DELETE CASCADE;


--
-- Name: policy_active_versions policy_active_versions_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_active_versions
    ADD CONSTRAINT policy_active_versions_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.policy_versions(id) ON DELETE SET NULL;


--
-- Name: policy_audit_log policy_audit_log_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_audit_log
    ADD CONSTRAINT policy_audit_log_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- Name: policy_audit_log policy_audit_log_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_audit_log
    ADD CONSTRAINT policy_audit_log_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: policy_audit_log policy_audit_log_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_audit_log
    ADD CONSTRAINT policy_audit_log_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.form_policies(id);


--
-- Name: policy_customizations policy_customizations_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_customizations
    ADD CONSTRAINT policy_customizations_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.form_fields(id) ON DELETE CASCADE;


--
-- Name: policy_customizations policy_customizations_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_customizations
    ADD CONSTRAINT policy_customizations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: policy_departments policy_departments_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_departments
    ADD CONSTRAINT policy_departments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- Name: policy_departments policy_departments_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_departments
    ADD CONSTRAINT policy_departments_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: policy_departments policy_departments_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_departments
    ADD CONSTRAINT policy_departments_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.ai_catalog_policies(id) ON DELETE CASCADE;


--
-- Name: policy_resource_restrictions policy_resource_restrictions_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_resource_restrictions
    ADD CONSTRAINT policy_resource_restrictions_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.ai_catalog_policies(id) ON DELETE CASCADE;


--
-- Name: policy_versions policy_versions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_versions
    ADD CONSTRAINT policy_versions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: policy_versions policy_versions_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.policy_versions
    ADD CONSTRAINT policy_versions_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.form_policies(id) ON DELETE CASCADE;


--
-- Name: post_market_monitoring post_market_monitoring_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.post_market_monitoring
    ADD CONSTRAINT post_market_monitoring_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: post_market_monitoring post_market_monitoring_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.post_market_monitoring
    ADD CONSTRAINT post_market_monitoring_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_modification_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_modification_class_fkey FOREIGN KEY (modification_class) REFERENCES public.modification_classes(class_number);


--
-- Name: submissions submissions_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id);


--
-- Name: submissions submissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: version_change_log version_change_log_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.version_change_log
    ADD CONSTRAINT version_change_log_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.policy_versions(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO aiuser;


--
-- PostgreSQL database dump complete
--

\unrestrict FH9tjUfdiDGAxlMgwi7x4HeuCLQ0Umc98dJTmj9Yb05ldgwt6PFgTTvS7W2NzpP

