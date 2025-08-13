-- === Ensure users.role exists and is constrained ===
-- Add column if missing
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS role text;

-- Default for new rows
ALTER TABLE public.users
  ALTER COLUMN role SET DEFAULT 'user';

-- Backfill any NULLs (in case the column already existed but was null)
UPDATE public.users SET role = 'user' WHERE role IS NULL;

-- Enforce NOT NULL
ALTER TABLE public.users
  ALTER COLUMN role SET NOT NULL;

-- Add CHECK constraint if not already present
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM   pg_constraint
    WHERE  conname = 'users_role_chk'
      AND  conrelid = 'public.users'::regclass
  ) THEN
    ALTER TABLE public.users
      ADD CONSTRAINT users_role_chk CHECK (role IN ('user','admin'));
  END IF;
END$$;

-- === Base reference tables ===
DROP TABLE IF EXISTS public.badges CASCADE;
CREATE TABLE public.badges (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category    text NOT NULL,
  title       text NOT NULL,
  description text NOT NULL,
  created_at  timestamptz DEFAULT now()
);

DROP TABLE IF EXISTS public.colleges CASCADE;
CREATE TABLE public.colleges (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        text NOT NULL,
  state       text NOT NULL,
  city        text NOT NULL,
  created_at  timestamptz DEFAULT now()
);

-- === Challenges (references badges and users) ===
DROP TABLE IF EXISTS public.challenges CASCADE;
CREATE TABLE public.challenges (
  id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category         text NOT NULL,
  title            text NOT NULL,
  description      text NOT NULL,
  reward_points    integer DEFAULT 0,
  reward_badge     integer REFERENCES public.badges(id) ON DELETE SET NULL,
  expiration_time  timestamptz NOT NULL CHECK (expiration_time >= now()),
  created_by       uuid REFERENCES public.users(id) ON DELETE SET NULL,
  approved_by      uuid REFERENCES public.users(id) ON DELETE SET NULL,
  location         text,
  votes            integer NOT NULL DEFAULT 0,
  participants     integer NOT NULL DEFAULT 0
);

-- === Shares (many per user/challenge) ===
DROP TABLE IF EXISTS public.challenge_shares CASCADE;
CREATE TABLE public.challenge_shares (
  id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  challenge_id integer NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id      uuid    NOT NULL REFERENCES public.users(id)      ON DELETE CASCADE,
  share_time   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_challenge_shares_challenge_id ON public.challenge_shares(challenge_id);
CREATE INDEX IF NOT EXISTS idx_challenge_shares_user_id      ON public.challenge_shares(user_id);

-- === Saves (bookmarks) ===
DROP TABLE IF EXISTS public.challenge_saves CASCADE;
CREATE TABLE public.challenge_saves (
  challenge_id integer REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id      uuid    REFERENCES public.users(id)      ON DELETE CASCADE,
  PRIMARY KEY (challenge_id, user_id)
);

-- === Participants ===
DROP TABLE IF EXISTS public.challenge_participants CASCADE;
CREATE TABLE public.challenge_participants (
  challenge_id integer REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id      uuid    REFERENCES public.users(id)      ON DELETE CASCADE,
  PRIMARY KEY (challenge_id, user_id)
);

-- === Votes ===
DROP TABLE IF EXISTS public.challenge_votes CASCADE;
CREATE TABLE public.challenge_votes (
  challenge_id integer REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id      uuid    REFERENCES public.users(id)      ON DELETE CASCADE,
  PRIMARY KEY (challenge_id, user_id)
);

-- === Challenge ↔ College participation ===
DROP TABLE IF EXISTS public.challenge_college_participate CASCADE;
CREATE TABLE public.challenge_college_participate (
  challenge_id integer REFERENCES public.challenges(id) ON DELETE CASCADE,
  college_id   integer REFERENCES public.colleges(id)   ON DELETE CASCADE,
  PRIMARY KEY (challenge_id, college_id)
);

-- === Submissions (one challenge per post) ===
-- Assumes public.posts(id uuid) already exists
DROP TABLE IF EXISTS public.submissions CASCADE;
CREATE TABLE public.submissions (
  id                 integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  post_id            uuid    NOT NULL REFERENCES public.posts(id)       ON DELETE CASCADE,
  challenge_id       integer NOT NULL REFERENCES public.challenges(id)  ON DELETE CASCADE,
  report_fraudulent  boolean NOT NULL DEFAULT false,
  is_verified        boolean NOT NULL DEFAULT false,
  UNIQUE (post_id)
);

-- === Badge obtain ===
DROP TABLE IF EXISTS public.badge_obtain CASCADE;
CREATE TABLE public.badge_obtain (
  badge_id integer REFERENCES public.badges(id) ON DELETE CASCADE,
  user_id  uuid    REFERENCES public.users(id)  ON DELETE CASCADE,
  PRIMARY KEY (badge_id, user_id)
);

-- === College students ===
DROP TABLE IF EXISTS public.college_students CASCADE;
CREATE TABLE public.college_students (
  college_id integer REFERENCES public.colleges(id) ON DELETE CASCADE,
  user_id    uuid    REFERENCES public.users(id)    ON DELETE CASCADE,
  PRIMARY KEY (college_id, user_id)
);
