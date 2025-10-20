import { createClient } from '@supabase/supabase-js';

// Initialize a Supabase client using environment variables. These variables must
// be defined in your `.env` file or set as GitHub secrets during CI builds.
export const supabase = createClient(
  import.meta.env.SUPABASE_URL!,
  import.meta.env.SUPABASE_ANON_KEY!
);