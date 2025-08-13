-- ========================================
-- 1. Points Transaction Table
-- Tracks all point changes for each user
-- ========================================
create table public.points_transaction (
  id SERIAL primary key,
  user_id UUID not null references public.users (id) on delete CASCADE,
  change_amount INTEGER not null, -- Positive for gain, negative for spend
  reason VARCHAR(50) not null, -- e.g., guess_who, uplifting_message, buy_banner
  related_entity_type VARCHAR(50), -- e.g., post, challenge, house
  related_entity_id INTEGER, -- ID of the related entity
  created_at TIMESTAMP not null default CURRENT_TIMESTAMP
);

-- Indexes for faster queries
create index idx_points_transaction_user on public.points_transaction (user_id);

create index idx_points_transaction_reason on public.points_transaction (reason);

create index idx_points_transaction_created_at on public.points_transaction (created_at);

-- ========================================
-- 2. User Points Summary Table
-- Stores current points and streaks for quick access
-- ========================================
create table public.user_points_summary (
  user_id UUID primary key references public.users (id) on delete CASCADE,
  total_points INTEGER not null default 0,
  daily_post_streak INTEGER not null default 0,
  daily_comment_streak INTEGER not null default 0,
  last_post_date DATE,
  last_comment_date DATE
);

create index idx_user_points_summary_points on public.user_points_summary (total_points desc);

-- ========================================
-- 3. User Level Table
-- Stores user level and experience
-- ========================================
create table public.user_level (
  user_id UUID primary key references public.users (id) on delete CASCADE,
  level INTEGER not null default 1,
  exp INTEGER not null default 0,
  last_level_up TIMESTAMP
);

create index idx_user_level_level on public.user_level (level desc);

-- ========================================
-- 4. Level Config Table
-- Defines requirements and unlocked features for each level
-- ========================================
create table public.level_config (
  level INTEGER primary key,
  required_exp INTEGER not null, -- Total EXP required to reach this level
  unlocked_features JSONB -- JSON of unlocked abilities/features
);

-- ========================================
-- Trigger Function: Update user_points_summary.total_points
-- Automatically runs after inserting into points_transaction
-- ========================================
create or replace function public.update_user_points_summary () RETURNS TRIGGER as $$
BEGIN
    -- Insert a new row if user does not exist, otherwise update total_points
    INSERT INTO public.user_points_summary (user_id, total_points)
    VALUES (NEW.user_id, NEW.change_amount)
    ON CONFLICT (user_id)
    DO UPDATE SET total_points = public.user_points_summary.total_points + NEW.change_amount;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- Create Trigger
-- ========================================
create trigger trg_update_user_points_summary
after INSERT on public.points_transaction for EACH row
execute FUNCTION public.update_user_points_summary ();