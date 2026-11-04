-- REVIEW FIRST: backup database before running. This migration preserves old notes.
-- Apply in Supabase SQL Editor before testing the patched Flutter application.
BEGIN;

ALTER TABLE public.data_home
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.data_archive
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_data_home_owner ON public.data_home(user_id);
CREATE INDEX IF NOT EXISTS idx_data_archive_owner ON public.data_archive(user_id);

-- Old id_user is an integer belonging to the legacy login system.
-- It must not be mandatory for NEW rows that use auth.users.id instead.
DO $$
DECLARE tbl text;
BEGIN
  FOREACH tbl IN ARRAY ARRAY['data_home', 'data_archive'] LOOP
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema='public' AND table_name=tbl
        AND column_name='id_user' AND is_nullable='NO'
    ) THEN
      EXECUTE format('ALTER TABLE public.%I ALTER COLUMN id_user DROP NOT NULL', tbl);
    END IF;
  END LOOP;
END $$;

-- Bỏ giá trị mặc định của ID tài khoản cũ.
ALTER TABLE public.data_home
  ALTER COLUMN id_user DROP DEFAULT;

ALTER TABLE public.data_archive
  ALTER COLUMN id_user DROP DEFAULT;

COMMIT;

-- Rows with user_id IS NULL are legacy notes. They are NOT deleted.
-- Assign each existing id_user to the correct auth.users.id (UUID) manually
-- before enabling RLS; read MIGRATION_GUIDE.md.
