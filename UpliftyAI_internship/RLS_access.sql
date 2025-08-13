-- ========================================
-- Strict RLS Policies for Points and Levels Tables
-- ========================================

-- Ensure RLS is enabled on all tables first
ALTER TABLE public.points_transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_points_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_level ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.level_config ENABLE ROW LEVEL SECURITY;

-- Points Transaction Table Policies
CREATE POLICY "points_transaction_select_own" 
ON public.points_transaction 
FOR SELECT 
TO authenticated 
USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "points_transaction_no_insert" 
ON public.points_transaction 
FOR INSERT 
TO authenticated
WITH CHECK (false);

CREATE POLICY "points_transaction_no_update" 
ON public.points_transaction 
FOR UPDATE 
TO authenticated
USING (false);

CREATE POLICY "points_transaction_no_delete" 
ON public.points_transaction 
FOR DELETE 
TO authenticated
USING (false);

-- User Points Summary Table Policies
CREATE POLICY "user_points_summary_select_own" 
ON public.user_points_summary 
FOR SELECT 
TO authenticated 
USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "user_points_summary_no_insert" 
ON public.user_points_summary 
FOR INSERT 
TO authenticated
WITH CHECK (false);

CREATE POLICY "user_points_summary_no_update" 
ON public.user_points_summary 
FOR UPDATE 
TO authenticated
USING (false);

CREATE POLICY "user_points_summary_no_delete" 
ON public.user_points_summary 
FOR DELETE 
TO authenticated
USING (false);

-- User Level Table Policies
CREATE POLICY "user_level_select_own" 
ON public.user_level 
FOR SELECT 
TO authenticated 
USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "user_level_no_insert" 
ON public.user_level 
FOR INSERT 
TO authenticated
WITH CHECK (false);

CREATE POLICY "user_level_no_update" 
ON public.user_level 
FOR UPDATE 
TO authenticated
USING (false);

CREATE POLICY "user_level_no_delete" 
ON public.user_level 
FOR DELETE 
TO authenticated
USING (false);

-- Level Config Table Policies
CREATE POLICY "level_config_view_all" 
ON public.level_config 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "level_config_no_insert" 
ON public.level_config 
FOR INSERT 
TO authenticated
WITH CHECK (false);

CREATE POLICY "level_config_no_update" 
ON public.level_config 
FOR UPDATE 
TO authenticated
USING (false);

CREATE POLICY "level_config_no_delete" 
ON public.level_config 
FOR DELETE 
TO authenticated
USING (false);

-- Service Role Policies for Administrative Access
CREATE POLICY "service_role_manage_points_transaction" 
ON public.points_transaction 
FOR ALL 
TO service_role 
USING (true)
WITH CHECK (true);

CREATE POLICY "service_role_manage_user_points_summary" 
ON public.user_points_summary 
FOR ALL 
TO service_role 
USING (true)
WITH CHECK (true);

CREATE POLICY "service_role_manage_user_levels" 
ON public.user_level 
FOR ALL 
TO service_role 
USING (true)
WITH CHECK (true);

CREATE POLICY "service_role_manage_level_config" 
ON public.level_config 
FOR ALL 
TO service_role 
USING (true)
WITH CHECK (true);