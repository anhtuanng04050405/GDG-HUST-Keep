-- SECURITY CUTOVER: apply once nobody uses the old username+password clients.
-- Existing legacy login rows remain stored for now, but client access is blocked.
-- AFTER verifying migration, securely remove the plaintext password column/data
-- according to team backup/retention policy.
BEGIN;
ALTER TABLE public.login ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.login FROM anon, authenticated;
COMMIT;
