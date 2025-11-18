-- Insert admin user if not exists
INSERT INTO users (email, password_hash, name, role)
SELECT 'faganronan@gmail.com', '$2b$10$fGvyIwCCwBtfahQ2RPXJLeRuX2SH1WYL73JBrLDc2aHnJlcHJ2OWS', 'Ronan Fagan', 'admin'
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE email = 'faganronan@gmail.com'
);
