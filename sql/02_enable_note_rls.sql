-- IMPORTANT: Run only AFTER 01_add_user_id_uuid.sql and user ownership backfill.
-- Ensure no legacy client depends on the unsecured table access.
-- Check existing policies first: this script refuses to run with unknown policies.
BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('data_home', 'data_archive')
  ) THEN
    RAISE EXCEPTION 'Policies already exist: review pg_policies before applying';
  END IF;
END $$;

ALTER TABLE public.data_home ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_archive ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.data_home, public.data_archive FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.data_home, public.data_archive TO authenticated;

-- Auto-increment id sequences may require explicit usage permission.
DO $$
DECLARE tbl text;
DECLARE seq text;
BEGIN
  FOREACH tbl IN ARRAY ARRAY['data_home', 'data_archive'] LOOP
    seq := pg_get_serial_sequence('public.' || tbl, 'id');
    IF seq IS NOT NULL THEN
      EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %s TO authenticated', seq);
    END IF;
  END LOOP;
END $$;

CREATE POLICY "home_select_own" ON public.data_home
  FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "home_insert_own" ON public.data_home
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "home_update_own" ON public.data_home
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "home_delete_own" ON public.data_home
  FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "archive_select_own" ON public.data_archive
  FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "archive_insert_own" ON public.data_archive
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "archive_update_own" ON public.data_archive
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "archive_delete_own" ON public.data_archive
  FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) = user_id);

COMMIT;
